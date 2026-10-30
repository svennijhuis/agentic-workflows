#!/usr/bin/env bash
# POL03 staged and dispatch first: every workflow has on.workflow_dispatch; triggers other than
# workflow_dispatch and write outputs without `staged: true` need a governance/rollout.yml promotion (Sven's yes).
# .github/workflows/*.yml and *.yaml (repo mode) and any .yml or .yaml argument are workflow_dispatch only on the same terms.
# Lock files are checked too (SM05a round 2): every *.lock.yml under .github/workflows/ and workflows/ in repo mode,
#   a *.lock.yml argument, and the X.lock.yml beside a checked X.md. A lock is agentic, so workflow_call and
#   deployment_status always fail on it; its promoted: name is X.
# $POL_ROLLOUT is for tests only: repo mode ignores it and reads governance/rollout.yml.
# on: is read through scripts/lib/on-triggers.sh: string, list and map forms alike; a parse error is a hit.
# SM05a: deterministic_triggers (scripts/lib/det-triggers.sh). Before `promoted && return 0`:
#   a rollout file that does not parse, or a deterministic_triggers that is not a map, fails every file;
#   a listed entry needs triggers plus non-empty yes.date and yes.quote; deployment_status always fails;
#   workflow_call passes only on a non-agentic file whose entry lists it; an entry trigger other than
#   workflow_dispatch and workflow_call needs promoted:. A case folder (DIR with rollout.yml) is checked
#   with its own rollout.yml and must hold exactly one workflow file.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
# shellcheck source=../../scripts/lib/on-triggers.sh
. "$POL_ROOT/scripts/lib/on-triggers.sh"
# shellcheck source=../../scripts/lib/det-triggers.sh
. "$POL_ROOT/scripts/lib/det-triggers.sh"
repo_mode "$@" && unset POL_ROLLOUT
ROLLOUT=$(det_rollout)
# promoted NAME: NAME is an exact item of promoted: (strenv, no substring match; a non-list is not promoted)
promoted() { [ -f "$ROLLOUT" ] && [ "$(N=$1 yq '(.promoted // []) | select(tag == "!!seq") | any_c(. == strenv(N))' "$ROLLOUT" 2>/dev/null)" = "true" ]; }
# wf_name FILE: promoted: name of a workflow file (X for X.md, X.lock.yml, X.yml, X.yaml)
wf_name() { local b; b=$(basename "$1"); case "$b" in *.lock.yml) echo "${b%.lock.yml}" ;; *) echo "${b%.*}" ;; esac; }
SETTINGS=" $(polcfg POL25 '.settings | join(" ")') "
READ_ONLY=' noop missing-tool missing-data report-incomplete '

triggers_ok() { # FILE NAME: on: triggers are workflow_dispatch (plus settings) unless promoted
  local f=$1 r b t trig rc l err call_ok=0; r=$(rel "$f"); b=$(basename "$f")
  trig=$(on_triggers "$f"); rc=$?
  case $rc in
    3) case "$f" in *.md) return 1 ;; *) hit "$r" 1 POL03 "no on: key (workflow_dispatch only)"; return 0 ;; esac ;;
    2) hit "$r" "$(on_line "$f")" POL03 "on: does not parse as a string, list or map (fail closed)"; return 0 ;;
  esac
  l=$(on_line "$f")
  err=$(det_map_err "$ROLLOUT")
  if [ -n "$err" ]; then hit "$r" "$l" POL03 "$err"; return 0; fi
  if det_listed "$ROLLOUT" "$b"; then
    while IFS= read -r err; do [ -n "$err" ] && hit "$r" "$l" POL03 "$err"; done < <(det_entry_err "$ROLLOUT" "$b")
    det_entry_triggers "$ROLLOUT" "$b" | grep -qx workflow_call && ! det_agentic "$f" && call_ok=1
    while IFS= read -r t; do
      case "$t" in
        workflow_dispatch|workflow_call) ;;
        *) promoted "$2" || hit "$r" "$l" POL03 "deterministic_triggers entry $b lists '$t': only workflow_dispatch and workflow_call (other triggers need promoted:)" ;;
      esac
    done < <(det_entry_triggers "$ROLLOUT" "$b")
  fi
  while IFS= read -r t; do
    case "$t" in
      deployment_status) hit "$r" "$l" POL03 "trigger 'deployment_status' always fails, listed or promoted (it names the GitHub environment, not tst or acc)" ;;
      workflow_call)
        if det_agentic "$f"; then hit "$r" "$l" POL03 "agentic workflow never gets 'workflow_call' (PA1), listed or promoted"
        elif [ $call_ok -eq 0 ]; then hit "$r" "$l" POL03 "trigger 'workflow_call' needs a deterministic_triggers entry for $b that lists it (Sven's yes)"; fi ;;
    esac
  done <<<"$trig"
  promoted "$2" && return 0
  grep -qx workflow_dispatch <<<"$trig" || hit "$r" "$l" POL03 "no on.workflow_dispatch path"
  while IFS= read -r t; do
    case "$t" in workflow_dispatch|deployment_status|workflow_call) continue ;; esac
    case "$SETTINGS" in *" $t "*) ;; *) hit "$r" "$l" POL03 "trigger '$t' needs a governance/rollout.yml promotion (Sven's yes)" ;; esac
  done <<<"$trig"
  return 0
}

check_file() { # FILE
  local f=$1 r o
  case "$f" in
    *.yml|*.yaml) triggers_ok "$f" "$(wf_name "$f")"; return ;;
  esac
  [ -f "${f%.md}.lock.yml" ] && triggers_ok "${f%.md}.lock.yml" "$(wf_name "$f")"
  triggers_ok "$f" "$(wf_name "$f")" || return
  promoted "$(basename "$f" .md)" && return
  is_workflow "$f" || return
  r=$(rel "$f")
  if [ "$(q "$f" '.["safe-outputs"].staged')" != "true" ]; then
    for o in $(so_outputs "$f"); do
      case "$READ_ONLY" in *" $o "*) ;; *) hit "$r" "$(qline "$f" ".[\"safe-outputs\"].[\"$o\"]")" POL03 "write output '$o' without safe-outputs.staged: true" ;; esac
    done
  fi
}

for a in "$@"; do
  det_case "$a" || continue
  mapfile -t cf < <(det_case_files "$a")
  if [ "${#cf[@]}" -ne 1 ]; then hit "$(rel "$a")" 1 POL03 "case folder needs exactly one workflow file beside rollout.yml, found ${#cf[@]}"; continue; fi
  ROLLOUT=$(det_rollout "$a"); check_file "${cf[0]}"; ROLLOUT=$(det_rollout)
done
args=(); for a in "$@"; do det_case "$a" || args+=("$a"); done
if [ $# -eq 0 ] || [ ${#args[@]} -gt 0 ]; then
  for f in $(targets "${args[@]}"); do check_file "$f"; done
fi
if repo_mode "$@"; then
  for y in "$POL_ROOT"/.github/workflows/*.yml "$POL_ROOT"/.github/workflows/*.yaml; do
    [ -e "$y" ] || continue; triggers_ok "$y" "$(wf_name "$y")"
  done
  # orphan locks under workflows/ (a lock beside an X.md was already checked with that X.md)
  while IFS= read -r y; do
    [ -e "${y%.lock.yml}.md" ] || triggers_ok "$y" "$(wf_name "$y")"
  done < <(find "$POL_ROOT/workflows" -name '*.lock.yml' 2>/dev/null | sort)
fi
pol_done
