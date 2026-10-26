#!/usr/bin/env bash
# SM01 smoke scenario check. Args: one or more scenarios.yml files (smoke/<feature>/scenarios.yml or fixtures).
# Prints one `file:line SMOKE message` per hit. Exit 0 ok, 1 a hit or a file that does not parse (fail closed),
# 2 needs-human (yq missing). Format: smoke/README.md, smoke/_schema.yml.
set -uo pipefail
command -v yq >/dev/null 2>&1 || { echo "scripts/check-smoke.sh:1 VERIFY needs-human missing: yq"; exit 2; }
N=0
hit() { echo "$1:$2 SMOKE $3"; N=$((N + 1)); } # FILE LINE MESSAGE
TOKEN='[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'

# one row per scenario: line, tag, id, env, method, path, auth tag, auth, expect tag, status tag, status,
# expect.json tag, test_data_only tag and value, count of bad expect.json items
SCALARS='((.. | select(tag == "!!str")), (.. | select(tag == "!!map") | keys | .[])) | [line, .] | @tsv'
ROWS='.scenarios[] | [line, tag, (.id // "" | tostring), (.env // "" | tostring), (.method // "" | tostring),
  (.path // "" | tostring), (.auth | tag), (.auth // "" | tostring), (.expect | tag), (.expect.status | tag),
  (.expect.status // 0 | tostring), (.expect.json | tag), (.test_data_only | tag), (.test_data_only | tostring),
  ([(select(.expect.json | tag == "!!seq") | .expect.json[]) | select(tag != "!!map" or (.path | tag) != "!!str"
    or ((.path // "") | test("^[$]") | not) or (has("equals") == has("exists"))
    or (has("exists") and .exists != true))] | length | tostring)] | @tsv'

check_file() {
  local f=$1 docs top rows line tag id env method path atag auth etag stag status jtag ttag tdo jbad v
  [ -f "$f" ] || { hit "$f" 1 "no such file"; return; }
  if ! docs=$(yq -N 'document_index' "$f" 2>/dev/null); then hit "$f" 1 "parse error (yq)"; return; fi
  [ "$(grep -c . <<<"$docs")" -le 1 ] || { hit "$f" 1 "more than one YAML document"; return; }
  # token shape on any scalar, keys included
  if ! v=$(yq -r "$SCALARS" "$f" 2>/dev/null); then hit "$f" 1 "scalars do not read"; return; fi
  while IFS=$'\t' read -r line v; do
    [ -n "$line" ] || continue
    if grep -qE "$TOKEN" <<<"$v" || grep -qiE '^[[:space:]]*bearer ' <<<"$v"; then hit "$f" "$line" "token-shaped value (no tokens in scenario files)"; fi
  done <<<"$v"
  top=$(yq -r '[tag, (.scenarios | tag), (.scenarios | length)] | @tsv' "$f" 2>/dev/null)
  IFS=$'\t' read -r tag stag rows <<<"$top"
  if [ "$tag" != '!!map' ] || [ "$stag" != '!!seq' ] || [ "${rows:-0}" -eq 0 ]; then
    hit "$f" 1 "top level must be a map with a non-empty scenarios: list"; return
  fi
  if ! rows=$(yq -r "$ROWS" "$f" 2>/dev/null); then hit "$f" 1 "scenario fields do not read (bad shape)"; return; fi
  while IFS=$'\037' read -r line tag id env method path atag auth etag stag status jtag ttag tdo jbad; do
    [ -n "$line" ] || continue
    if [ "$tag" != '!!map' ]; then hit "$f" "$line" "scenario must be a map"; continue; fi
    { [ -z "$id" ] || [ "$id" = null ]; } && hit "$f" "$line" "id missing"
    case "$env" in tst|acc) ;; *) hit "$f" "$line" "env '$env' not allowed (only tst or acc)" ;; esac
    [[ "$method" =~ ^[A-Za-z]+$ ]] || hit "$f" "$line" "method missing or not a word"
    if [[ ! "$path" =~ ^/ ]] || [[ "$path" =~ ^// ]] || [[ "$path" == *"\\"* ]] || [[ "$path" =~ [[:space:]] ]]; then
      hit "$f" "$line" "path '$path' must be relative: one leading /, no scheme, no host (host only from SMOKE_BASE_URL)"
    fi
    if [ "$atag" != '!!str' ] || { [ "$auth" != none ] && [ "$auth" != smoke-jwt ]; }; then
      hit "$f" "$line" "auth must be none or smoke-jwt"
    fi
    if [ "$etag" != '!!map' ]; then hit "$f" "$line" "expect missing"
    elif [ "$stag" != '!!int' ] || [ "$status" -lt 100 ] || [ "$status" -gt 599 ]; then hit "$f" "$line" "expect.status must be an HTTP status (100 to 599)"; fi
    case "$jtag" in '!!null'|'!!seq') ;; *) jbad=1 ;; esac
    [ "$jbad" = 0 ] || hit "$f" "$line" "expect.json items need path: \$... and exactly one of equals or exists: true"
    if [ "$method" != GET ] && [ "$method" != HEAD ]; then
      { [ "$ttag" != '!!bool' ] || [ "$tdo" != true ]; } && hit "$f" "$line" "write method '$method' needs test_data_only: true"
    fi
  done < <(tr '\t' '\037' <<<"$rows")
}

[ $# -gt 0 ] || { echo "scripts/check-smoke.sh:1 SMOKE usage: check-smoke.sh FILE..."; exit 1; }
for f in "$@"; do check_file "$f"; done
[ "$N" -eq 0 ]
