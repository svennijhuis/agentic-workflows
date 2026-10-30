#!/usr/bin/env bash
# SM01 smoke scenario check. Args: one or more scenarios.yml files (smoke/<feature>/scenarios.yml or fixtures).
# Prints one `file:line SMOKE message` per hit. Exit 0 ok, 1 a hit or a file that does not parse (fail closed),
# 2 needs-human (yq missing). Format: smoke/README.md, smoke/_schema.yml.
set -uo pipefail
command -v yq >/dev/null 2>&1 || { echo "scripts/check-smoke.sh:1 VERIFY needs-human missing: yq"; exit 2; }
N=0
hit() { echo "$1:$2 SMOKE $3"; N=$((N + 1)); } # FILE LINE MESSAGE

is_dec_int() { [[ "$1" =~ ^[0-9]+$ ]]; }

url_decode_once() {
  python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1], errors="strict"))' "$1" 2>/dev/null
}

# shellcheck disable=SC2016
KEYS='.. | select(tag == "!!map") | . as $m | $m | keys | group_by(.) | .[] | select(length > 1) | .[0] | [($m | line), .] | @tsv'
# shellcheck disable=SC2016
TOKENS='.. | select(tag == "!!str" or tag == "!!int" or tag == "!!float" or tag == "!!bool") | select(
  (tostring | test("(?i)(^|[^A-Za-z0-9])(gh[pousr]_|github_pat_|glpat-|sk_live_|sk_test_|rk_live_|rk_test_|xox[abpr]-|xoxe-|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,})"))
  or (tostring | test("(?i)(^|[^A-Za-z0-9])(bearer|basic|token)[[:space:]]+[A-Za-z0-9_.-]+"))
  or (tostring | test("[A-Za-z0-9_-]{10,}\\.[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]{10,}"))
  or (tostring | test("^eyJ"))
) | [line, "token-shaped value (no tokens in scenario files)"] | @tsv'
# shellcheck disable=SC2016
HDRS='.scenarios[]? | select(tag == "!!map") | .headers | select(tag == "!!map") | keys | .[] | [line, .] | @tsv'
# shellcheck disable=SC2016
ROWS='.scenarios[] | [line, tag, (.id | tag), (.id // "" | tostring), (.env // "" | tostring), (.method // "" | tostring),
  (.path // "" | tostring), (.auth | tag), (.auth // "" | tostring), (.expect | tag), (.expect.status | tag),
  (.expect.status // 0 | tostring), (.expect.status // 0), (.expect.json | tag), (.headers | tag),
  (.test_data_only | tag), (.test_data_only | tostring),
  ([(select(.expect.json | tag == "!!seq") | .expect.json[]) | select(tag != "!!map" or (.path | tag) != "!!str"
    or ((.path // "") | test("^[$]") | not) or (has("equals") == has("exists"))
    or (has("exists") and ((.exists | tag) != "!!bool" or .exists != true)))] | length | tostring)] | @tsv'

HEADERS=' accept content-type if-none-match x-request-id '
QUERY_KEY_ALLOW='limit'

check_path_query() {
  local f=$1 line=$2 path=$3 dec reason
  if [[ "$path" == *'#'* ]]; then
    hit "$f" "$line" "path must not contain a fragment (#)"
    return
  fi
  dec=$(url_decode_once "$path") || { hit "$f" "$line" "path percent-encoding is not decodable (fail closed)"; return; }
  if [[ "$dec" == *'#'* ]]; then
    hit "$f" "$line" "path must not contain a fragment (#) after one decode"
    return
  fi
  if [[ "$dec" == *'%'* ]]; then
    hit "$f" "$line" "path still contains percent-encoding after one decode"
    return
  fi
  if ! reason=$(QUERY_ALLOW="$QUERY_KEY_ALLOW" python3 - "$path" <<'PY'
import re, os, sys, urllib.parse
path = sys.argv[1]
allow = os.environ.get("QUERY_ALLOW", "limit")
for m in re.finditer(r"(?:\?|&|;)([^=;&]+)=", path):
    raw = m.group(1)
    try:
        k = urllib.parse.unquote(raw, errors="strict")
    except Exception:
        print("query key percent-encoding is not decodable (fail closed)")
        sys.exit(0)
    if "%" in k:
        print("query key still contains percent-encoding after one decode")
        sys.exit(0)
    if k.lower() != allow:
        print(f"query key '{k}' not allowed (only {allow})")
        sys.exit(0)
PY
); then
    hit "$f" "$line" "query keys do not read (fail closed)"
    return
  fi
  if [ -n "$reason" ]; then hit "$f" "$line" "$reason"; fi
}

declare -A GLOBAL_IDS=()

check_file() {
  local f=$1 h k ids='' docs top rows line tag idtag id env method path atag auth etag stag status stnum jtag htag ttag tdo jbad v
  [ -f "$f" ] || { hit "$f" 1 "no such file"; return; }
  if ! docs=$(yq -N 'document_index' "$f" 2>/dev/null); then hit "$f" 1 "parse error (yq)"; return; fi
  [ "$(grep -c . <<<"$docs")" -le 1 ] || { hit "$f" 1 "more than one YAML document"; return; }
  if ! v=$(yq -r "$KEYS" "$f" 2>/dev/null); then hit "$f" 1 "keys do not read"; return; fi
  while IFS=$'\t' read -r line k; do
    [ -n "$line" ] && hit "$f" "$line" "duplicate key '$k'"
  done <<<"$v"
  if ! v=$(yq -r "$TOKENS" "$f" 2>/dev/null); then hit "$f" 1 "token rules do not read (fail closed)"; return; fi
  while IFS=$'\t' read -r line _msg; do
    [ -n "$line" ] && hit "$f" "$line" "token-shaped value (no tokens in scenario files)"
  done <<<"$v"
  if ! v=$(yq -r "$HDRS" "$f" 2>/dev/null); then hit "$f" 1 "headers do not read"; return; fi
  while IFS=$'\t' read -r line h; do
    [ -n "$line" ] || continue
    case "$HEADERS" in *" ${h,,} "*) ;; *) hit "$f" "$line" "header '$h' not allowed (only Accept, Content-Type, If-None-Match, X-Request-Id; auth only via auth:)" ;; esac
  done <<<"$v"
  top=$(yq -r '[tag, (.scenarios | tag), (.scenarios | length)] | @tsv' "$f" 2>/dev/null)
  IFS=$'\t' read -r tag stag rows <<<"$top"
  if [ "$tag" != '!!map' ] || [ "$stag" != '!!seq' ] || [ "${rows:-0}" -eq 0 ]; then
    hit "$f" 1 "top level must be a map with a non-empty scenarios: list"; return
  fi
  if ! rows=$(yq -r "$ROWS" "$f" 2>/dev/null); then hit "$f" 1 "scenario fields do not read (bad shape)"; return; fi
  while IFS=$'\037' read -r line tag idtag id env method path atag auth etag stag status stnum jtag htag ttag tdo jbad; do
    [ -n "$line" ] || continue
    if [ "$tag" != '!!map' ]; then hit "$f" "$line" "scenario must be a map"; continue; fi
    if [ "$idtag" != '!!str' ] || [ -z "$id" ] || [ "$id" = null ] || [[ "$id" =~ [[:space:]] ]]; then
      hit "$f" "$line" "id must be a non-empty string with no whitespace"
    fi
    case "$env" in tst|acc) ;; *) hit "$f" "$line" "env '$env' not allowed (only tst or acc)" ;; esac
    [[ "$method" =~ ^[A-Za-z]+$ ]] || hit "$f" "$line" "method missing or not a word"
    check_path_query "$f" "$line" "$path"
    if [[ -n "$id" ]] && [[ -n "${GLOBAL_IDS[$id]+x}" ]]; then hit "$f" "$line" "duplicate id '$id' across files"; fi
    GLOBAL_IDS[$id]=1
    if [[ -n "$id" ]] && grep -Fxq "$id" <<<"$ids"; then hit "$f" "$line" "duplicate id '$id'"; fi
    ids="${ids}${id}"$'\n'
    if [[ ! "$path" =~ ^/ ]] || [[ "$path" =~ ^// ]] || [[ "$path" == *"\\"* ]] || [[ "$path" =~ [[:space:]] ]]; then
      hit "$f" "$line" "path '$path' must be relative: one leading /, no scheme, no host (host only from SMOKE_BASE_URL)"
    fi
    if [ "$atag" != '!!str' ] || { [ "$auth" != none ] && [ "$auth" != smoke-jwt ]; }; then
      hit "$f" "$line" "auth must be none or smoke-jwt"
    fi
    if [ "$etag" != '!!map' ]; then
      hit "$f" "$line" "expect missing"
    elif [ "$stag" != '!!int' ]; then
      hit "$f" "$line" "expect.status must be an HTTP status (100 to 599)"
    elif ! is_dec_int "$status"; then
      hit "$f" "$line" "expect.status must be a plain decimal integer"
    elif [ "$stnum" -lt 100 ] || [ "$stnum" -gt 599 ]; then
      hit "$f" "$line" "expect.status must be an HTTP status (100 to 599)"
    fi
    case "$htag" in '!!null'|'!!map') ;; *) hit "$f" "$line" "headers must be a map" ;; esac
    case "$jtag" in '!!null'|'!!seq') ;; *) jbad=1 ;; esac
    [ "$jbad" = 0 ] || hit "$f" "$line" "expect.json items need path: \$... and exactly one of equals or exists: true (boolean)"
    if [ "$method" != GET ] && [ "$method" != HEAD ]; then
      { [ "$ttag" != '!!bool' ] || [ "$tdo" != true ]; } && hit "$f" "$line" "write method '$method' needs test_data_only: true"
    fi
  done < <(tr '\t' '\037' <<<"$rows")
}

case "${1:-}" in -h|--help) echo "usage: check-smoke.sh FILE... (smoke/<feature>/scenarios.yml; rules in smoke/README.md)"; exit 0 ;; esac
[ $# -gt 0 ] || { echo "scripts/check-smoke.sh:1 SMOKE usage: check-smoke.sh FILE..."; exit 1; }
for f in "$@"; do check_file "$f"; done
[ "$N" -eq 0 ]
