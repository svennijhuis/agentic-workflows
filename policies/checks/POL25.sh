#!/usr/bin/env bash
# POL25 agentic workflows are workflow_dispatch only (PA1).
#   *.md workflow: frontmatter on: keys are workflow_dispatch plus settings only; its sibling .lock.yml too.
#   *.lock.yml or a yml with a gh-aw-metadata header: on: keys are workflow_dispatch only.
#   Deterministic CI yml: POL25 fails deployment_status (always) and workflow_call unless deterministic_triggers lists it;
#     pull_request, push and other triggers are out of scope here (gh aw compile --strict covers the rest).
#   sven_yes: reads $POL25_CFG (default policies/POL25.yml). deployment_status, workflow_call allowlist and
#     agentic workflow_call fail before yes_for; yes_for lifts only the agentic dispatch-only rule (e.g. schedule).
#     lock_keys: a .lock.yml under yes_for may only use triggers its .md also has; a lock with no sibling .md is a hit.
#     yes_for matches the workflow name exactly and needs a non-blank date (str or timestamp) and quote.
#   deterministic_triggers: scripts/lib/det-triggers.sh reads governance/rollout.yml or a case folder rollout.yml.
#   on: is read through scripts/lib/on-triggers.sh (string, list, map); a parse error is a hit (fail closed).
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
# shellcheck source=../../scripts/lib/on-triggers.sh
. "$POL_ROOT/scripts/lib/on-triggers.sh"
# shellcheck source=../../scripts/lib/det-triggers.sh
. "$POL_ROOT/scripts/lib/det-triggers.sh"
repo_mode "$@" && unset POL_ROLLOUT POL25_CFG
ROLLOUT=$(det_rollout)
POL25_CFG=$(det_pol25_cfg)
SETTINGS=" $(yq '.settings // [] | join(" ")' "$POL25_CFG") "
# yes_for NAME: 0 lifted, 1 no sven_yes row with workflow exactly NAME, 2 a row matches but its date
#   (non-blank str or yaml timestamp) or quote (non-blank str) is missing or blank. Only 0 lifts.
#   A yq error (config does not parse) is 1: not lifted, fail closed.
yes_for() {
  local n ok
  n=$(N=$1 yq '[.sven_yes // [] | .[] | select(.workflow == strenv(N))] | length' "$POL25_CFG" 2>/dev/null)
  case "$n" in ''|*[!0-9]*|0) return 1 ;; esac
  ok=$(N=$1 yq '[.sven_yes // [] | .[] | select(.workflow == strenv(N))
    | select(((.date | tag) == "!!timestamp") or ((.date | tag) == "!!str" and (.date | trim) != ""))
    | select((.quote | tag) == "!!str" and (.quote | trim) != "")] | length' "$POL25_CFG" 2>/dev/null)
  [ "$ok" = "$n" ] || return 2
  return 0
}

lock_keys() { # LOCK MD: under sven_yes, every lock trigger must appear on the md too
  local lock=$1 md=$2 r l lock_trig md_trig t
  r=$(rel "$lock"); l=$(on_line "$lock")
  lock_trig=$(on_triggers "$lock"); md_trig=$(on_triggers "$md")
  while IFS= read -r t; do
    case "$SETTINGS" in *" $t "*) continue ;; esac
    grep -qx "$t" <<<"$md_trig" || hit "$r" "$l" POL25 "lock trigger '$t' is not on $(basename "$md") (sven_yes allows only triggers the md has)"
  done <<<"$lock_trig"
}

check_triggers() { # FILE WFNAME: rollout, allowlist and on: triggers
  local f=$1 name=$2 r b t trig rc l err call_ok=0 agentic=0 yrc=1 why=''
  r=$(rel "$f"); b=$(basename "$f")
  det_agentic "$f" && agentic=1
  if [ "$agentic" -eq 1 ]; then
    yes_for "$name"; yrc=$?
    [ "$yrc" -eq 2 ] && why="; sven_yes row for $name needs a non-blank date and quote"
  fi
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
        if [ "$agentic" -eq 1 ] && [ "$yrc" -ne 0 ]; then
          case "$SETTINGS" in *" $t "*) ;; *) hit "$r" "$l" POL25 "agentic trigger '$t': workflow_dispatch only (PA1, Sven's yes)$why" ;; esac
        fi
        ;;
    esac
  done <<<"$trig"
  if [ "$agentic" -eq 1 ]; then
    grep -qx workflow_dispatch <<<"$trig" || hit "$r" "$l" POL25 "no on.workflow_dispatch"
    if [ "$yrc" -eq 0 ]; then
      case "$f" in
        *.lock.yml)
          if [ -f "${f%.lock.yml}.md" ]; then lock_keys "$f" "${f%.lock.yml}.md"
          else hit "$r" "$l" POL25 "lock under sven_yes has no paired $(basename "${f%.lock.yml}").md (orphan lock, fail closed)"; fi ;;
      esac
    fi
  fi
  return 0
}

check_file() { # FILE
  local f=$1 name
  case "$f" in
    *.md)
      name=$(basename "$f" .md)
      check_triggers "$f" "$name"
      [ -f "${f%.md}.lock.yml" ] && check_triggers "${f%.md}.lock.yml" "$name"
      ;;
    *.yml|*.yaml)
      if det_agentic "$f"; then
        name=$(basename "$f" .lock.yml); name=${name%.yml}; name=${name%.yaml}
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
  ROLLOUT=$(det_rollout "$a"); POL25_CFG=$(det_pol25_cfg "$a")
  SETTINGS=" $(yq '.settings // [] | join(" ")' "$POL25_CFG") "
  check_file "${cf[0]}"
  ROLLOUT=$(det_rollout); POL25_CFG=$(det_pol25_cfg)
  SETTINGS=" $(yq '.settings // [] | join(" ")' "$POL25_CFG") "
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
