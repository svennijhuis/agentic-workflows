#!/usr/bin/env bash
# POL25 agentic workflows are workflow_dispatch only (PA1).
#   *.md workflow: frontmatter on: keys are workflow_dispatch plus settings only; its sibling .lock.yml too.
#   *.lock.yml or a yml with a gh-aw-metadata header: on: keys are workflow_dispatch only.
#   Deterministic CI yml: POL25 fails deployment_status (always) and workflow_call unless deterministic_triggers lists it;
#     pull_request, push and other triggers are out of scope here (POL03 promoted: gates them).
#   A workflow listed in policies/POL25.yml sven_yes is skipped (Sven's exact yes, none today).
#   SM05b: deterministic_triggers (scripts/lib/det-triggers.sh). Rollout path matches POL03 case folders.
#   on: is read through scripts/lib/on-triggers.sh (string, list, map); a parse error is a hit (fail closed).
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
# shellcheck source=../../scripts/lib/on-triggers.sh
. "$POL_ROOT/scripts/lib/on-triggers.sh"
# shellcheck source=../../scripts/lib/det-triggers.sh
. "$POL_ROOT/scripts/lib/det-triggers.sh"
repo_mode "$@" && unset POL_ROLLOUT
ROLLOUT=$(det_rollout)
SETTINGS=" $(polcfg POL25 '.settings | join(" ")') "
yes_for() { [ "$(yq ".sven_yes // [] | map(.workflow) | contains([\"$1\"])" "$POL_ROOT/policies/POL25.yml")" = true ]; }

check_triggers() { # FILE WFNAME: rollout, allowlist and on: triggers
  local f=$1 name=$2 r b t trig rc l err call_ok=0 agentic=0
  r=$(rel "$f"); b=$(basename "$f")
  det_agentic "$f" && agentic=1
  l=$(on_line "$f")
  err=$(det_map_err "$ROLLOUT")
  if [ -n "$err" ]; then hit "$r" "$l" POL25 "$err"; return 0; fi
  trig=$(on_triggers "$f"); rc=$?
  case $rc in
    3) case "$f" in
         *.md) is_workflow "$f" || return 0 ;;
         *) hit "$r" "$l" POL25 "no on: key (fail closed)"; return 0 ;;
       esac ;;
    2) hit "$r" "$(on_line "$f")" POL25 "on: does not parse as a string, list or map (fail closed)"; return 0 ;;
  esac
  if det_listed "$ROLLOUT" "$b"; then
    while IFS= read -r err; do [ -n "$err" ] && hit "$r" "$l" POL25 "$err"; done < <(det_entry_err "$ROLLOUT" "$b")
    det_entry_triggers "$ROLLOUT" "$b" | grep -qx workflow_call && [ "$agentic" -eq 0 ] && call_ok=1
  fi
  while IFS= read -r t; do
    case "$t" in
      deployment_status) hit "$r" "$l" POL25 "trigger 'deployment_status' always fails, listed or promoted (it names the GitHub environment, not tst or acc)" ;;
      workflow_call)
        if [ "$agentic" -eq 1 ]; then hit "$r" "$l" POL25 "agentic workflow never gets 'workflow_call' (PA1), listed or promoted"
        elif [ "$call_ok" -eq 0 ]; then hit "$r" "$l" POL25 "trigger 'workflow_call' needs a deterministic_triggers entry for $b that lists it (Sven's yes)"; fi ;;
      workflow_dispatch) ;;
      *)
        if [ "$agentic" -eq 1 ]; then
          case "$SETTINGS" in *" $t "*) ;; *) hit "$r" "$l" POL25 "agentic trigger '$t': workflow_dispatch only (PA1, Sven's yes)" ;; esac
        fi
        ;;
    esac
  done <<<"$trig"
  if [ "$agentic" -eq 1 ]; then grep -qx workflow_dispatch <<<"$trig" || hit "$r" "$l" POL25 "no on.workflow_dispatch"; fi
  return 0
}

check_file() { # FILE
  local f=$1 name
  case "$f" in
    *.md)
      name=$(basename "$f" .md); yes_for "$name" && return
      check_triggers "$f" "$name"
      [ -f "${f%.md}.lock.yml" ] && check_triggers "${f%.md}.lock.yml" "$name"
      ;;
    *.yml|*.yaml)
      if det_agentic "$f"; then
        name=$(basename "$f" .lock.yml); name=${name%.yml}; name=${name%.yaml}
        yes_for "$name" && return
        check_triggers "$f" "$name"
      else
        check_triggers "$f" "$(basename "$f")"
      fi
      ;;
  esac
}

for a in "$@"; do
  det_case "$a" || continue
  mapfile -t cf < <(det_case_files "$a")
  if [ "${#cf[@]}" -ne 1 ]; then hit "$(rel "$a")" 1 POL25 "case folder needs exactly one workflow file beside rollout.yml, found ${#cf[@]}"; continue; fi
  ROLLOUT=$(det_rollout "$a"); check_file "${cf[0]}"; ROLLOUT=$(det_rollout)
done
args=(); for a in "$@"; do det_case "$a" || args+=("$a"); done
if [ $# -eq 0 ] || [ ${#args[@]} -gt 0 ]; then
  for f in $(targets "${args[@]}"); do check_file "$f"; done
fi
if repo_mode "$@"; then
  for y in "$POL_ROOT"/.github/workflows/*.yml "$POL_ROOT"/.github/workflows/*.yaml; do
    [ -e "$y" ] || continue
    det_agentic "$y" || check_triggers "$y" "$(basename "$y")"
  done
fi
pol_done
