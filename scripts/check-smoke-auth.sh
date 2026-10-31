#!/usr/bin/env bash
# SM04 smoke auth check: parse, triggers, OIDC environment rule, token hygiene. Args: workflow files.
# Prints one `file:line SMOKEAUTH message` per hit. Exit 0 ok, 1 a hit (fail closed), 2 needs-human (yq missing).
# Rules, per file (stop at first hit in each phase where noted):
#   1 parse: top level is a map; anchor or alias is a hit; duplicate key within any map is a hit (per map node)
#   2 forbidden workflow inputs: client_secret, clientSecret, client-secret, password
#   3 banned scalar values: grant_type=password, AZURE_USERNAME, party.* role, Write or Admin role requests
#   4 triggers through on_triggers (allowlist workflow_dispatch, workflow_call)
#   5 jobs non-empty map; permissions shape; id-token permission value must be exactly write when present
#   6 OIDC environment on each job that can mint id-token: write
#   7 token hygiene on each minting job that passes 6: azure/login@v2, every get-access-token step masked on its var,
#     no token reads before mask (echo, printf, curl, same line as capture or mask), shell debug trace on any step,
#     no ACTIONS_STEP_DEBUG true or 1 at workflow, job, or step; yq read errors on inputs, scalars, or id-token are hits
set -uo pipefail
case "${1:-}" in -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac
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
BAD_IDTOKEN='.. | select(tag == "!!map" and has("id-token")) | .["id-token"] | select(tag == "!!str" and . != "write") | [line, .] | @tsv'
# shellcheck disable=SC2016
SCALARS='.. | select(tag == "!!str") | select(. | contains("\n") | not) | [line, .] | @tsv'
# shellcheck disable=SC2016
STEP_RUNS='.jobs[]?.steps[]? | select(.run) | [line, .run] | @json'
# shellcheck disable=SC2016
STEP_ENVS='.jobs[]?.steps[]? | select(.env) | . as $s | $s.env | to_entries | [.[] | [($s | line), .value]] | .[] | @json'

scalar_value_banned() {
  local f=$1 line=$2 v=$3
  [ -n "$line" ] || return 1
  if grep -qE '(^|[^A-Za-z0-9_])(client_secret|clientSecret|client-secret|password)([^A-Za-z0-9_]|$)' <<<"$v"; then
    hit "$f" "$line" "forbidden secret-shaped name in a workflow value"; return 0
  fi
  if grep -qF 'grant_type=password' <<<"$v"; then hit "$f" "$line" "ROPC grant_type=password not allowed"; return 0; fi
  if grep -qF 'AZURE_USERNAME' <<<"$v"; then hit "$f" "$line" "AZURE_USERNAME not allowed"; return 0; fi
  if [ "$v" = 'party.*' ]; then hit "$f" "$line" "party.* role not allowed"; return 0; fi
  if grep -qE '(^|[^A-Za-z0-9_])([A-Za-z0-9_.]*\.Write|API\.Write)([^A-Za-z0-9_]|$)' <<<"$v"; then
    hit "$f" "$line" "Write role must not be requested in smoke auth"; return 0
  fi
  if grep -qE '(^|[^A-Za-z0-9_])([A-Za-z0-9_.]*\.Admin|API\.Admin)([^A-Za-z0-9_]|$)' <<<"$v"; then
    hit "$f" "$line" "Admin role must not be requested in smoke auth"; return 0
  fi
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
    case $key in
      client_secret|clientSecret|client-secret|password) hit "$f" "$line" "forbidden workflow input '$key'"; return 1 ;;
    esac
  done <<<"$keys"
  return 0
}

check_banned_scalars() {
  local f=$1 line v row el
  if ! v=$(yq -r "$SCALARS" "$f" 2>/dev/null); then hit "$f" 1 "scalars do not read"; return 1; fi
  while IFS=$'\t' read -r line v; do
    scalar_value_banned "$f" "$line" "$v" && return 1
  done <<<"$v"
  if ! v=$(yq -r "$STEP_RUNS" "$f" 2>/dev/null); then hit "$f" 1 "step run scalars do not read"; return 1; fi
  while IFS= read -r row; do
    [ -n "$row" ] || continue
    line=$(<<<"$row" yq -r '.[0]')
    el=$(<<<"$row" yq -r '.[1]')
    scalar_value_banned "$f" "$line" "$el" && return 1
  done <<<"$v"
  if ! v=$(yq -r "$STEP_ENVS" "$f" 2>/dev/null); then hit "$f" 1 "step env scalars do not read"; return 1; fi
  while IFS= read -r row; do
    [ -n "$row" ] || continue
    line=$(<<<"$row" yq -r '.[0]')
    el=$(<<<"$row" yq -r '.[1]')
    scalar_value_banned "$f" "$line" "$el" && return 1
  done <<<"$v"
  return 0
}

check_id_token_case() {
  local f=$1 line val
  if ! val=$(yq -r "$BAD_IDTOKEN" "$f" 2>/dev/null); then hit "$f" 1 "id-token permission values do not read"; return 1; fi
  while IFS=$'\t' read -r line val; do
    [ -n "$line" ] && { hit "$f" "$line" "id-token permission must be lowercase write (got '$val')"; return 1; }
  done <<<"$val"
  return 0
}

debug_env_true() {
  [ "$1" = true ] || [ "$1" = 'true' ] || [ "$1" = 1 ] || [ "$1" = '1' ]
}

token_var_from_run() {
  grep -E '^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*=\$\(az account get-access-token' <<<"$1" | head -n1 | sed -E 's/^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=.*/\1/'
}

run_masks_var() {
  local run=$1 var=$2
  grep -qF "::add-mask::\$${var}" <<<"$run" || grep -qF "::add-mask::\${${var}}" <<<"$run"
}

run_has_debug_trace() {
  grep -qE '(^|[[:space:]])set[[:space:]]+-[a-zA-Z]*x([[:space:]]|;|$|[&|])' <<<"$1" \
    || grep -qE '(^|[[:space:]])set[[:space:]]+-o[[:space:]]+xtrace' <<<"$1"
}

run_leaks_token_var() {
  local run=$1 var=$2 line
  while IFS= read -r line; do
    [[ $line =~ ^[[:space:]]*${var}=\$\(az[[:space:]]account[[:space:]]get-access-token ]] && continue
    [[ $line =~ add-mask ]] && continue
    [[ $line =~ GITHUB_ENV ]] && continue
    if [[ $line =~ (\$\{${var}\}|\$${var}([^A-Za-z0-9_]|$)) ]]; then
      if [[ $line =~ (^|[[:space:]])(echo|printf|cat|tee|curl|wget)[[:space:]] ]]; then
        return 0
      fi
    fi
  done <<<"$run"
  return 1
}

run_capture_mask_same_line() {
  local run=$1 var=$2 line
  while IFS= read -r line; do
    [[ $line =~ ^[[:space:]]*${var}=\$\(az[[:space:]]account[[:space:]]get-access-token ]] \
      && [[ $line =~ add-mask ]] && return 0
  done <<<"$run"
  return 1
}

run_uses_var_before_mask() {
  local run=$1 var=$2 tokln maskln n line
  tokln=$(grep -nF "${var}=\$(az account get-access-token" <<<"$run" | head -n1 | cut -d: -f1)
  maskln=$(grep -nF "::add-mask::\$${var}" <<<"$run" | head -n1 | cut -d: -f1)
  [ -z "$maskln" ] && maskln=$(grep -nF "::add-mask::\${${var}}" <<<"$run" | head -n1 | cut -d: -f1)
  [ -z "$tokln" ] || [ -z "$maskln" ] && return 1
  n=0
  while IFS= read -r line; do
    n=$((n + 1))
    [ "$n" -le "$tokln" ] && continue
    [ "$n" -ge "$maskln" ] && break
    [[ $line =~ add-mask ]] && continue
    [[ $line =~ (\$\{${var}\}|\$${var}([^A-Za-z0-9_]|$)) ]] && return 0
  done <<<"$run"
  return 1
}

check_token_run_step() {
  local f=$1 job=$2 sl=$3 run=$4
  local var
  if ! grep -q 'get-access-token' <<<"$run" || ! grep -q 'SMOKE_API_SCOPE' <<<"$run"; then
    hit "$f" "$sl" "token step must use az account get-access-token with scope SMOKE_API_SCOPE"; return
  fi
  if grep -qF 'grant_type=password' <<<"$run"; then hit "$f" "$sl" "ROPC grant_type=password not allowed"; return; fi
  if grep -qF 'AZURE_USERNAME' <<<"$run"; then hit "$f" "$sl" "AZURE_USERNAME not allowed"; return; fi
  if grep -qE '(^|[^A-Za-z0-9_])([A-Za-z0-9_.]*\.Write|API\.Write)([^A-Za-z0-9_]|$)' <<<"$run"; then
    hit "$f" "$sl" "Write role must not be requested in smoke auth"; return
  fi
  if grep -qE '(^|[^A-Za-z0-9_])([A-Za-z0-9_.]*\.Admin|API\.Admin)([^A-Za-z0-9_]|$)' <<<"$run"; then
    hit "$f" "$sl" "Admin role must not be requested in smoke auth"; return
  fi
  var=$(token_var_from_run "$run")
  if [ -z "$var" ]; then hit "$f" "$sl" "token step must capture az account get-access-token into a shell variable"; return; fi
  if run_capture_mask_same_line "$run" "$var"; then
    hit "$f" "$sl" "::add-mask:: must run after the token is captured"; return
  fi
  if run_leaks_token_var "$run" "$var"; then hit "$f" "$sl" "token must not be echoed or printed"; return; fi
  tokln=$(grep -nF "${var}=\$(az account get-access-token" <<<"$run" | head -n1 | cut -d: -f1)
  maskln=$(grep -nF "::add-mask::\$${var}" <<<"$run" | head -n1 | cut -d: -f1)
  [ -z "$maskln" ] && maskln=$(grep -nF "::add-mask::\${${var}}" <<<"$run" | head -n1 | cut -d: -f1)
  if [ -n "$tokln" ] && [ -n "$maskln" ] && [ "$maskln" -le "$tokln" ]; then
    hit "$f" "$sl" "::add-mask:: must run after the token is captured"; return
  fi
  if run_uses_var_before_mask "$run" "$var"; then hit "$f" "$sl" "token used before ::add-mask::"; return; fi
  if ! run_masks_var "$run" "$var"; then
    if grep -q '::add-mask::' <<<"$run"; then
      hit "$f" "$sl" "::add-mask:: must mask the captured token variable"; return
    fi
    hit "$f" "$sl" "token must be masked with ::add-mask:: before any other use"; return
  fi
}

check_mint_job_steps() {
  local f=$1 job=$2 jl=$3
  local loginln uses cid tid allow sub envdbg wfl sl run
  wfl=$(yq '.env | line' "$f" 2>/dev/null) || wfl=1
  envdbg=$(yq -r '.env.ACTIONS_STEP_DEBUG // ""' "$f" 2>/dev/null)
  if debug_env_true "$envdbg"; then hit "$f" "$wfl" "workflow must not set ACTIONS_STEP_DEBUG"; return; fi
  envdbg=$(J=$job yq -r '.jobs[strenv(J)].env.ACTIONS_STEP_DEBUG // ""' "$f" 2>/dev/null)
  if debug_env_true "$envdbg"; then hit "$f" "$jl" "job $job must not set ACTIONS_STEP_DEBUG"; return; fi
  while IFS= read -r sl; do
    [ -n "$sl" ] || continue
    envdbg=$(J=$job SL=$sl yq -r '.jobs[strenv(J)].steps[]? | select(line == (env(SL) | tonumber)) | .env.ACTIONS_STEP_DEBUG // ""' "$f" 2>/dev/null)
    if debug_env_true "$envdbg"; then hit "$f" "$sl" "step must not enable ACTIONS_STEP_DEBUG"; return; fi
    run=$(J=$job SL=$sl yq -r '.jobs[strenv(J)].steps[]? | select(line == (env(SL) | tonumber)) | .run // ""' "$f" 2>/dev/null)
    if run_has_debug_trace "$run"; then hit "$f" "$sl" "step must not enable shell debug trace (set -x)"; return; fi
  done < <(J=$job yq '.jobs[strenv(J)].steps[]? | line' "$f" 2>/dev/null)
  loginln=$(J=$job yq '.jobs[strenv(J)].steps[]? | select(.["uses"] // "" | test("^azure/login@")) | line' "$f" 2>/dev/null | head -n1)
  if [ -z "$loginln" ]; then hit "$f" "$jl" "job $job can mint an OIDC token but has no azure/login step"; return; fi
  while IFS=$'\t' read -r loginln uses; do
    [ -n "$loginln" ] || continue
    if [ "$uses" != 'azure/login@v2' ]; then hit "$f" "$loginln" "azure/login must be pinned to azure/login@v2"; return; fi
  done < <(J=$job yq -r '.jobs[strenv(J)].steps[]? | select(.["uses"] // "" | test("^azure/login@")) | [line, .["uses"]] | @tsv' "$f" 2>/dev/null)
  cid=$(J=$job yq -r '.jobs[strenv(J)].steps[]? | select(.["uses"] // "" | test("^azure/login@")) | .with["client-id"] // ""' "$f" | head -n1)
  tid=$(J=$job yq -r '.jobs[strenv(J)].steps[]? | select(.["uses"] // "" | test("^azure/login@")) | .with["tenant-id"] // ""' "$f" | head -n1)
  allow=$(J=$job yq -r '.jobs[strenv(J)].steps[]? | select(.["uses"] // "" | test("^azure/login@")) | .with["allow-no-subscriptions"] // ""' "$f" | head -n1)
  sub=$(J=$job yq -r '.jobs[strenv(J)].steps[]? | select(.["uses"] // "" | test("^azure/login@")) | .with["subscription-id"] // ""' "$f" | head -n1)
  if [ "$cid" != "$WANT_CID" ]; then hit "$f" "$loginln" "azure/login client-id must be $WANT_CID"; return; fi
  if [ "$tid" != "$WANT_TID" ]; then hit "$f" "$loginln" "azure/login tenant-id must be $WANT_TID"; return; fi
  if [ "$allow" != true ] && [ "$allow" != 'true' ]; then hit "$f" "$loginln" "azure/login must set allow-no-subscriptions: true"; return; fi
  if [ -n "$sub" ] && grep -q 'secrets\.' <<<"$sub"; then hit "$f" "$loginln" "azure/login must not use subscription-id from secrets"; return; fi
  if grep -q 'secrets\.' <<<"$cid$tid"; then hit "$f" "$loginln" "azure/login must use environment vars AZURE_CLIENT_ID and AZURE_TENANT_ID (vars.*), not secrets"; return; fi
  sl=$(J=$job yq '.jobs[strenv(J)].steps[]? | select(.run // "" | test("get-access-token")) | line' "$f" 2>/dev/null | head -n1)
  if [ -z "$sl" ]; then hit "$f" "$jl" "job $job must capture token with az account get-access-token --scope \"\$SMOKE_API_SCOPE\""; return; fi
  while IFS= read -r sl; do
    [ -n "$sl" ] || continue
    run=$(J=$job SL=$sl yq -r '.jobs[strenv(J)].steps[]? | select(line == (env(SL) | tonumber)) | .run // ""' "$f" 2>/dev/null)
    check_token_run_step "$f" "$job" "$sl" "$run"
    [ "$N" -gt 0 ] && return
  done < <(J=$job yq '.jobs[strenv(J)].steps[]? | select(.run // "" | test("get-access-token")) | line' "$f" 2>/dev/null)
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
