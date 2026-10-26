#!/usr/bin/env bash
# POL27 verify toolchain pinned in one place (VF01).
# Roots: .github/aw.json and .github/workflows/verify.yml (repo mode; a missing root is a hit).
# Args: a file named *aw.json or *verify.yml, or a folder holding aw.json and or verify.yml (a folder
#   without either is a folder of cases). Any other file is not a POL27 root: no line, exit 0.
# aw.json: one gh-aw pin (top-level `gh-aw`), and tools: actionlint, gitleaks, yq, shellcheck each with
#   version, url (naming that version as its own token) and sha256. verify.yml (VF02d1): the only download
#   is a plain `curl ... -o FILE <tools: url>` line at the top level of a step run: block, and that same
#   block checks FILE with the exact sha256 line, top level, after the curl; every tools: url is
#   downloaded that way; no step or job sets continue-on-error or a shell without -e; gh-aw is
#   installed at the gh-aw pin.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
command -v jq >/dev/null 2>&1 || { echo "policies/checks/POL27.sh:1 VERIFY needs-human missing: jq"; exit 2; }
TOOLS="actionlint gitleaks yq shellcheck"
# SET_E: a set that turns errexit off (set +e, set +eu, set +o errexit, quoted or not).
SET_E="(^|[;&|({[:space:]])set[[:space:]]+['\"]?(\\+[A-Za-z]*e[A-Za-z]*|\\+o[[:space:]]+['\"]?errexit)(['\"[:space:];]|\$)"

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
    # The version is its own token in the url, so 1.7.1 does not match a 1.7.12 url (Cursor 5655973880 low 5).
    case "$u" in https://*) grep -qE "(^|[^0-9.])${v//./\\.}([^0-9.]|\\.[^0-9]|\\.?\$)" <<<"$u" ;; *) false ;; esac \
      || hit "$r" "$(fline "$f" "\"$t\"")" POL27 "$t url missing, not https, or not naming version $v as its own token"
    [[ "$s" =~ ^[0-9a-f]{64}$ ]] || hit "$r" "$(fline "$f" "\"$t\"")" POL27 "$t sha256 missing or not 64 hex (C14)"
  done
}

# Allowlist, not a denylist (Reviewer 6421748756, round 3; VF02d1). Rows come from run_lines (lib.sh): one
# trimmed, comment-free shell line per row with its job, step, file line and TOP flag. A download is only a
# row that starts with plain `curl ` at the top level. Any other spelling of curl (\curl, /usr/bin/curl,
# bin/curl, command curl, after && or $( ) and any wget or aria2c is a hit (Cursor 5655973880 high 1). The
# check is a row in the SAME run: block, after the curl, at the top level (no if, then, case, loop,
# heredoc or continuation opened before it in that block), that is exactly
# `echo "<pinned sha256>  FILE" | sha256sum -c -` (Cursor 5655973880 high 2). A set +e or set +o errexit
# (quoted or not) earlier in that block is a hit (Tester 2 6421487873 item 2, Cursor 5655973880 medium 3).
check_verify() { # VERIFY_YML AW_JSON
  local f=$1 aw=$2 r t u s o pin rows j st l top txt want found urls="" k jj ss ll tt xx; r=$(rel "$f")
  if ! yq -e 'tag == "!!map"' "$f" >/dev/null 2>&1; then hit "$r" 1 POL27 "parse error: not a YAML map"; return; fi
  errexit_hits "$f" POL27
  rows=$(run_lines "$f")
  while IFS=$'\037' read -r j st l top txt; do
    [ -n "$l" ] || continue
    if grep -qE '(^|[^A-Za-z0-9_.-])(wget|aria2c)([^A-Za-z0-9_.-]|$)' <<<"$txt"; then
      hit "$r" "$l" POL27 "downloader $(grep -oE -m1 'wget|aria2c' <<<"$txt") is not allowed; the only download is plain curl ... -o FILE (C14)"; continue
    fi
    if [[ "$txt" != "curl "* ]]; then
      grep -qE '(^|[^A-Za-z0-9_.-])curl([^A-Za-z0-9_.-]|$)' <<<"$txt" \
        && hit "$r" "$l" POL27 "curl is not a plain curl ... -o FILE line (\\curl, a path, a wrapper or a chain); only that shape is a download (C14)"
      continue
    fi
    [ "$top" = 1 ] || { hit "$r" "$l" POL27 "curl sits inside if, a loop, a heredoc or a continuation; a download must be top level (C14)"; continue; }
    u=$(grep -oE 'https://[^[:space:]"|;&]+' <<<"$txt" | head -1)
    t=$(jq -r --arg u "$u" '.tools // {} | to_entries[] | select(.value.url == $u) | .key' "$aw" 2>/dev/null | head -1)
    if [ -z "$t" ]; then hit "$r" "$l" POL27 "curl downloads ${u:-an unnamed url}, not a tools: url in .github/aw.json"; continue; fi
    s=$(jq -r --arg t "$t" '.tools[$t].sha256' "$aw")
    o=$(grep -oE -- '(^|[[:space:]])-o[[:space:]]+[^[:space:]]+' <<<"$txt" | head -1 | awk '{print $2}')
    if [ -z "$o" ]; then hit "$r" "$l" POL27 "$t curl has no -o file to check (C14)"; continue; fi
    want="echo \"$s  $o\" | sha256sum -c -"; found=""
    while IFS=$'\037' read -r jj ss ll k tt; do
      if [ "$jj" != "$j" ] || [ "$ss" != "$st" ] || [ "$ll" -le "$l" ] || [ "$tt" != "$want" ]; then continue; fi
      if [ "$k" != 1 ]; then found="check line $ll sits inside if, a loop, a heredoc or a continuation, so it may never run"; continue; fi
      xx=$(while IFS=$'\037' read -r a b c _ e; do [ "$a" = "$j" ] && [ "$b" = "$st" ] && [ "$c" -lt "$ll" ] && grep -qE -- "$SET_E" <<<"$e" && echo "$c"; done <<<"$rows" | head -1)
      if [ -n "$xx" ]; then found="check line $ll runs after set +e (line $xx), so a failed sha256sum -c does not stop the step"; continue; fi
      found=ok; break
    done <<<"$rows"
    case "$found" in
      ok) urls="$urls $u" ;;
      "") hit "$r" "$l" POL27 "$t download has no top-level line in the same run: block after it that is exactly: $want (C14)" ;;
      *) hit "$r" "$l" POL27 "$t download $found (C14)" ;;
    esac
  done <<<"$rows"
  for t in $TOOLS; do
    u=$(jq -r --arg t "$t" '.tools[$t].url // "" | strings' "$aw" 2>/dev/null)
    [ -n "$u" ] && [[ " $urls " != *" $u "* ]] && hit "$r" 1 POL27 "does not download and check the $t pin from .github/aw.json with plain curl -o FILE plus its sha256 line"
  done
  pin=$(jq -r '.["gh-aw"] // ""' "$aw" 2>/dev/null)
  cut -d $'\037' -f5 <<<"$rows" | grep -qxF "gh extension install github/gh-aw --pin $pin" || hit "$r" "$(gline "$f" 'gh-aw')" POL27 "does not install gh-aw at the pin $pin"
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
