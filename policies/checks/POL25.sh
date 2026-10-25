#!/usr/bin/env bash
# POL25 agentic workflows are workflow_dispatch only (PA1).
#   *.md workflow: frontmatter on: keys are workflow_dispatch plus settings only; its sibling .lock.yml too.
#   *.lock.yml or a yml with a gh-aw-metadata header: on: keys are workflow_dispatch only.
#   Any other *.yml is deterministic CI: allowed here (pull_request is fine), POL03 gates its promotion.
#   A workflow listed in policies/POL25.yml sven_yes is skipped (Sven's exact yes, none today).
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
SETTINGS=" $(polcfg POL25 '.settings | join(" ")') "
yes_for() { [ "$(yq ".sven_yes // [] | map(.workflow) | contains([\"$1\"])" "$POL_ROOT/policies/POL25.yml")" = true ]; }
agentic_yml() { case "$1" in *.lock.yml) return 0 ;; esac; head -3 "$1" | grep -q '^# gh-aw-metadata:'; }
lock_keys() { # FILE: triggers in a compiled lock (comments ignored)
  local t r; r=$(rel "$1")
  for t in $(yq '.on | select(tag == "!!map") | keys | .[]' "$1" 2>/dev/null); do
    [ "$t" = workflow_dispatch ] || hit "$r" "$(yq ".on.[\"$t\"] | line" "$1")" POL25 "agentic lock trigger '$t': workflow_dispatch only (PA1, Sven's yes)"
  done
  [ "$(yq '.on | tag' "$1" 2>/dev/null)" = '!!map' ] || hit "$r" 1 POL25 "agentic lock has no on: map with workflow_dispatch"
}
files() { if [ $# -eq 0 ]; then targets; else for a in "$@"; do if [ -d "$a" ]; then find "$a" -name '*.md' ! -name README.md -o -name '*.yml' | sort; else echo "$a"; fi; done; fi; }
for f in $(files "$@"); do
  case "$f" in
    *.md)
      is_workflow "$f" || continue
      name=$(basename "$f" .md); yes_for "$name" && continue
      r=$(rel "$f")
      for t in $(q "$f" '.on | select(tag == "!!map") | keys | .[]'); do
        [ "$t" = workflow_dispatch ] && continue
        case "$SETTINGS" in *" $t "*) ;; *) hit "$r" "$(qline "$f" ".on.[\"$t\"]")" POL25 "agentic trigger '$t': workflow_dispatch only (PA1, Sven's yes)" ;; esac
      done
      [ "$(q "$f" '.on | has("workflow_dispatch")')" = true ] || hit "$r" "$(qline "$f" .on)" POL25 "no on.workflow_dispatch"
      [ -f "${f%.md}.lock.yml" ] && lock_keys "${f%.md}.lock.yml" ;;
    *.yml)
      agentic_yml "$f" || continue
      yes_for "$(basename "$f" .lock.yml)" && continue
      lock_keys "$f" ;;
  esac
done
pol_done
