#!/usr/bin/env bash
# deterministic_triggers and POL25_CFG reader for POL25. Fail closed: every error is a message.
# The rollout file is $POL_ROLLOUT (tests only; POL25 unsets it in repo mode), else <case>/rollout.yml for a case folder, else governance/rollout.yml.
#
# det_rollout [DIR]      path of the rollout file to use (DIR: a case folder or empty)
# det_pol25_cfg [DIR]    path of POL25.yml to use ($POL25_CFG, else <case>/POL25.yml, else policies/POL25.yml)
# det_case DIR           true when DIR is a case folder (holds a rollout.yml)
# det_case_files DIR     workflow files in a case folder, one per line: *.md (not README.md), *.yml, *.yaml,
#                        minus rollout.yml, POL25.yml and minus an X.lock.yml beside X.md (one workflow, two files)
# det_map_err ROLLOUT    why the file or its deterministic_triggers key is unusable, empty when fine
#                        (missing key = empty map; a list, string, null or parse error is an error)
# det_listed ROLLOUT NAME     true when NAME (file basename) is a key in the map
# det_entry_err ROLLOUT NAME  why NAME's entry is invalid, empty when fine: map, triggers a list of
#                             strings, yes.date and yes.quote non-empty after trim
# det_entry_triggers ROLLOUT NAME  the entry's triggers, one per line
# det_agentic FILE       true for a .md, a *.lock.yml or a yml with a gh-aw-metadata header

det_case() { [ -d "$1" ] && [ -f "${1%/}/rollout.yml" ]; }

det_rollout() {
  if [ -n "${POL_ROLLOUT:-}" ]; then echo "$POL_ROLLOUT"
  elif [ -n "${1:-}" ] && det_case "$1"; then echo "${1%/}/rollout.yml"
  else echo "$POL_ROOT/governance/rollout.yml"; fi
}

det_pol25_cfg() {
  if [ -n "${1:-}" ] && det_case "$1" && [ -f "${1%/}/POL25.yml" ]; then echo "${1%/}/POL25.yml"
  elif [ -n "${POL25_CFG:-}" ]; then echo "$POL25_CFG"
  else echo "$POL_ROOT/policies/POL25.yml"; fi
}

det_case_files() {
  local d=${1%/} f b
  for f in "$d"/*; do
    [ -f "$f" ] || continue; b=$(basename "$f")
    case "$b" in
      rollout.yml|POL25.yml|README.md) continue ;;
      *.lock.yml) [ -e "$d/${b%.lock.yml}.md" ] && continue; echo "$f" ;;
      *.md|*.yml|*.yaml) echo "$f" ;;
    esac
  done
}

det_map_err() {
  local r=$1 tag
  [ -f "$r" ] || { echo "rollout file $(rel "$r") is missing (fail closed)"; return; }
  tag=$(yq '.deterministic_triggers | tag' "$r" 2>/dev/null) || { echo "rollout file $(rel "$r") does not parse (fail closed)"; return; }
  case "$tag" in
    '!!map') ;;
    '!!null') [ "$(yq 'has("deterministic_triggers")' "$r" 2>/dev/null)" = true ] && echo "deterministic_triggers in $(rel "$r") is null, must be a map (fail closed)" ;;
    *) echo "deterministic_triggers in $(rel "$r") is ${tag#!!}, must be a map (fail closed)" ;;
  esac
}

det_listed() { [ "$(K=$2 yq '(.deterministic_triggers // {}) | has(strenv(K))' "$1" 2>/dev/null)" = true ]; }

det_entry_err() {
  local r=$1 e="deterministic_triggers entry $2"
  [ "$(K=$2 yq '.deterministic_triggers[strenv(K)] | tag' "$r")" = '!!map' ] || { echo "$e is not a map (fail closed)"; return; }
  if [ "$(K=$2 yq '.deterministic_triggers[strenv(K)].triggers | tag' "$r")" != '!!seq' ] \
    || [ "$(K=$2 yq '.deterministic_triggers[strenv(K)].triggers | length' "$r")" = 0 ] \
    || [ "$(K=$2 yq '[.deterministic_triggers[strenv(K)].triggers[] | select(tag != "!!str")] | length' "$r")" != 0 ] \
    || [ "$(K=$2 yq '[.deterministic_triggers[strenv(K)].triggers[] | tostring | trim | select(. == "")] | length' "$r")" != 0 ]; then
    echo "$e: triggers must be a non-empty list of trigger names (fail closed)"
  fi
  [ -n "$(K=$2 yq '.deterministic_triggers[strenv(K)].yes.date | select(. != null) | select(tag == "!!str" or tag == "!!timestamp") | tostring | trim' "$r")" ] \
    || echo "$e: yes.date is empty (Sven's exact yes needs a date)"
  [ -n "$(K=$2 yq '.deterministic_triggers[strenv(K)].yes.quote | select(tag == "!!str") | trim' "$r")" ] \
    || echo "$e: yes.quote is empty (Sven's exact yes needs his words)"
}

det_entry_triggers() { K=$2 yq '.deterministic_triggers[strenv(K)].triggers[]' "$1" 2>/dev/null; }

det_agentic() {
  case "$1" in
    *.md|*.lock.yml) return 0 ;;
  esac
  sed $'1s/^\xEF\xBB\xBF//' "$1" | awk '
    /^[[:space:]]*#/ {
      if ($0 ~ /gh-aw-metadata:/) { found=1; exit 0 }
    }
    END { exit found ? 0 : 1 }'
}
