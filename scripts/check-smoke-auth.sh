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
#   7 token hygiene on each minting job that passes 6: azure/login from AZURE_* vars, masked get-access-token step
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

check_forbidden_inputs() {
  local f=$1 key line
  line=$(yq '.on | line' "$f" 2>/dev/null) || line=1
  while IFS= read -r key; do
    [ -n "$key" ] || continue
    case $key in
      client_secret|clientSecret|client-secret|password) hit "$f" "$line" "forbidden workflow input '$key'"; return 1 ;;
    esac
  done < <(yq -r '[(.on.workflow_call.inputs // {} | keys | .[]), (.on.workflow_dispatch.inputs // {} | keys | .[])] | .[]' "$f" 2>/dev/null)
  return 0
}

check_banned_scalars() {
  local f=$1 line v
  while IFS=$'\t' read -r line v; do
    [ -n "$line" ] || continue
    if grep -qF 'grant_type=password' <<<"$v"; then hit "$f" "$line" "ROPC grant_type=password not allowed"; return 1; fi
    if grep -qF 'AZURE_USERNAME' <<<"$v"; then hit "$f" "$line" "AZURE_USERNAME not allowed"; return 1; fi
    if [ "$v" = 'party.*' ]; then hit "$f" "$line" "party.* role not allowed"; return 1; fi
    if grep -qE '(^|[^A-Za-z0-9_])([A-Za-z0-9_.]*\.Write|API\.Write)([^A-Za-z0-9_]|$)' <<<"$v"; then
      hit "$f" "$line" "Write role must not be requested in smoke auth"; return 1
    fi
    if grep -qE '(^|[^A-Za-z0-9_])([A-Za-z0-9_.]*\.Admin|API\.Admin)([^A-Za-z0-9_]|$)' <<<"$v"; then
      hit "$f" "$line" "Admin role must not be requested in smoke auth"; return 1
    fi
  done < <(yq -r "$SCALARS" "$f" 2>/dev/null)
  return 0
}

check_id_token_case() {
  local f=$1 line val
  while IFS=$'\t' read -r line val; do
    [ -n "$line" ] && { hit "$f" "$line" "id-token permission must be lowercase write (got '$val')"; return 1; }
  done < <(yq -r "$BAD_IDTOKEN" "$f" 2>/dev/null)
  return 0
}

check_mint_job_steps() {
  local f=$1 job=$2 jl=$3
  local sl cid tid allow sub run envdbg maskln tokln usetokln loginln
  loginln=$(J=$job yq '.jobs[strenv(J)].steps[]? | select(.["uses"] // "" | test("^azure/login@")) | line' "$f" 2>/dev/null | head -n1)
  if [ -z "$loginln" ]; then hit "$f" "$jl" "job $job can mint an OIDC token but has no azure/login step"; return; fi
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
  run=$(J=$job yq -r '.jobs[strenv(J)].steps[]? | select(.run // "" | test("get-access-token")) | .run' "$f" 2>/dev/null)
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
  envdbg=$(J=$job yq -r '.jobs[strenv(J)].steps[]? | select(.run // "" | test("get-access-token")) | .env.ACTIONS_STEP_DEBUG // ""' "$f" 2>/dev/null | head -n1)
  if [ "$envdbg" = true ] || [ "$envdbg" = 'true' ]; then hit "$f" "$sl" "token step must not enable ACTIONS_STEP_DEBUG"; return; fi
  if grep -qE '(^|[[:space:]])set[[:space:]]+-x' <<<"$run"; then hit "$f" "$sl" "token step must not enable shell debug trace (set -x)"; return; fi
  # shellcheck disable=SC2016
  if grep -nE '^[[:space:]]*echo[[:space:]]' <<<"$run" | grep -v 'add-mask' | grep -v 'GITHUB_ENV' | grep -qE '\$TOKEN|accessToken'; then
    hit "$f" "$sl" "token must not be echoed or printed"; return
  fi
  maskln=$(grep -n '::add-mask::' <<<"$run" | head -n1 | cut -d: -f1)
  if [ -z "$maskln" ]; then hit "$f" "$sl" "token must be masked with ::add-mask:: before any other use"; return; fi
  tokln=$(grep -nE 'TOKEN=\$\(az account get-access-token|TOKEN=' <<<"$run" | head -n1 | cut -d: -f1)
  # shellcheck disable=SC2016
  usetokln=$(grep -nE 'GITHUB_ENV|echo[[:space:]]+"?\$TOKEN' <<<"$run" | grep -v 'add-mask' | head -n1 | cut -d: -f1)
  if [ -n "$usetokln" ] && [ -n "$maskln" ] && [ "$usetokln" -lt "$maskln" ]; then hit "$f" "$sl" "token used before ::add-mask::"; return; fi
  if [ -n "$tokln" ] && [ -n "$maskln" ] && [ "$maskln" -le "$tokln" ]; then hit "$f" "$sl" "::add-mask:: must run after the token is captured"; return; fi
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
