#!/usr/bin/env bash
# POL28 one verify entry point (VF01).
# Roots (repo mode, a missing root or an empty scan is a hit): .github/workflows/*.yml (not *.lock.yml),
#   AGENTS.md, CONTRIBUTING.md, .github/copilot-instructions.md, .github/skills/verify-aw/SKILL.md.
# Args: files, or folders scanned for files. A *.yml (not *.lock.yml or *.card.yml) is a workflow;
#   a *.md whose name starts with agents, contributing, copilot-instructions or skill (any case) is an
#   agent surface. Any other file is not a POL28 root: no line, exit 0. A missing root is not a hit here.
# Workflow: no step runs gh aw compile, actionlint or shellcheck itself; a step that runs verify.sh runs
#   ./scripts/verify.sh and nothing else; a verify*.yml has that step. Agent surface: names scripts/verify.sh.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
command -v jq >/dev/null 2>&1 || { echo "policies/checks/POL28.sh:1 VERIFY needs-human missing: jq"; exit 2; }
GATE='./scripts/verify.sh'
ADHOC='(^|&&|;|\||\$\()[[:space:]]*(gh aw compile|actionlint|shellcheck)([[:space:]]|$)'

check_workflow() { # FILE
  local f=$1 r steps n i line run has_gate=0; r=$(rel "$f")
  if ! steps=$(yq -o json -I0 '[(.jobs // {}) | .[] | (.steps // []) | .[] | select(has("run")) | {"line": (.run | line), "run": .run}]' "$f" 2>/dev/null) \
    || [ "$(yq 'tag' "$f" 2>/dev/null)" != '!!map' ]; then
    hit "$r" 1 POL28 "parse error: not a YAML workflow"; return
  fi
  n=$(jq length <<<"$steps")
  for ((i = 0; i < n; i++)); do
    line=$(jq -r ".[$i].line" <<<"$steps"); run=$(jq -r ".[$i].run" <<<"$steps")
    if grep -qE -- "$ADHOC" <<<"$run"; then
      hit "$r" "$line" POL28 "ad hoc gate step ($(grep -oE -m1 -- "$ADHOC" <<<"$run" | sed -E 's/^[^a-z]*//;s/[[:space:]]*$//')); gate only through $GATE"
    fi
    if grep -q 'verify\.sh' <<<"$run"; then
      if [ "$(sed -E 's/^[[:space:]]+//;s/[[:space:]]+$//' <<<"$run" | sed '/^$/d')" = "$GATE" ]; then has_gate=1
      else hit "$r" "$line" POL28 "gate step must run $GATE and nothing else"; fi
    fi
  done
  case "$(basename "$f")" in
    verify*.yml) [ "$has_gate" = 1 ] || hit "$r" 1 POL28 "verify workflow has no step that runs $GATE" ;;
  esac
}

check_surface() { # FILE
  grep -qF 'scripts/verify.sh' "$1" || hit "$(rel "$1")" 1 POL28 "agent surface does not name scripts/verify.sh"
}

check_file() { # FILE
  local b; b=$(basename "$1")
  case "$b" in
    *.lock.yml | *.card.yml) ;;
    *.yml) check_workflow "$1" ;;
    *.md) case "$(tr '[:upper:]' '[:lower:]' <<<"$b")" in agents* | contributing* | copilot-instructions* | skill*) check_surface "$1" ;; esac ;;
  esac
}

if repo_mode "$@"; then
  cd "$POL_ROOT" || exit 2
  mapfile -t wfs < <(find .github/workflows -maxdepth 1 -name '*.yml' ! -name '*.lock.yml' 2>/dev/null | sort)
  [ "${#wfs[@]}" -gt 0 ] || hit .github/workflows 1 POL28 "root missing or empty: no workflow to scan"
  for f in "${wfs[@]}"; do [ -s "$f" ] || { hit "${f#./}" 1 POL28 "root empty"; continue; }; check_workflow "${f#./}"; done
  for f in AGENTS.md CONTRIBUTING.md .github/copilot-instructions.md .github/skills/verify-aw/SKILL.md; do
    if [ -s "$f" ]; then check_surface "$f"; else hit "$f" 1 POL28 "root missing or empty"; fi
  done
else
  for a in "$@"; do
    if [ -d "$a" ]; then while IFS= read -r f; do check_file "$f"; done < <(find "$a" -type f | sort)
    else check_file "$a"; fi
  done
fi
pol_done
