#!/usr/bin/env bash
# POL03 staged and dispatch first: every workflow has on.workflow_dispatch; triggers other than
# workflow_dispatch and write outputs without `staged: true` need a governance/rollout.yml promotion (Sven's yes).
# .github/workflows/*.yml (repo mode) and any .yml argument are workflow_dispatch only on the same terms.
# on: is read through scripts/lib/on-triggers.sh: string, list and map forms alike; a parse error is a hit.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
# shellcheck source=../../scripts/lib/on-triggers.sh
. "$POL_ROOT/scripts/lib/on-triggers.sh"
ROLLOUT="$POL_ROOT/governance/rollout.yml"
promoted() { [ -f "$ROLLOUT" ] && [ "$(yq ".promoted // [] | contains([\"$1\"])" "$ROLLOUT")" = "true" ]; }
OK_KEYS=' workflow_dispatch roles skip-bots skip-roles '
READ_ONLY=' noop missing-tool missing-data report-incomplete '

triggers_ok() { # FILE NAME: on: triggers are workflow_dispatch (plus settings) unless promoted
  local f=$1 r t trig rc; r=$(rel "$f")
  trig=$(on_triggers "$f"); rc=$?
  case $rc in
    3) case "$f" in *.md) return 1 ;; *) hit "$r" 1 POL03 "no on: key (workflow_dispatch only)"; return 0 ;; esac ;;
    2) hit "$r" "$(on_line "$f")" POL03 "on: does not parse as a string, list or map (fail closed)"; return 0 ;;
  esac
  promoted "$2" && return 0
  grep -qx workflow_dispatch <<<"$trig" || hit "$r" "$(on_line "$f")" POL03 "no on.workflow_dispatch path"
  while IFS= read -r t; do
    case "$OK_KEYS" in *" $t "*) ;; *) hit "$r" "$(on_line "$f")" POL03 "trigger '$t' needs a governance/rollout.yml promotion (Sven's yes)" ;; esac
  done <<<"$trig"
  return 0
}

for f in $(targets "$@"); do
  case "$f" in
    *.yml) case "$f" in *.lock.yml) continue ;; esac; triggers_ok "$f" "$(basename "$f" .yml)"; continue ;;
  esac
  triggers_ok "$f" "$(basename "$f" .md)" || continue
  promoted "$(basename "$f" .md)" && continue
  is_workflow "$f" || continue
  r=$(rel "$f")
  if [ "$(q "$f" '.["safe-outputs"].staged')" != "true" ]; then
    for o in $(so_outputs "$f"); do
      case "$READ_ONLY" in *" $o "*) ;; *) hit "$r" "$(qline "$f" ".[\"safe-outputs\"].[\"$o\"]")" POL03 "write output '$o' without safe-outputs.staged: true" ;; esac
    done
  fi
done
if repo_mode "$@"; then
  for y in "$POL_ROOT"/.github/workflows/*.yml; do
    [ -e "$y" ] || continue; case "$y" in *.lock.yml) continue ;; esac
    triggers_ok "$y" "$(basename "$y" .yml)"
  done
fi
pol_done
