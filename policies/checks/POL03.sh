#!/usr/bin/env bash
# POL03 staged and dispatch first: every workflow has on.workflow_dispatch; triggers other than
# workflow_dispatch and write outputs without `staged: true` need a governance/rollout.yml promotion (Sven's yes).
# Repo mode also holds .github/workflows/*.yml to workflow_dispatch only.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
ROLLOUT="$POL_ROOT/governance/rollout.yml"
promoted() { [ -f "$ROLLOUT" ] && [ "$(yq ".promoted // [] | contains([\"$1\"])" "$ROLLOUT")" = "true" ]; }
OK_KEYS=' workflow_dispatch roles skip-bots skip-roles '
READ_ONLY=' noop missing-tool missing-data report-incomplete '
for f in $(targets "$@"); do
  is_workflow "$f" || continue
  r=$(rel "$f"); name=$(basename "$f" .md)
  promoted "$name" && continue
  [ "$(q "$f" '.on | has("workflow_dispatch")')" = "true" ] || hit "$r" "$(qline "$f" .on)" POL03 "no on.workflow_dispatch path"
  for t in $(q "$f" '.on | keys | .[]'); do
    case "$OK_KEYS" in *" $t "*) ;; *) hit "$r" "$(qline "$f" ".on.[\"$t\"]")" POL03 "trigger '$t' needs a governance/rollout.yml promotion (Sven's yes)" ;; esac
  done
  if [ "$(q "$f" '.["safe-outputs"].staged')" != "true" ]; then
    for o in $(so_outputs "$f"); do
      case "$READ_ONLY" in *" $o "*) ;; *) hit "$r" "$(qline "$f" ".[\"safe-outputs\"].[\"$o\"]")" POL03 "write output '$o' without safe-outputs.staged: true" ;; esac
    done
  fi
done
if repo_mode "$@"; then
  for y in "$POL_ROOT"/.github/workflows/*.yml; do
    [ -e "$y" ] || continue; case "$y" in *.lock.yml) continue ;; esac
    promoted "$(basename "$y" .yml)" && continue
    for t in $(yq '.on | keys | .[]' "$y"); do
      [ "$t" = workflow_dispatch ] || hit "$(rel "$y")" "$(yq ".on.[\"$t\"] | line" "$y")" POL03 "trigger '$t' needs a governance/rollout.yml promotion (Sven's yes)"
    done
  done
fi
pol_done
