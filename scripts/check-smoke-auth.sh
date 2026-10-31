#!/usr/bin/env bash
# SM04 smoke auth check: parse, triggers, OIDC environment rule, token hygiene. Args: workflow files.
# Prints one `file:line SMOKEAUTH message` per hit. Exit 0 ok, 1 a hit (fail closed), 2 needs-human (yq missing).
# Rules, per file (stop at the first hit):
#   1 parse: top level is a map; anchor or alias is a hit; duplicate key within any map is a hit (per map node)
#   2 forbidden input and workflow_call secret names, case insensitive: client_secret, clientSecret, client-secret, password
#   3 banned values in every parsed string (multiline too): secret-shaped names, grant_type=password, AZURE_USERNAME,
#     party.* anywhere, Write, ReadWrite or Admin role requests in any case
#   4 triggers through on_triggers (allowlist workflow_dispatch, workflow_call)
#   5 jobs non-empty map; permissions shape; id-token value must be exactly the string write when the key is present
#   6 OIDC environment on each job that can mint id-token: write
#   7 token hygiene on each minting job: every azure/login step pinned @v2 with vars.* ids and no secrets.* in with:;
#     every az account get-access-token is VAR=$(...) with --scope "$SMOKE_API_SCOPE", each VAR masked before any read;
#     no print or substring read of a token, per command on the line; no shell trace (run, shell:, defaults);
#     no ACTIONS_STEP_DEBUG or ACTIONS_RUNNER_DEBUG true, 1, $true (any case) or an expression; later steps never print
#     SMOKE_TOKEN or exported token names, dump env, printenv, or cat GITHUB_ENV; yq read errors are hits
set -uo pipefail
case "${1:-}" in -h|--help) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac
command -v yq >/dev/null 2>&1 || { echo "scripts/check-smoke-auth.sh:1 VERIFY needs-human missing: yq"; exit 2; }
# shellcheck source=lib/on-triggers.sh
. "$(dirname "$0")/lib/on-triggers.sh"
N=0
# shellcheck disable=SC2016 # literal GitHub expressions
WANT='smoke-${{ inputs.env }}'
# shellcheck disable=SC2016 # literal GitHub expressions
WANT_CID='${{ vars.AZURE_CLIENT_ID }}'
# shellcheck disable=SC2016
WANT_TID='${{ vars.AZURE_TENANT_ID }}'
hit() { echo "$1:$2 SMOKEAUTH $3"; N=$((N + 1)); } # FILE LINE MESSAGE

# Duplicate keys within one map (not across sibling maps on the same line)
# shellcheck disable=SC2016
DUPKEYS='.. | select(tag == "!!map") | . as $m | ($m | keys | group_by(.) | .[] | select(length > 1) | .[0]) as $k | select($k != null) | [($m | line), $k] | @tsv'
ANCHORS='.. | select(anchor != "" or kind == "alias") | line'
PSHAPE='(tag == "!!map" or (tag == "!!str" and (. == "read-all" or . == "write-all")))'
MINTS='((tag == "!!str" and . == "write-all") or (tag == "!!map" and .["id-token"] == "write"))'
# shellcheck disable=SC2016
BAD_IDTOKEN='.. | select(tag == "!!map" and has("id-token")) | .["id-token"] | select(tag != "!!str" or . != "write") | [line, tag] | @tsv'
# Every string node, value base64 so tabs and newlines survive the row split
ALL_STR='.. | select(tag == "!!str") | [line, @base64] | @tsv'
NAME_RE='[A-Za-z_][A-Za-z0-9_]*'
# shellcheck disable=SC2016
LOGIN_SEL='select((.uses // "") | test("(?i)^[[:space:]]*azure/login([@[:space:]]|$)"))'

role_banned() { # VALUE: prints a message when the value requests a banned role
  local v=$1
  if grep -qF 'party.*' <<<"$v"; then echo "party.* role not allowed"; return 0; fi
  if grep -qiE '(^|[^A-Za-z0-9_])([A-Za-z0-9_.]*\.(write|readwrite)|[A-Za-z0-9_]*readwrite)([^A-Za-z0-9_]|$)' <<<"$v"; then
    echo "Write role must not be requested in smoke auth"; return 0
  fi
  if grep -qiE '(^|[^A-Za-z0-9_])[A-Za-z0-9_.]*\.admin([^A-Za-z0-9_]|$)' <<<"$v"; then
    echo "Admin role must not be requested in smoke auth"; return 0
  fi
  return 1
}

scalar_value_banned() {
  local f=$1 line=$2 v=$3 m
  [ -n "$line" ] || line=1
  v="$v"$'\n'"${v//\\[ntr]/ }" # also scan with \t, \n, \r escapes read as separators
  if grep -qE '(^|[^A-Za-z0-9_])(client_secret|clientSecret|client-secret|password)([^A-Za-z0-9_]|$)' <<<"$v"; then
    hit "$f" "$line" "forbidden secret-shaped name in a workflow value"; return 0
  fi
  if grep -qF 'grant_type=password' <<<"$v"; then hit "$f" "$line" "ROPC grant_type=password not allowed"; return 0; fi
  if grep -qF 'AZURE_USERNAME' <<<"$v"; then hit "$f" "$line" "AZURE_USERNAME not allowed"; return 0; fi
  if m=$(role_banned "$v"); then hit "$f" "$line" "$m"; return 0; fi
  return 1
}

forbidden_name() { # KEY: client_secret, clientSecret, client-secret, password in any case or separator
  case $(tr '[:upper:]' '[:lower:]' <<<"$1" | tr -d '_-') in clientsecret|password) return 0 ;; esac
  return 1
}

check_forbidden_inputs() {
  local f=$1 key line keys ontag
  line=$(yq '.on | line' "$f" 2>/dev/null) || line=1
  ontag=$(yq '.on | tag' "$f" 2>/dev/null) || { hit "$f" "$line" "workflow inputs do not read"; return 1; }
  [ "$ontag" = '!!map' ] || return 0
  if ! keys=$(yq -r '[(.on.workflow_call.inputs // {} | keys | .[]), (.on.workflow_dispatch.inputs // {} | keys | .[])] | .[]' "$f" 2>/dev/null); then
    hit "$f" "$line" "workflow inputs do not read"; return 1
  fi
  while IFS= read -r key; do
    [ -n "$key" ] || continue
    forbidden_name "$key" && { hit "$f" "$line" "forbidden workflow input '$key'"; return 1; }
  done <<<"$keys"
  if ! keys=$(yq -r '.on.workflow_call.secrets // {} | keys | .[]' "$f" 2>/dev/null); then
    hit "$f" "$line" "workflow_call secrets do not read"; return 1
  fi
  while IFS= read -r key; do
    [ -n "$key" ] || continue
    forbidden_name "$key" && { hit "$f" "$line" "forbidden workflow_call secret '$key'"; return 1; }
  done <<<"$keys"
  return 0
}

check_banned_scalars() {
  local f=$1 rows line b64 v
  if ! rows=$(yq -r "$ALL_STR" "$f" 2>/dev/null); then hit "$f" 1 "scalars do not read"; return 1; fi
  while IFS=$'\t' read -r line b64; do
    [ -n "$line" ] || continue
    v=$(base64 -d <<<"$b64" 2>/dev/null) || { hit "$f" "$line" "scalar does not decode"; return 1; }
    scalar_value_banned "$f" "$line" "$v" && return 1
  done <<<"$rows"
  return 0
}

check_id_token_case() {
  local f=$1 line val
  if ! val=$(yq -r "$BAD_IDTOKEN" "$f" 2>/dev/null); then hit "$f" 1 "id-token permission values do not read"; return 1; fi
  while IFS=$'\t' read -r line val; do
    [ -n "$line" ] && { hit "$f" "$line" "id-token permission must be the string write (got ${val#!!})"; return 1; }
  done <<<"$val"
  return 0
}

debug_env_true() { # VALUE: true, 1 or $true in any case, or any expression (fail closed)
  local v
  # shellcheck disable=SC2016 # literal GitHub expression and PowerShell $true
  case $1 in *'${{'*) return 0 ;; esac
  v=$(tr '[:upper:]' '[:lower:]' <<<"$1" | tr -d "\"' ")
  # shellcheck disable=SC2016
  [ "$v" = true ] || [ "$v" = 1 ] || [ "$v" = '$true' ]
}

env_debug_hit() { # FILE LINE WHERE YQ_PATH: env must be a map or absent; debug keys must be off
  local f=$1 line=$2 where=$3 p=$4 t k v
  t=$(J=${J:-} SL=${SL:-} yq "$p | tag" "$f" 2>/dev/null) || { hit "$f" "$line" "$where env does not read"; return 0; }
  [ "$t" = '!!null' ] && return 1
  [ "$t" = '!!map' ] || { hit "$f" "$line" "$where env must be a map (got ${t#!!})"; return 0; }
  for k in ACTIONS_STEP_DEBUG ACTIONS_RUNNER_DEBUG; do
    v=$(J=${J:-} SL=${SL:-} K=$k yq -r "$p | .[strenv(K)] // \"\"" "$f" 2>/dev/null) || { hit "$f" "$line" "$where env does not read"; return 0; }
    if [ -n "$v" ] && debug_env_true "$v"; then hit "$f" "$line" "$where must not set $k"; return 0; fi
  done
  return 1
}

shell_has_xtrace() {
  grep -qE '(^|[[:space:]])-[A-Za-z]*x[A-Za-z]*([[:space:]]|$)|xtrace' <<<"$1"
}

run_has_debug_trace() {
  grep -qE '(^|[[:space:]])set[[:space:]]+-[a-zA-Z]*x([[:space:]]|;|$|[&|])' <<<"$1" \
    || grep -qE 'xtrace' <<<"$1" \
    || grep -qE '(^|[[:space:]])(ba)?sh[[:space:]]+(-[A-Za-z]+[[:space:]]+)*-[A-Za-z]*x' <<<"$1"
}

# One shell command per output row as LINENO<TAB>COMMAND, split on ; && || | & (fail closed: no quote awareness)
split_cmds() {
  local n=0 line
  while IFS= read -r line; do
    n=$((n + 1))
    sed -E 's/(&&|\|\||;|\||&)/\n/g' <<<"$line" | while IFS= read -r c; do printf '%s\t%s\n' "$n" "$c"; done
  done <<<"$1"
}

reads_var() { grep -qE "\\\$${2}([^A-Za-z0-9_]|\$)|\\\$\\{[#!]?${2}([^A-Za-z0-9_]|\$)" <<<"$1"; }
partial_read() { grep -qE "\\\$\\{${2}[:#%/^,@\\[]" <<<"$1"; }
prints_cmd() { grep -qE '(^|[[:space:]])(echo|printf|cat|tee|curl|wget|printenv)([[:space:]]|$)' <<<"$1"; }

# Token step scan. Prints `LINE<TAB>MESSAGE` for the first problem, or `EXPORT<TAB>NAME` rows for GITHUB_ENV exports.
scan_token_run() {
  local run=$1 n c v name scope hasmask=0
  local -A cap=() masked=() capln=() premask=()
  local -a order=()
  while IFS=$'\t' read -r n c; do
    [[ $c =~ ^[[:space:]]*$ || $c =~ ^[[:space:]]*# ]] && continue
    if [[ $c =~ get-access-token ]]; then
      if ! [[ $c =~ ^[[:space:]]*($NAME_RE)=\$\(az[[:space:]]+account[[:space:]]+get-access-token([[:space:]]|\)|$) ]]; then
        printf '%s\t%s\n' "$n" "az account get-access-token must assign stdout to a shell variable (VAR=\$(az ...))"; return
      fi
      v=${BASH_REMATCH[1]}
      scope=$(sed -E 's/[[:space:]]#.*$//' <<<"$c")
      # shellcheck disable=SC2016
      if [ "$(grep -oE -- '--scope' <<<"$scope" | wc -l)" -ne 1 ] || grep -qE -- '--resource([[:space:]=]|$)' <<<"$scope" \
        || ! grep -qE -- '--scope[[:space:]]+("\$\{?SMOKE_API_SCOPE\}?"|\$\{?SMOKE_API_SCOPE\}?|"\$\{\{[[:space:]]*(env|vars)\.SMOKE_API_SCOPE[[:space:]]*\}\}")([[:space:]]|\)|$)' <<<"$scope"; then
        printf '%s\t%s\n' "$n" "token capture must pass --scope \"\$SMOKE_API_SCOPE\" on the assignment"; return
      fi
      [ -n "${premask[$v]:-}" ] && { printf '%s\t%s\n' "$n" "::add-mask:: must run after the token is captured"; return; }
      [ -n "${cap[$v]:-}" ] || order+=("$v")
      cap[$v]=1; capln[$v]=$n; unset 'masked[$v]'
      continue
    fi
    if [[ $c =~ ^[[:space:]]*echo[[:space:]]+\"::add-mask::\$\{?($NAME_RE)\}?\"[[:space:]]*$ ]] \
      || [[ $c =~ ^[[:space:]]*echo[[:space:]]+::add-mask::\$\{?($NAME_RE)\}?[[:space:]]*$ ]]; then
      v=${BASH_REMATCH[1]}; hasmask=1
      if [ -z "${cap[$v]:-}" ]; then premask[$v]=1; continue; fi
      [ "${capln[$v]}" = "$n" ] && { printf '%s\t%s\n' "$n" "::add-mask:: must run after the token is captured (own line)"; return; }
      masked[$v]=1; continue
    fi
    [[ $c =~ add-mask ]] && hasmask=1
    for v in "${order[@]}"; do
      reads_var "$c" "$v" || continue
      if [ -z "${masked[$v]:-}" ]; then printf '%s\t%s\n' "$n" "token used before ::add-mask::"; return; fi
      if partial_read "$c" "$v"; then printf '%s\t%s\n' "$n" "token substring read (add-mask redacts only the full value)"; return; fi
      if [[ $c =~ ^[[:space:]]*echo[[:space:]]+\"?($NAME_RE)=\$\{?$v\}?\"?[[:space:]]*\>\>[[:space:]]*\"?\$\{?GITHUB_ENV\}?\"?[[:space:]]*$ ]]; then
        name=${BASH_REMATCH[1]}; printf 'EXPORT\t%s\n' "$name"; continue
      fi
      if prints_cmd "$c"; then printf '%s\t%s\n' "$n" "token must not be echoed or printed"; return; fi
    done
  done < <(split_cmds "$run")
  [ "${#order[@]}" -gt 0 ] || { printf '1\t%s\n' "token step must capture az account get-access-token into a shell variable"; return; }
  for v in "${order[@]}"; do
    [ -n "${masked[$v]:-}" ] && continue
    if [ "$hasmask" -eq 1 ]; then printf '%s\t%s\n' "${capln[$v]}" "::add-mask:: must mask the captured token variable $v"
    else printf '%s\t%s\n' "${capln[$v]}" "token must be masked with ::add-mask:: before any other use"; fi
    return
  done
}

later_step_leak() { # RUN NAMES...: prints a message for the first leak of an exported token in a later step
  local run=$1 n c x; shift
  while IFS=$'\t' read -r n c; do
    [[ $c =~ ^[[:space:]]*$ || $c =~ ^[[:space:]]*# ]] && continue
    if grep -qE '^[[:space:]]*(env|printenv|export[[:space:]]+-p|declare[[:space:]]+-[px]|set)([[:space:]]+-[A-Za-z0-9]+)*[[:space:]]*(>.*)?$' <<<"$c" \
      || grep -qE '(^|[[:space:]])printenv([[:space:]]|$)' <<<"$c"; then
      echo "smoke job must not dump the environment after the token step"; return 0
    fi
    if grep -qE '(^|[[:space:]])(cat|less|more|head|tail|cp|base64)[[:space:]].*\$\{?GITHUB_ENV' <<<"$c" || grep -qF '/environ' <<<"$c"; then
      echo "smoke job must not print the GITHUB_ENV file or process environ"; return 0
    fi
    for x in "$@"; do
      reads_var "$c" "$x" || continue
      if partial_read "$c" "$x" || grep -qE '(^|[[:space:]])(echo|printf|cat|tee)([[:space:]]|$)' <<<"$c"; then
        echo "smoke job must not print or write $x after the token step"; return 0
      fi
    done
  done < <(split_cmds "$run")
  return 1
}

step_q() { J=$1 SL=$2 yq -r ".jobs[strenv(J)].steps[]? | select(line == (env(SL) | tonumber)) | $3" "$4" 2>/dev/null; }

check_logins() {
  local f=$1 job=$2 jl=$3 lines ll uses wt cid tid allow sub sk
  lines=$(J=$job yq ".jobs[strenv(J)].steps[]? | $LOGIN_SEL | line" "$f" 2>/dev/null) || { hit "$f" "$jl" "job $job steps do not read"; return; }
  if [ -z "$lines" ]; then hit "$f" "$jl" "job $job can mint an OIDC token but has no azure/login step"; return; fi
  while IFS= read -r ll; do
    [ -n "$ll" ] || continue
    uses=$(step_q "$job" "$ll" '.uses' "$f")
    if [ "$uses" != 'azure/login@v2' ]; then hit "$f" "$ll" "azure/login must be pinned to azure/login@v2"; return; fi
    wt=$(step_q "$job" "$ll" '.with | tag' "$f")
    if [ "$wt" != '!!map' ]; then hit "$f" "$ll" "azure/login with: must be a map"; return; fi
    cid=$(step_q "$job" "$ll" '.with["client-id"] // ""' "$f")
    tid=$(step_q "$job" "$ll" '.with["tenant-id"] // ""' "$f")
    allow=$(step_q "$job" "$ll" '.with["allow-no-subscriptions"] // ""' "$f")
    sub=$(step_q "$job" "$ll" '.with["subscription-id"] // ""' "$f")
    if [ "$cid" != "$WANT_CID" ]; then hit "$f" "$ll" "azure/login client-id must be $WANT_CID"; return; fi
    if [ "$tid" != "$WANT_TID" ]; then hit "$f" "$ll" "azure/login tenant-id must be $WANT_TID"; return; fi
    if [ "$allow" != true ]; then hit "$f" "$ll" "azure/login must set allow-no-subscriptions: true"; return; fi
    if grep -q 'secrets\.' <<<"$sub"; then hit "$f" "$ll" "azure/login must not use subscription-id from secrets"; return; fi
    if ! sk=$(step_q "$job" "$ll" '.with | to_entries | .[] | select((.value | tostring) | test("secrets\.")) | .key' "$f"); then
      hit "$f" "$ll" "azure/login with: does not read"; return
    fi
    if [ -n "$sk" ]; then hit "$f" "$ll" "azure/login must not take secrets.* in with: ($(head -n1 <<<"$sk"))"; return; fi
  done <<<"$lines"
}

check_token_run_step() {
  local f=$1 sl=$2 run=$3 out first ln msg m
  if grep -qF 'grant_type=password' <<<"$run"; then hit "$f" "$sl" "ROPC grant_type=password not allowed"; return; fi
  if grep -qF 'AZURE_USERNAME' <<<"$run"; then hit "$f" "$sl" "AZURE_USERNAME not allowed"; return; fi
  if m=$(role_banned "$run"); then hit "$f" "$sl" "$m"; return; fi
  out=$(scan_token_run "$run")
  first=$(grep -v '^EXPORT' <<<"$out" | head -n1)
  [ -n "$first" ] || return
  IFS=$'\t' read -r ln msg <<<"$first"
  hit "$f" "$sl" "$msg (run line $ln)"
}

check_mint_job_steps() {
  local f=$1 job=$2 jl=$3
  local wfl sl run sh got_token=0 names=(SMOKE_TOKEN) m x
  wfl=$(yq '.env | line' "$f" 2>/dev/null) || wfl=1
  [ "$wfl" -gt 0 ] 2>/dev/null || wfl=1
  env_debug_hit "$f" "$wfl" "workflow" '.env' && return
  J=$job env_debug_hit "$f" "$jl" "job $job" '.jobs[strenv(J)].env' && return
  sh=$(yq -r '.defaults.run.shell // ""' "$f" 2>/dev/null)
  if shell_has_xtrace "$sh"; then hit "$f" "$wfl" "workflow defaults.run.shell must not enable debug trace"; return; fi
  sh=$(J=$job yq -r '.jobs[strenv(J)].defaults.run.shell // ""' "$f" 2>/dev/null)
  if shell_has_xtrace "$sh"; then hit "$f" "$jl" "job $job defaults.run.shell must not enable debug trace"; return; fi
  check_logins "$f" "$job" "$jl"; [ "$N" -eq 0 ] || return
  while IFS= read -r sl; do
    [ -n "$sl" ] || continue
    J=$job SL=$sl env_debug_hit "$f" "$sl" "step" '.jobs[strenv(J)].steps[]? | select(line == (env(SL) | tonumber)) | .env' && return
    sh=$(step_q "$job" "$sl" '.shell // ""' "$f")
    if shell_has_xtrace "$sh"; then hit "$f" "$sl" "step must not enable shell debug trace (shell: -x or xtrace)"; return; fi
    run=$(step_q "$job" "$sl" '.run // ""' "$f")
    if run_has_debug_trace "$run"; then hit "$f" "$sl" "step must not enable shell debug trace (set -x)"; return; fi
    if grep -q 'get-access-token' <<<"$run"; then
      got_token=1
      check_token_run_step "$f" "$sl" "$run"; [ "$N" -eq 0 ] || return
      while IFS=$'\t' read -r x m; do [ "$x" = EXPORT ] && names+=("$m"); done < <(scan_token_run "$run")
      continue
    fi
    if [ "$got_token" -eq 1 ] && m=$(later_step_leak "$run" "${names[@]}"); then hit "$f" "$sl" "$m"; return; fi
  done < <(J=$job yq '.jobs[strenv(J)].steps[]? | line' "$f" 2>/dev/null)
  [ "$got_token" -eq 1 ] || hit "$f" "$jl" "job $job must capture token with az account get-access-token --scope \"\$SMOKE_API_SCOPE\""
}

check_file() {
  local f=$1 rc t names=() top job jl wf m env etag v line k envok
  if ! top=$(yq -p yaml '. | tag' "$f" 2>/dev/null) || [ "$top" != '!!map' ]; then
    hit "$f" 1 "file does not parse as a YAML map"; return
  fi
  v=$(yq "$ANCHORS" "$f" 2>/dev/null) || { hit "$f" 1 "anchors do not read"; return; }
  if [ -n "$v" ]; then hit "$f" "$(head -n1 <<<"$v")" "anchor or alias not allowed (permissions could hide behind it)"; return; fi
  v=$(yq -r "$DUPKEYS" "$f" 2>/dev/null) || { hit "$f" 1 "keys do not read"; return; }
  while IFS=$'\t' read -r line k; do
    [ -n "$line" ] && { hit "$f" "$line" "duplicate key '$k' (yq keeps only the last one)"; return; }
  done <<<"$v"
  check_forbidden_inputs "$f" && check_banned_scalars "$f" || return
  t=$(on_triggers "$f"); rc=$?
  case $rc in
    0) mapfile -t names < <(grep -vxE 'roles|skip-bots|skip-roles' <<<"$t")
       [ "${#names[@]}" -gt 0 ] || hit "$f" "$(on_line "$f")" "on: has no trigger after dropping roles, skip-bots, skip-roles"
       for t in "${names[@]}"; do
         case $t in workflow_dispatch|workflow_call) ;; *) hit "$f" "$(on_line "$f")" "trigger $t is not allowed (only workflow_dispatch, workflow_call)" ;; esac
       done ;;
    3) hit "$f" 1 "no on: key (not a workflow)" ;;
    *) hit "$f" "$(on_line "$f")" "on: does not parse or has a bad shape" ;;
  esac
  [ "$N" -eq 0 ] || return
  if [ "$(yq '.jobs | tag' "$f")" != '!!map' ] || [ "$(yq '.jobs | length' "$f")" -eq 0 ]; then
    hit "$f" 1 "jobs: is missing, empty or not a map"; return
  fi
  check_id_token_case "$f" || return
  if [ "$(yq 'has("permissions")' "$f")" = true ] && [ "$(yq ".permissions | $PSHAPE" "$f")" != true ]; then
    hit "$f" "$(yq '.permissions | key | line' "$f")" "workflow permissions is $(yq '.permissions | tag' "$f") (want a map, read-all or write-all)"
  fi
  [ "$N" -eq 0 ] || return
  wf=$(yq ".permissions | $MINTS" "$f")
  while IFS= read -r job; do
    jl=$(J=$job yq '.jobs[strenv(J)] | line' "$f")
    if [ "$(J=$job yq '.jobs[strenv(J)] | tag' "$f")" != '!!map' ]; then
      hit "$f" "$jl" "job $job is not a map"; continue
    fi
    if [ "$(J=$job yq '.jobs[strenv(J)] | has("permissions")' "$f")" = true ]; then
      if [ "$(J=$job yq ".jobs[strenv(J)].permissions | $PSHAPE" "$f")" != true ]; then
        hit "$f" "$jl" "job $job permissions is $(J=$job yq '.jobs[strenv(J)].permissions | tag' "$f") (want a map, read-all or write-all; an empty permissions: is a hit)"; continue
      fi
      m=$(J=$job yq ".jobs[strenv(J)].permissions | $MINTS" "$f")
    else m=$wf; fi
    [ "$m" = true ] || continue
    etag=$(J=$job yq '.jobs[strenv(J)].environment | tag' "$f")
    env=$(J=$job yq '.jobs[strenv(J)].environment' "$f")
    envok=1
    if [ "$etag" != '!!str' ]; then
      hit "$f" "$jl" "job $job can mint an OIDC token but environment is ${etag#!!} (want the string $WANT)"; envok=0
    elif [ "$env" != "$WANT" ]; then
      hit "$f" "$jl" "job $job can mint an OIDC token but environment is '$env' (want $WANT)"; envok=0
    fi
    [ "$envok" -eq 1 ] && check_mint_job_steps "$f" "$job" "$jl"
  done < <(yq '.jobs | keys | .[]' "$f")
}

[ $# -gt 0 ] || { echo "scripts/check-smoke-auth.sh:1 SMOKEAUTH usage: check-smoke-auth.sh FILE..."; exit 1; }
for f in "$@"; do check_file "$f"; done
[ "$N" -eq 0 ]
