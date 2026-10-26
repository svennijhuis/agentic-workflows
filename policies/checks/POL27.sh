#!/usr/bin/env bash
# POL27 verify toolchain pinned in one place (VF01).
# Roots: .github/aw.json and .github/workflows/verify.yml (repo mode; a missing root is a hit).
# Args: a file named *aw.json or *verify.yml, or a folder holding aw.json and or verify.yml (a folder
#   without either is a folder of cases). Any other file is not a POL27 root: no line, exit 0.
# aw.json: one gh-aw pin (top-level `gh-aw`), and tools: actionlint, gitleaks, yq, shellcheck each with
#   version, url (naming that version) and sha256. verify.yml: every curl downloads a tools: url and
#   checks its sha256, every tools: url is installed, and gh-aw is installed at the gh-aw pin.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
command -v jq >/dev/null 2>&1 || { echo "policies/checks/POL27.sh:1 VERIFY needs-human missing: jq"; exit 2; }
TOOLS="actionlint gitleaks yq shellcheck"

check_aw() { # FILE: 0 when it parses (later checks may read it)
  local f=$1 r t v u s n; r=$(rel "$f")
  if ! jq -e 'type == "object"' "$f" >/dev/null 2>&1; then hit "$r" 1 POL27 "parse error: not a JSON object"; return 1; fi
  v=$(jq -r '.["gh-aw"] // "" | strings' "$f")
  [[ "$v" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || hit "$r" 1 POL27 "top-level gh-aw pin missing or not vX.Y.Z"
  n=$(jq '[paths | select(.[-1] == "gh-aw")] | length' "$f")
  [ "$n" -le 1 ] || hit "$r" "$(grep -nE '"gh-aw"[[:space:]]*:' "$f" | tail -1 | cut -d: -f1)" POL27 "second gh-aw pin ($n gh-aw keys, only the top-level one is allowed)"
  [ "$(jq -r '.tools | type' "$f")" = object ] || { hit "$r" 1 POL27 "no tools: map"; return 0; }
  for t in $TOOLS; do
    v=$(jq -r --arg t "$t" '.tools[$t].version // "" | strings' "$f")
    u=$(jq -r --arg t "$t" '.tools[$t].url // "" | strings' "$f")
    s=$(jq -r --arg t "$t" '.tools[$t].sha256 // "" | strings' "$f")
    if [ -z "$v$u$s" ]; then hit "$r" 1 POL27 "tools: has no $t pin"; continue; fi
    [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || hit "$r" "$(fline "$f" "\"$t\"")" POL27 "$t version missing or not X.Y.Z"
    case "$u" in https://*"$v"*) ;; *) hit "$r" "$(fline "$f" "\"$t\"")" POL27 "$t url missing, not https, or not naming version $v" ;; esac
    [[ "$s" =~ ^[0-9a-f]{64}$ ]] || hit "$r" "$(fline "$f" "\"$t\"")" POL27 "$t sha256 missing or not 64 hex (C14)"
  done
}

# A check line holds the pinned sha256 and sha256sum -c, names the -o file as a whole token (split on
# space and quotes, so xgitleaks.tar.gz does not count for gitleaks.tar.gz), does not mask a failed
# check with || true or || :, and has no set +e (or set +o errexit) on any line before it (Tester 2
# 6421487873 items 1 and 2). Prints nothing when one line passes, else why the download is unchecked.
check_line() { # CODE SHA256 FILE
  local code=$1 s=$2 o=$3 c n txt why
  why="has no sha256sum -c line naming its pinned sha256 and $o"
  while IFS= read -r c; do
    n=${c%%:*}; txt=${c#*:}
    tr -s ' \t"'"'"'' '\n' <<<"$txt" | grep -qxF -- "$o" || continue
    if grep -qE '\|\|[[:space:]]*(true|:)([[:space:];)]|$)' <<<"$txt"; then why="check line $n masks a failed sha256sum -c with || true or || :"; continue; fi
    if head -n "$n" <<<"$code" | grep -qE '(^|[;&|({[:space:]])set[[:space:]]+(\+[A-Za-z]*e[A-Za-z]*|\+o[[:space:]]+errexit)([[:space:];]|$)'; then why="check line $n runs after set +e, so a failed sha256sum -c does not stop the step"; continue; fi
    return 0
  done < <(grep -nF -- "$s" <<<"$code" | grep -F 'sha256sum -c')
  echo "$why"
}

check_verify() { # VERIFY_YML AW_JSON
  local f=$1 aw=$2 r t u s o l pin code why; r=$(rel "$f")
  if ! yq -e 'tag == "!!map"' "$f" >/dev/null 2>&1; then hit "$r" 1 POL27 "parse error: not a YAML map"; return; fi
  # Comments do not count: a url, sha256 or check that only sits after # is not installed or checked
  # (Cursor 5655409212 medium 1). sed keeps the line count, so line numbers still match the file.
  code=$(sed -E 's/(^|[[:space:]])#.*$//' "$f")
  while IFS= read -r l; do
    u=$(grep -oE 'https://[^[:space:]"|]+' <<<"${l#*:}" | head -1)
    t=$(jq -r --arg u "$u" '.tools // {} | to_entries[] | select(.value.url == $u) | .key' "$aw" 2>/dev/null | head -1)
    if [ -z "$t" ]; then hit "$r" "${l%%:*}" POL27 "curl downloads ${u:-an unnamed url}, not a tools: url in .github/aw.json"; continue; fi
    s=$(jq -r --arg t "$t" '.tools[$t].sha256' "$aw")
    o=$(grep -oE -- '(^|[[:space:]])-o[[:space:]]+[^[:space:]]+' <<<"${l#*:}" | head -1 | awk '{print $2}')
    if [ -z "$o" ]; then hit "$r" "${l%%:*}" POL27 "$t curl has no -o file to check (C14)"; continue; fi
    why=$(check_line "$code" "$s" "$o")
    [ -z "$why" ] || hit "$r" "${l%%:*}" POL27 "$t download $why (C14)"
  done < <(grep -nE '(^|[[:space:]])curl[[:space:]]' <<<"$code")
  for t in $TOOLS; do
    u=$(jq -r --arg t "$t" '.tools[$t].url // "" | strings' "$aw" 2>/dev/null)
    [ -n "$u" ] && ! grep -qF -- "$u" <<<"$code" && hit "$r" 1 POL27 "does not install the $t pin from .github/aw.json"
  done
  pin=$(jq -r '.["gh-aw"] // ""' "$aw" 2>/dev/null)
  grep -qE "gh extension install github/gh-aw --pin $pin([[:space:]]|$)" <<<"$code" || hit "$r" "$(gline "$f" 'gh-aw')" POL27 "does not install gh-aw at the pin $pin"
}

check_pair() { # AW_JSON|"" VERIFY_YML|""
  local aw=$1 vy=$2 ok=1
  [ -n "$aw" ] && { check_aw "$aw" || ok=0; }
  [ -n "$vy" ] || return 0
  [ -n "$aw" ] || aw="$POL_ROOT/.github/aw.json"
  if [ "$ok" = 1 ] && jq -e . "$aw" >/dev/null 2>&1; then check_verify "$vy" "$aw"; fi
}

check_arg() { # PATH
  local a=$1 x
  if [ -d "$a" ]; then
    if [ -e "$a/aw.json" ] || [ -e "$a/verify.yml" ]; then
      check_pair "$([ -e "$a/aw.json" ] && echo "$a/aw.json")" "$([ -e "$a/verify.yml" ] && echo "$a/verify.yml")"
    else
      for x in "$a"/*; do [ -e "$x" ] && check_arg "$x"; done
    fi
    return
  fi
  case "$(basename "$a")" in
    *aw.json) check_pair "$a" "" ;;
    *verify.yml) check_pair "" "$a" ;;
  esac
}

if repo_mode "$@"; then
  aw="$POL_ROOT/.github/aw.json"; vy="$POL_ROOT/.github/workflows/verify.yml"
  [ -s "$aw" ] || hit .github/aw.json 1 POL27 "root missing or empty"
  [ -s "$vy" ] || hit .github/workflows/verify.yml 1 POL27 "root missing or empty"
  if [ "$HITS" -eq 0 ]; then check_pair "$aw" "$vy"; fi
else
  for a in "$@"; do check_arg "$a"; done
fi
pol_done
