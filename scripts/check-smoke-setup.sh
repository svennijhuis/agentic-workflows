#!/usr/bin/env bash
# SM07a smoke setup checklist check. Args: one or more checklist files (default smoke/SETUP.md).
# Prints one `file:line SMOKESETUP message` per hit. Exit 0 ok, 1 a hit (fail closed), 2 needs-human (yq missing).
# Gate phase, in this order, stops the file at its first hit (before the verify-line scan):
#   1 frontmatter slice: line 1 is `---` and a closing `---` follows (the `fm` slice of policies/checks/lib.sh)
#   2 `yq` parses the slice (only the slice, never the markdown body), the slice is a map, no duplicate key
#   3 `steps` is an integer
#   4 every fence closes: open = 3+ backticks or tildes; close = same char, at least as long, nothing after
#   5 at least one numbered step (`N. ` at column 0, outside fences)
#   6 `steps` equals the count of numbered steps
#   7 steps are numbered 1, 2, 3 ... in order
# Then the scan: every step has an indented `verify: <text>` (or `- verify: <text>`) line before the next step
# or heading, outside fences.
set -uo pipefail
case "${1:-}" in -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac
command -v yq >/dev/null 2>&1 || { echo "scripts/check-smoke-setup.sh:1 VERIFY needs-human missing: yq"; exit 2; }
N=0; fch=''; flen=0
hit() { echo "$1:$2 SMOKESETUP $3"; N=$((N + 1)); } # FILE LINE MESSAGE
# shellcheck disable=SC2016 # $m is a yq variable
KEYS='.. | select(tag == "!!map") | . as $m | keys | .[] | [($m | line), .] | @tsv'

# in_fence LINE: track one fence (marker char and length). Returns 0 when LINE opens, is inside or closes a
# fence, 1 when LINE is outside every fence. A close is the same char, at least as long, nothing after it.
in_fence() {
  local l=$1
  if [ -n "$fch" ]; then
    [[ $l =~ ^[[:space:]]*(\`{3,}|~{3,})[[:space:]]*$ ]] && [ "${BASH_REMATCH[1]:0:1}" = "$fch" ] \
      && [ "${#BASH_REMATCH[1]}" -ge "$flen" ] && fch=''
    return 0
  fi
  [[ $l =~ ^[[:space:]]*(\`{3,}|~{3,})(.*)$ ]] || return 1
  # a backtick fence info string may not hold a backtick (CommonMark), so that line is not a fence
  [ "${BASH_REMATCH[1]:0:1}" = '~' ] || [[ ${BASH_REMATCH[2]} != *\`* ]] || return 1
  fch=${BASH_REMATCH[1]:0:1}; flen=${#BASH_REMATCH[1]}
}

check_file() {
  local f=$1 close slice v tag want line k i l n fline=0 cur=0 cur_line=0 have=0
  local -a L steps=()
  fch=''; flen=0
  [ -f "$f" ] || { hit "$f" 1 "no such file"; return; }
  mapfile -t L <"$f"
  # 1 frontmatter slice
  [ "${L[0]:-}" = "---" ] || { hit "$f" 1 "no frontmatter (line 1 must be ---)"; return; }
  close=0
  for ((i = 1; i < ${#L[@]}; i++)); do [ "${L[i]}" = "---" ] && { close=$((i + 1)); break; }; done
  [ "$close" -gt 0 ] || { hit "$f" 1 "frontmatter is not closed (no second ---)"; return; }
  slice=$(printf '%s\n' "${L[@]:1:close-2}")
  # 2 parse, map, duplicate keys (yq keeps the last of two keys, so steps: 8 then steps: 2 would read as 2)
  if ! tag=$(yq 'tag' <<<"$slice" 2>/dev/null); then hit "$f" 2 "frontmatter parse error (yq)"; return; fi
  [ "$tag" = "!!map" ] || { hit "$f" 2 "frontmatter is not a map ($tag)"; return; }
  v=$(yq -r "$KEYS" <<<"$slice" 2>/dev/null) || { hit "$f" 2 "frontmatter keys do not read"; return; }
  while IFS=$'\t' read -r line k; do
    [ -n "$line" ] && { hit "$f" "$((line + 1))" "duplicate frontmatter key '$k'"; return; }
  done < <(sort <<<"$v" | uniq -d)
  # 3 steps is an integer
  [ "$(yq '.steps | tag' <<<"$slice")" = "!!int" ] || { hit "$f" 1 "frontmatter steps is missing or not an integer"; return; }
  want=$(yq '.steps' <<<"$slice")
  # 4 every fence closes; 5 to 7 numbered steps outside fences
  for ((i = close; i < ${#L[@]}; i++)); do
    l=${L[i]}
    if [ -n "$fch" ]; then in_fence "$l"; continue; fi
    in_fence "$l" && { fline=$((i + 1)); continue; }
    [[ $l =~ ^([0-9]+)\.[[:space:]] ]] && steps+=("$((i + 1)):${BASH_REMATCH[1]}")
  done
  [ -z "$fch" ] || { hit "$f" "$fline" "code fence opened here is never closed"; return; }
  n=${#steps[@]}
  [ "$n" -gt 0 ] || { hit "$f" 1 "0 numbered steps"; return; }
  [ "$n" -eq "$want" ] || { hit "$f" 1 "frontmatter steps: $want but $n numbered steps"; return; }
  for ((i = 0; i < n; i++)); do
    [ "$((10#${steps[i]#*:}))" -eq "$((i + 1))" ] || { hit "$f" "${steps[i]%%:*}" "step numbered ${steps[i]#*:}, expected $((i + 1))"; return; }
  done
  # verify-line scan outside fences: a step ends at the next step, a heading or end of file
  for ((i = close; i <= ${#L[@]}; i++)); do
    l=${L[i]:-}
    [ "$i" -lt "${#L[@]}" ] && in_fence "$l" && continue
    if [ "$i" -eq "${#L[@]}" ] || [[ $l =~ ^[0-9]+\.[[:space:]] ]] || [[ $l =~ ^# ]]; then
      [ "$cur" -gt 0 ] && [ "$have" -eq 0 ] && hit "$f" "$cur_line" "step $cur has no verify: line (or it is empty)"
      cur=0
      [[ $l =~ ^([0-9]+)\.[[:space:]] ]] && { cur=$((10#${BASH_REMATCH[1]})); cur_line=$((i + 1)); have=0; }
      continue
    fi
    [[ $l =~ ^[[:space:]]+(-[[:space:]]+)?verify:[[:space:]]*[^[:space:]] ]] && have=1
  done
}

[ $# -gt 0 ] || set -- smoke/SETUP.md
for f in "$@"; do check_file "$f"; done
[ "$N" -eq 0 ]
