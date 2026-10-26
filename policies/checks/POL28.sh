#!/usr/bin/env bash
# POL28 one verify entry point (VF01).
# Roots (repo mode, a missing root or an empty scan is a hit): .github/workflows/*.yml and *.yaml (not
#   *.lock.yml), AGENTS.md, CONTRIBUTING.md, .github/copilot-instructions.md, .github/skills/verify-aw/SKILL.md.
# Args: files, or folders scanned for files. A *.yml or *.yaml (not *.lock.yml or *.card.yml) is a workflow;
#   a *.md whose name starts with agents, contributing, copilot-instructions or skill (any case) is an
#   agent surface. Any other file is not a POL28 root: no line, exit 0. A missing root is not a hit here.
# Workflow (VF02d1, allowlist, not a denylist): every shell line of every step run: in every job (split by
#   run_lines in lib.sh: comments and blanks dropped) must match one regex of run_allow: in
#   policies/POL28.yml as a whole line, and anything else (bash -c, if, go run, npx, make, sudo -u root
#   actionlint and the rest) is a hit. A missing, empty or non-list run_allow, or an entry that is not a
#   non-empty string, is a hit (fail closed). Every uses: (step or job) is actions/checkout@<40 hex>. No
#   step or job sets continue-on-error or a shell without -e. A step that runs verify.sh runs
#   ./scripts/verify.sh and nothing else; a verify*.yml or verify*.yaml has that step.
#   Agent surface: names scripts/verify.sh.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
command -v jq >/dev/null 2>&1 || { echo "policies/checks/POL28.sh:1 VERIFY needs-human missing: jq"; exit 2; }
GATE='./scripts/verify.sh'
CFG="$POL_ROOT/policies/POL28.yml"
ALLOW=()

load_allow() { # fills ALLOW from run_allow:, a hit when it is missing, empty, not a list or has a bad entry
  local l t; l=$(fline "$CFG" 'run_allow:')
  if ! t=$(yq '.run_allow | tag' "$CFG" 2>/dev/null); then hit policies/POL28.yml 1 POL28 "run_allow unreadable (yq error)"; return; fi
  [ "$t" = '!!seq' ] || { hit policies/POL28.yml "$l" POL28 "run_allow missing or not a list (fail closed)"; return; }
  [ "$(yq '.run_allow | length' "$CFG")" -gt 0 ] || { hit policies/POL28.yml "$l" POL28 "run_allow empty (fail closed)"; return; }
  [ "$(yq '[.run_allow[] | select(tag != "!!str" or . == "")] | length' "$CFG")" -eq 0 ] \
    || { hit policies/POL28.yml "$l" POL28 "run_allow entry is not a non-empty regex string (fail closed)"; return; }
  mapfile -t ALLOW < <(yq '.run_allow[]' "$CFG")
  local a; for a in "${ALLOW[@]}"; do
    grep -qE -- "$a" <<<"" ; [ $? -le 1 ] || { hit policies/POL28.yml "$l" POL28 "run_allow entry is not a valid regex: $a"; ALLOW=(); return; }
  done
}

allowed() { # TEXT: true when TEXT matches one run_allow regex as a whole line
  local a args=(); [ "${#ALLOW[@]}" -gt 0 ] || return 1
  for a in "${ALLOW[@]}"; do args+=(-e "$a"); done
  grep -qxE "${args[@]}" <<<"$1"
}

check_workflow() { # FILE
  local f=$1 r steps n i line run u l txt has_gate=0; r=$(rel "$f")
  if ! steps=$(yq -o json -I0 '[(.jobs // {}) | .[] | (.steps // []) | .[] | select(has("run")) | {"line": (.run | line), "run": .run}]' "$f" 2>/dev/null) \
    || [ "$(yq 'tag' "$f" 2>/dev/null)" != '!!map' ]; then
    hit "$r" 1 POL28 "parse error: not a YAML workflow"; return
  fi
  while read -r line u; do
    [ -n "$line" ] && hit "$r" "$line" POL28 "uses: $u is not actions/checkout@<40 hex>; gate only through $GATE"
  done < <(yq '[(.jobs // {}) | .[] | (., ((.steps // []) | .[])) | select(has("uses")) | select(.uses | test("^actions/checkout@[0-9a-f]{40}$") | not)] | .[] | (.uses | line | tostring) + " " + .uses' "$f" 2>/dev/null)
  errexit_hits "$f" POL28
  while IFS=$'\037' read -r _ _ l _ txt; do
    [ -n "$l" ] || continue
    allowed "$txt" || hit "$r" "$l" POL28 "run line is not in run_allow (policies/POL28.yml): $txt"
  done < <(run_lines "$f")
  n=$(jq length <<<"$steps")
  for ((i = 0; i < n; i++)); do
    line=$(jq -r ".[$i].line" <<<"$steps"); run=$(jq -r ".[$i].run" <<<"$steps")
    if grep -q 'verify\.sh' <<<"$run"; then
      if [ "$(sed -E 's/^[[:space:]]+//;s/[[:space:]]+$//' <<<"$run" | sed '/^$/d')" = "$GATE" ]; then has_gate=1
      else hit "$r" "$line" POL28 "gate step must run $GATE and nothing else"; fi
    fi
  done
  case "$(basename "$f")" in
    verify*.yml | verify*.yaml) [ "$has_gate" = 1 ] || hit "$r" 1 POL28 "verify workflow has no step that runs $GATE" ;;
  esac
}

check_surface() { # FILE
  grep -qF 'scripts/verify.sh' "$1" || hit "$(rel "$1")" 1 POL28 "agent surface does not name scripts/verify.sh"
}

check_file() { # FILE
  local b; b=$(basename "$1")
  case "$b" in
    *.lock.yml | *.lock.yaml | *.card.yml) ;;
    *.yml | *.yaml) check_workflow "$1" ;;
    *.md) case "$(tr '[:upper:]' '[:lower:]' <<<"$b")" in agents* | contributing* | copilot-instructions* | skill*) check_surface "$1" ;; esac ;;
  esac
}

load_allow
if repo_mode "$@"; then
  cd "$POL_ROOT" || exit 2
  mapfile -t wfs < <(find .github/workflows -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) ! -name '*.lock.yml' ! -name '*.lock.yaml' 2>/dev/null | sort)
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
