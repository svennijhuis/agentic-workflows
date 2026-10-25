#!/usr/bin/env bash
# POL25 agentic workflows are workflow_dispatch only (PA1).
#   *.md workflow: frontmatter on: keys are workflow_dispatch plus settings only; its sibling .lock.yml too.
#   *.lock.yml or a yml with a gh-aw-metadata header: on: keys are workflow_dispatch only.
#   Any other *.yml is deterministic CI: allowed here (pull_request is fine), POL03 gates its promotion.
#   A workflow listed in policies/POL25.yml sven_yes is skipped (Sven's exact yes, none today).
#   on: is read through scripts/lib/on-triggers.sh (string, list, map); a parse error is a hit (fail closed).
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
# shellcheck source=../../scripts/lib/on-triggers.sh
. "$POL_ROOT/scripts/lib/on-triggers.sh"
SETTINGS=" $(polcfg POL25 '.settings | join(" ")') "
yes_for() { [ "$(yq ".sven_yes // [] | map(.workflow) | contains([\"$1\"])" "$POL_ROOT/policies/POL25.yml")" = true ]; }
agentic_yml() { case "$1" in *.lock.yml) return 0 ;; esac; head -3 "$1" | grep -q '^# gh-aw-metadata:'; }
lock_keys() { # FILE: triggers in a compiled lock
  local t r trig rc; r=$(rel "$1")
  trig=$(on_triggers "$1"); rc=$?
  if [ $rc -ne 0 ]; then hit "$r" "$(on_line "$1")" POL25 "agentic lock on: missing or does not parse (fail closed)"; return; fi
  while IFS= read -r t; do
    [ "$t" = workflow_dispatch ] || hit "$r" "$(on_line "$1")" POL25 "agentic lock trigger '$t': workflow_dispatch only (PA1, Sven's yes)"
  done <<<"$trig"
}
files() { if [ $# -eq 0 ]; then targets; else for a in "$@"; do if [ -d "$a" ]; then find "$a" -name '*.md' ! -name README.md -o -name '*.yml' | sort; else echo "$a"; fi; done; fi; }
for f in $(files "$@"); do
  case "$f" in
    *.md)
      trig=$(on_triggers "$f"); rc=$?
      [ $rc -eq 3 ] && continue
      r=$(rel "$f")
      if [ $rc -eq 2 ]; then hit "$r" "$(on_line "$f")" POL25 "on: does not parse as a string, list or map (fail closed)"; continue; fi
      name=$(basename "$f" .md); yes_for "$name" && continue
      while IFS= read -r t; do
        [ "$t" = workflow_dispatch ] && continue
        case "$SETTINGS" in *" $t "*) ;; *) hit "$r" "$(on_line "$f")" POL25 "agentic trigger '$t': workflow_dispatch only (PA1, Sven's yes)" ;; esac
      done <<<"$trig"
      grep -qx workflow_dispatch <<<"$trig" || hit "$r" "$(on_line "$f")" POL25 "no on.workflow_dispatch"
      [ -f "${f%.md}.lock.yml" ] && lock_keys "${f%.md}.lock.yml" ;;
    *.yml)
      agentic_yml "$f" || continue
      yes_for "$(basename "$f" .lock.yml)" && continue
      lock_keys "$f" ;;
  esac
done
pol_done
