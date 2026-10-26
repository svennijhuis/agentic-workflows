#!/usr/bin/env bash
# SM04a smoke auth check: parse, triggers and the OIDC environment rule. Args: one or more workflow files.
# Prints one `file:line SMOKEAUTH message` per hit. Exit 0 ok, 1 a hit (fail closed), 2 needs-human (yq missing).
# Rules, per file:
#   1 parse: `yq` reads the file and its top level is a map, else one hit and the file stops here; any anchor or
#     alias (`&p`, `*p`, `<<: *p`) is one hit and the file stops; a duplicate key in any map is a hit and the file
#     stops (yq keeps only the last one, so `id-token: write` then `id-token: none` would read as none)
#   2 triggers, read only through on_triggers (scripts/lib/on-triggers.sh): its exit 2 (parse error or bad
#     shape) and exit 3 (no on: key) are hits; after dropping roles, skip-bots and skip-roles the list must be
#     non-empty and every name workflow_dispatch or workflow_call (an allowlist: any other name is a hit)
#   3 jobs is a non-empty map
#   4 OIDC environment: a job mints a token when its permissions are write-all or have id-token: write, or when
#     it has no permissions key and the workflow permissions do. `permissions: {}` and read-all grant nothing.
#     A permissions value that is not a map, read-all or write-all (an empty `permissions:` included) is a hit.
#     Each such job declares environment as exactly the string `smoke-${{ inputs.env }}` (a map, null, prd,
#     prod, nonprod, a bare `${{ inputs.env }}` or a hardcoded smoke-tst is a hit)
# Token hygiene (secrets, mask, debug trace, roles) is SM04b.
set -uo pipefail
case "${1:-}" in -h|--help) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac
command -v yq >/dev/null 2>&1 || { echo "scripts/check-smoke-auth.sh:1 VERIFY needs-human missing: yq"; exit 2; }
# shellcheck source=lib/on-triggers.sh
. "$(dirname "$0")/lib/on-triggers.sh"
N=0
# shellcheck disable=SC2016 # literal GitHub expression, not a shell variable
WANT='smoke-${{ inputs.env }}'
hit() { echo "$1:$2 SMOKEAUTH $3"; N=$((N + 1)); } # FILE LINE MESSAGE

# KEYS: one `line<TAB>key` row per key of every map (SM01 check-smoke.sh); a repeated row is a duplicate key
# shellcheck disable=SC2016 # $m is a yq variable
KEYS='.. | select(tag == "!!map") | . as $m | keys | .[] | [($m | line), .] | @tsv'
# ANCHORS: line of every anchor or alias node
ANCHORS='.. | select(anchor != "" or kind == "alias") | line'
# PSHAPE: true when a permissions node has a valid shape (a map, read-all or write-all)
PSHAPE='(tag == "!!map" or (tag == "!!str" and (. == "read-all" or . == "write-all")))'

# MINTS: yq test on a permissions node (outer parens: yq binds `or` looser than `|`), true when it grants id-token: write (write-all or the id-token key)
MINTS='((tag == "!!str" and . == "write-all") or (tag == "!!map" and .["id-token"] == "write"))'

check_file() {
  local f=$1 rc t names=() top job jl wf m env etag v line k dup=0
  if ! top=$(yq -p yaml '. | tag' "$f" 2>/dev/null) || [ "$top" != '!!map' ]; then
    hit "$f" 1 "file does not parse as a YAML map"; return
  fi
  v=$(yq "$ANCHORS" "$f" 2>/dev/null) || { hit "$f" 1 "anchors do not read"; return; }
  if [ -n "$v" ]; then hit "$f" "$(head -n1 <<<"$v")" "anchor or alias not allowed (permissions could hide behind it)"; return; fi
  v=$(yq -r "$KEYS" "$f" 2>/dev/null) || { hit "$f" 1 "keys do not read"; return; }
  while IFS=$'\t' read -r line k; do
    [ -n "$line" ] && { hit "$f" "$line" "duplicate key '$k' (yq keeps only the last one)"; dup=1; }
  done < <(sort <<<"$v" | uniq -d)
  [ "$dup" -eq 0 ] || return
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
  if [ "$(yq '.jobs | tag' "$f")" != '!!map' ] || [ "$(yq '.jobs | length' "$f")" -eq 0 ]; then
    hit "$f" 1 "jobs: is missing, empty or not a map"; return
  fi
  if [ "$(yq 'has("permissions")' "$f")" = true ] && [ "$(yq ".permissions | $PSHAPE" "$f")" != true ]; then
    hit "$f" "$(yq '.permissions | key | line' "$f")" "workflow permissions is $(yq '.permissions | tag' "$f") (want a map, read-all or write-all)"
  fi
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
    if [ "$etag" != '!!str' ]; then
      hit "$f" "$jl" "job $job can mint an OIDC token but environment is ${etag#!!} (want the string $WANT)"
    elif [ "$env" != "$WANT" ]; then
      hit "$f" "$jl" "job $job can mint an OIDC token but environment is '$env' (want $WANT)"
    fi
  done < <(yq '.jobs | keys | .[]' "$f")
}

[ $# -gt 0 ] || { echo "scripts/check-smoke-auth.sh:1 SMOKEAUTH usage: check-smoke-auth.sh FILE..."; exit 1; }
for f in "$@"; do check_file "$f"; done
[ "$N" -eq 0 ]
