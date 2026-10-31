#!/usr/bin/env bash
# SM01 smoke scenario check. Args: one or more scenarios.yml files (smoke/<feature>/scenarios.yml or fixtures).
# Prints one `file:line SMOKE message` per hit. Exit 0 ok, 1 a hit or a file that does not parse (fail closed),
# 2 needs-human (yq or python3 missing). Format: smoke/README.md, smoke/_schema.yml.
set -uo pipefail
command -v yq >/dev/null 2>&1 || { echo "scripts/check-smoke.sh:1 VERIFY needs-human missing: yq"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "scripts/check-smoke.sh:1 VERIFY needs-human missing: python3"; exit 2; }
N=0
hit() { echo "$1:$2 SMOKE $3"; N=$((N + 1)); } # FILE LINE MESSAGE

is_dec_int() { [[ "$1" =~ ^[0-9]+$ ]]; }

url_decode_once() {
  python3 -c 'import sys, urllib.parse; sys.stdout.write(urllib.parse.unquote(sys.argv[1], errors="strict"))' "$1" 2>/dev/null
}

path_has_bad_pct() {
  python3 -c 'import re, sys; sys.exit(0 if re.search(r"%(?![0-9A-Fa-f]{2})", sys.argv[1]) else 1)' "$1" 2>/dev/null
}

path_relative_violation() {
  local p=$1
  [[ "$p" =~ ^/ ]] || return 0
  [[ "$p" =~ ^// ]] && return 0
  [[ "$p" == *"\\"* ]] && return 0
  [[ "$p" =~ [[:space:]] ]] && return 0
  return 1
}

dec_ws_clean() { # after one decode: exit 0 only when the path part has no unicode whitespace (NBSP, U+2028, ...)
  # and the query has none other than a plain space; any other exit (including a python error) is a hit (fail closed)
  python3 -c 'import sys
v = sys.argv[1]
p, _, q = v.partition("?")
bad = lambda s: any(c.isspace() or c in "\u00a0\u200b\ufeff" for c in s)
sys.exit(1 if bad(p) or bad(q.replace(" ", "")) else 0)' "$1" 2>/dev/null
}

dec_path_token_hit() {
  python3 -c 'import re, sys
v = sys.argv[1]
sep = re.compile(r"[\u000b\u000c\u0085\u2028\u2029]")
pre = r"(?i)(^|[^A-Za-z0-9])(gh[pousr]_|github_pat_|glpat-|sk_live_|sk_test_|rk_live_|rk_test_|xox[abpr]-|xoxe-|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,})"
sch = r"(?i)(^|[^A-Za-z0-9])(bearer|basic)[\s\u00a0]+[A-Za-z0-9_.-]+"
tok = r"(?i)(^|[^A-Za-z0-9])token[\s\u00a0]+(?!refresh[ \t\u00a0]*$)[A-Za-z0-9_.-]+"
jwt = r"[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]{10,}"
for v2 in (sep.sub("", v), sep.sub(" ", v)):
    if re.search(pre, v2) or re.search(sch, v2) or re.search(tok, v2) or re.search(jwt, v2) or v2.startswith("eyJ"):
        sys.exit(0)
sys.exit(1)' "$1" 2>/dev/null
}

# shellcheck disable=SC2016
KEYS='.. | select(tag == "!!map") | . as $m | $m | keys | group_by(.) | .[] | select(length > 1) | .[0] | [($m | line), .] | @tsv'
# shellcheck disable=SC2016
TOKEN_MATCH='select(
  (tostring | test("(?i)(^|[^A-Za-z0-9])(gh[pousr]_|github_pat_|glpat-|sk_live_|sk_test_|rk_live_|rk_test_|xox[abpr]-|xoxe-|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,})"))
  or (tostring | sub("[\r\n]"; ""; "g") | test("(?i)(^|[^A-Za-z0-9])(gh[pousr]_|github_pat_|glpat-|sk_live_|sk_test_|rk_live_|rk_test_|xox[abpr]-|xoxe-|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,})"))
  or (tostring | test("(?i)(^|[^A-Za-z0-9])(bearer|basic)[[:space:]]+[A-Za-z0-9_.-]+"))
  or (tostring | sub("[\r\n]"; ""; "g") | test("(?i)(^|[^A-Za-z0-9])(bearer|basic)[[:space:]]+[A-Za-z0-9_.-]+"))
  or (tostring | sub("(?i)(^|[^A-Za-z0-9])token[[:space:]]+refresh[[:space:]]*$"; " "; "g") | test("(?i)(^|[^A-Za-z0-9])token[[:space:]]+[A-Za-z0-9_.-]+"))
  or (tostring | sub("[\r\n]"; ""; "g") | sub("(?i)(^|[^A-Za-z0-9])token[[:space:]]+refresh[[:space:]]*$"; " "; "g") | test("(?i)(^|[^A-Za-z0-9])token[[:space:]]+[A-Za-z0-9_.-]+"))
  or (tostring | test("[A-Za-z0-9_-]{10,}\\.[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]{10,}"))
  or (tostring | sub("[\r\n]"; ""; "g") | test("[A-Za-z0-9_-]{10,}\\.[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]{10,}"))
  or (tostring | test("^eyJ"))
  or (tostring | sub("[\r\n]"; ""; "g") | test("^eyJ"))
)'
TOKENS='.. | select(tag == "!!str" or tag == "!!int" or tag == "!!float" or tag == "!!bool") | '"$TOKEN_MATCH"' | [line, "token-shaped value (no tokens in scenario files)"] | @tsv'
# shellcheck disable=SC2016
TOKEN_KEYS='.. | select(tag == "!!map") | keys | .[] | '"$TOKEN_MATCH"' | [line, "token-shaped value (no tokens in scenario files)"] | @tsv'
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
  local f=$1 line=$2 path=$3 dec reason relmsg
  relmsg="path must be relative: one leading /, no scheme, no host (host only from SMOKE_BASE_URL)"
  if path_relative_violation "$path"; then
    hit "$f" "$line" "$relmsg"
    return
  fi
  if [[ "$path" == *'%00'* ]]; then
    hit "$f" "$line" "path must not contain a NUL byte (raw or percent-encoded %00)"
    return
  fi
  if path_has_bad_pct "$path"; then
    hit "$f" "$line" "path percent-encoding is not decodable (fail closed)"
    return
  fi
  if [[ "$path" == *'#'* ]]; then
    hit "$f" "$line" "path must not contain a fragment (#)"
    return
  fi
  # sentinel x keeps a trailing decoded newline (command substitution strips trailing newlines)
  dec=$(url_decode_once "$path" && printf x) || { hit "$f" "$line" "path percent-encoding is not decodable (fail closed)"; return; }
  dec=${dec%x}
  if path_relative_violation "${dec%%\?*}"; then
    hit "$f" "$line" "$relmsg"
    return
  fi
  if [[ "$dec" == *"\\"* ]] || ! dec_ws_clean "$dec"; then
    hit "$f" "$line" "$relmsg"
    return
  fi
  if [[ "$dec" != "$path" ]] && dec_path_token_hit "$dec"; then
    hit "$f" "$line" "token-shaped value (no tokens in scenario files)"
    return
  fi
  if [[ "$dec" == *'#'* ]]; then
    hit "$f" "$line" "path must not contain a fragment (#) after one decode"
    return
  fi
  if [[ "$dec" == *'%'* ]]; then
    hit "$f" "$line" "path still contains percent-encoding after one decode"
    return
  fi
  if ! reason=$(QUERY_ALLOW="$QUERY_KEY_ALLOW" python3 - "$dec" <<'PY'
import re, os, sys, urllib.parse
path = sys.argv[1]
allow = os.environ.get("QUERY_ALLOW", "limit")

def check_key(raw):
    try:
        k = urllib.parse.unquote(raw, errors="strict")
    except Exception:
        return "query key percent-encoding is not decodable (fail closed)"
    if "%" in k:
        return "query key still contains percent-encoding after one decode"
    if k.lower() != allow:
        return f"query key '{k}' not allowed (only {allow})"
    return None

for m in re.finditer(r"(?:\?|&|;)([^=;&]+)=", path):
    err = check_key(m.group(1))
    if err:
        print(err)
        sys.exit(0)
for m in re.finditer(r"(?:\?|&|;)([^=;&]+)(?=[;&?]|$)", path):
    err = check_key(m.group(1))
    if err:
        print(err)
        sys.exit(0)
PY
); then
    hit "$f" "$line" "query keys do not read (fail closed)"
    return
  fi
  if [ -n "$reason" ]; then hit "$f" "$line" "$reason"; fi
}

scan_unicode_token_scalars() {
  local f=$1 seen=$2 rows v
  # JSON records, not @tsv: a scalar with a newline or U+2028 stays one record
  if ! rows=$(yq -o=json -I=0 '[.. | select(tag == "!!str" or tag == "!!int" or tag == "!!float" or tag == "!!bool") | [line, (tostring)]]' "$f" 2>/dev/null); then
    hit "$f" 1 "unicode token scan do not read (fail closed)"
    return
  fi
  if ! v=$(ROWS="$rows" SEEN="$seen" python3 - <<'PY'
import json, os, re, sys
SEEN = set(os.environ.get("SEEN", "").split())
SEP = re.compile(r"[\u000b\u000c\u0085\u2028\u2029]")
PRE = re.compile(r"(?i)(^|[^A-Za-z0-9])(gh[pousr]_|github_pat_|glpat-|sk_live_|sk_test_|rk_live_|rk_test_|xox[abpr]-|xoxe-|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,})")
SCH = re.compile(r"(?i)(^|[^A-Za-z0-9])(bearer|basic)[\s\u00a0]+[A-Za-z0-9_.-]+")
TOK = re.compile(r"(?i)(^|[^A-Za-z0-9])token[\s\u00a0]+(?!refresh[ \t\u00a0]*$)[A-Za-z0-9_.-]+")
JWT = re.compile(r"[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]{10,}")

def norm(s: str) -> str:
    return SEP.sub("", s)

def hit_val(val: str) -> bool:
    # a separator inside a prefix is stripped; between a scheme and a token it counts as a space
    for v2 in (norm(val), SEP.sub(" ", val)):
        if (
            PRE.search(v2)
            or SCH.search(v2)
            or TOK.search(v2)
            or JWT.search(v2)
            or v2.startswith("eyJ")
        ):
            return True
    return False

for rec in json.loads(os.environ.get("ROWS", "") or "[]"):
    line, val = str(rec[0]), str(rec[1])
    if line in ("", "null", "None") or line in SEEN:
        continue
    # strip CR and LF first, then the same separator normalization as hit_val
    val = val.replace("\r", "").replace("\n", "")
    if not SEP.search(val) and "\u00a0" not in val:
        continue
    if hit_val(val):
        print(f"{line}\ttoken-shaped value (no tokens in scenario files)")
        break
PY
); then
    hit "$f" 1 "unicode token scan do not read (fail closed)"
    return
  fi
  while IFS=$'\t' read -r line msg; do
    [ -n "$line" ] && hit "$f" "$line" "$msg"
  done <<<"$v"
}

scan_comment_pem() {
  local f=$1 v
  if ! v=$(python3 - "$f" <<'PY'
import re, sys
path = sys.argv[1]
pem = re.compile(r"-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----")
PRE = re.compile(r"(?i)(^|[^A-Za-z0-9])(gh[pousr]_|github_pat_|glpat-|sk_live_|sk_test_|rk_live_|rk_test_|xox[abpr]-|xoxe-|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,})")
SCH = re.compile(r"(?i)(^|[^A-Za-z0-9])(bearer|basic)[ \t\u00a0]+[A-Za-z0-9_.-]+")
TOK = re.compile(r"(?i)(^|[^A-Za-z0-9])token[ \t\u00a0]+(?!refresh[ \t\u00a0]*$)[A-Za-z0-9_.-]+")
JWT = re.compile(r"[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]{10,}")

def comment_token_hit(tail: str) -> bool:
    return bool(
        PRE.search(tail)
        or SCH.search(tail)
        or TOK.search(tail)
        or JWT.search(tail)
        or tail.lstrip().startswith("eyJ")
    )

def opens_value(line: str, i: int) -> bool:
    # a quote opens a YAML string only where a value starts: line start, after `:` or `- `, or a flow start
    before = line[:i].rstrip()
    return before == "" or before[-1] in ":-[{,?"

def comment_tail(line: str) -> str:
    # full-line and indented comments count too; the tail after # is scanned with the same token rules
    in_s = in_d = False
    esc = False
    i = 0
    while i < len(line):
        c = line[i]
        if esc:
            esc = False
        elif in_s:
            if c == "\\":
                esc = True
            elif c == '"':
                in_s = False
        elif in_d:
            if c == "'":
                if line[i + 1 : i + 2] == "'":
                    i += 1  # '' is one escaped quote inside single quotes
                else:
                    in_d = False
        elif c == '"' and opens_value(line, i):
            in_s = True
        elif c == "'" and opens_value(line, i):
            in_d = True
        elif c == "#" and (i == 0 or line[i - 1] in " \t"):
            return line[i + 1 :]
        i += 1
    return ""

with open(path, encoding="utf-8") as fh:
    for n, line in enumerate(fh, 1):
        if pem.search(line):
            print(f"{n}\tPEM private key header in file")
            continue
        tail = comment_tail(line)
        if tail and comment_token_hit(tail):
            print(f"{n}\ttoken-shaped value in YAML comment tail")
PY
); then
    hit "$f" 1 "comment and PEM scan do not read (fail closed)"
    return
  fi
  while IFS=$'\t' read -r line msg; do
    [ -n "$line" ] && hit "$f" "$line" "$msg"
  done <<<"$v"
}

declare -A GLOBAL_IDS=()

check_file() {
  local f=$1 h k ids='' seen='' docs top rows line tag idtag id env method path atag auth etag stag status stnum jtag htag ttag tdo jbad v
  [ -f "$f" ] || { hit "$f" 1 "no such file"; return; }
  if ! docs=$(yq -N 'document_index' "$f" 2>/dev/null); then hit "$f" 1 "parse error (yq)"; return; fi
  [ "$(grep -c . <<<"$docs")" -le 1 ] || { hit "$f" 1 "more than one YAML document"; return; }
  if ! v=$(yq -r "$KEYS" "$f" 2>/dev/null); then hit "$f" 1 "keys do not read"; return; fi
  while IFS=$'\t' read -r line k; do
    [ -n "$line" ] && hit "$f" "$line" "duplicate key '$k'"
  done <<<"$v"
  if ! v=$(yq -r "$TOKENS" "$f" 2>/dev/null); then hit "$f" 1 "token rules do not read (fail closed)"; return; fi
  while IFS=$'\t' read -r line _msg; do
    [ -n "$line" ] && { hit "$f" "$line" "token-shaped value (no tokens in scenario files)"; seen="$seen $line"; }
  done <<<"$v"
  if ! v=$(yq -r "$TOKEN_KEYS" "$f" 2>/dev/null); then hit "$f" 1 "token rules do not read (fail closed)"; return; fi
  while IFS=$'\t' read -r line _msg; do
    [ -n "$line" ] && { hit "$f" "$line" "token-shaped value (no tokens in scenario files)"; seen="$seen $line"; }
  done <<<"$v"
  scan_unicode_token_scalars "$f" "$seen"
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
  scan_comment_pem "$f"
  if ! rows=$(yq -r "$ROWS" "$f" 2>/dev/null); then hit "$f" 1 "scenario fields do not read (bad shape)"; return; fi
  local file_ids=''
  while IFS=$'\037' read -r line tag idtag id env method path atag auth etag stag status stnum jtag htag ttag tdo jbad; do
    [ -n "$line" ] || continue
    if [ "$tag" != '!!map' ]; then hit "$f" "$line" "scenario must be a map"; continue; fi
    if [ "$idtag" != '!!str' ] || [ -z "$id" ] || [ "$id" = null ] || [[ "$id" =~ [[:space:]] ]]; then
      hit "$f" "$line" "id must be a non-empty string with no whitespace"
    fi
    case "$env" in tst|acc) ;; *) hit "$f" "$line" "env '$env' not allowed (only tst or acc)" ;; esac
    [[ "$method" =~ ^[A-Za-z]+$ ]] || hit "$f" "$line" "method missing or not a word"
    check_path_query "$f" "$line" "$path"
    if [[ -n "$id" ]] && grep -Fxq "$id" <<<"$ids"; then hit "$f" "$line" "duplicate id '$id'"; fi
    ids="${ids}${id}"$'\n'
    if [[ -n "$id" ]] && [[ -n "${GLOBAL_IDS[$id]+x}" ]]; then hit "$f" "$line" "duplicate id '$id' across files"; fi
    if [[ -n "$id" ]] && ! grep -Fxq "$id" <<<"$file_ids"; then file_ids="${file_ids}${id}"$'\n'; fi
    if [ "$atag" != '!!str' ] || { [ "$auth" != none ] && [ "$auth" != smoke-jwt ]; }; then
      hit "$f" "$line" "auth must be none or smoke-jwt"
    fi
    if [ "$etag" != '!!map' ]; then
      hit "$f" "$line" "expect missing"
    elif [ "$stag" != '!!int' ]; then
      hit "$f" "$line" "expect.status must be an HTTP status (100 to 599)"
    elif ! is_dec_int "$status"; then
      hit "$f" "$line" "expect.status must be a plain decimal integer"
    elif [[ "$status" =~ ^0[0-9]+$ ]]; then
      hit "$f" "$line" "expect.status must be a plain decimal integer without a leading zero"
    elif ! { [ "$stnum" -ge 100 ] 2>/dev/null && [ "$stnum" -le 599 ] 2>/dev/null; }; then
      hit "$f" "$line" "expect.status must be an HTTP status (100 to 599)"
    fi
    case "$htag" in '!!null'|'!!map') ;; *) hit "$f" "$line" "headers must be a map" ;; esac
    case "$jtag" in '!!null'|'!!seq') ;; *) jbad=1 ;; esac
    [ "$jbad" = 0 ] || hit "$f" "$line" "expect.json items need path: \$... and exactly one of equals or exists: true (boolean)"
    if [ "$method" != GET ] && [ "$method" != HEAD ]; then
      { [ "$ttag" != '!!bool' ] || [ "$tdo" != true ]; } && hit "$f" "$line" "write method '$method' needs test_data_only: true"
    fi
  done < <(tr '\t' '\037' <<<"$rows")
  while IFS= read -r id; do
    [ -n "$id" ] && GLOBAL_IDS[$id]=1
  done <<<"$file_ids"
}

case "${1:-}" in -h|--help) echo "usage: check-smoke.sh FILE... (smoke/<feature>/scenarios.yml; rules in smoke/README.md)"; exit 0 ;; esac
[ $# -gt 0 ] || { echo "scripts/check-smoke.sh:1 SMOKE usage: check-smoke.sh FILE..."; exit 1; }
for f in "$@"; do check_file "$f"; done
[ "$N" -eq 0 ]
