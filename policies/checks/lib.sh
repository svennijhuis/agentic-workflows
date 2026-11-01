#!/usr/bin/env bash
# Shared helpers for policies/checks/POL25.sh and POL31.sh. Read-only: no network, no writes outside mktemp.
# Contract: each check prints `file:line POLnn message` per hit and exits 1 when it found any,
# 0 when clean, 2 (with a `VERIFY needs-human` line) when it cannot run.
set -u

POL_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
HITS=0

for _a in "$@"; do [ -e "$_a" ] || { echo "$_a:1 VERIFY needs-human no such path"; exit 2; }; done

command -v yq >/dev/null 2>&1 || { echo "policies/checks/lib.sh:1 VERIFY needs-human missing: yq"; exit 2; }

# hit FILE LINE ID MESSAGE
hit() { echo "$1:$2 $3 $4"; HITS=$((HITS + 1)); }

pol_done() { [ "$HITS" -eq 0 ] || exit 1; exit 0; }

# rel FILE: path relative to the repo root when inside it
rel() { local p; p=$(realpath -m "$1"); case "$p" in "$POL_ROOT"/*) echo "${p#"$POL_ROOT"/}" ;; *) echo "$1" ;; esac; }

# targets ARGS...: markdown files to check. Default is the catalog (workflows/, incl. shared/).
# Dirs expand to *.md below them. README.md files are docs, not workflows.
targets() {
  local a
  [ $# -eq 0 ] && set -- "$POL_ROOT/workflows"
  for a in "$@"; do
    if [ -d "$a" ]; then find "$a" -name '*.md' ! -name 'README.md' | sort
    elif [ -f "$a" ]; then echo "$a"
    else echo "$a:1 VERIFY no such path" >&2; fi
  done
}

# fm FILE: frontmatter text (between the first two --- lines), empty when none
fm() { awk 'NR==1 && $0!="---" {exit} NR==1 {next} $0=="---" {exit} {print}' "$1"; }

# is_workflow FILE: has frontmatter with an `on:` key (shared fragments have none)
is_workflow() { [ "$(fm "$1" | yq -p yaml 'has("on")' 2>/dev/null)" = "true" ]; }

# repo_mode ARGS...: true when the check runs on the default catalog (no args)
repo_mode() { [ $# -eq 0 ]; }
