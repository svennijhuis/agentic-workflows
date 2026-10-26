#!/usr/bin/env bash
# Shared helpers for policies/checks/POLnn.sh. Read-only: no network, no writes outside mktemp.
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

# q FILE EXPR: yq query on the frontmatter (null-safe, prints nothing for null)
q() { fm "$1" | yq -p yaml -o yaml "$2 // \"\"" 2>/dev/null | sed '/^""$/d;/^$/d'; }

# qline FILE EXPR: line number in FILE of the node EXPR selects (frontmatter offset +1), 1 when absent
qline() {
  local l; l=$(fm "$1" | yq -p yaml "($2) | line" 2>/dev/null | head -1)
  if [ -n "$l" ] && [ "$l" != "0" ] && [ "$l" != "null" ]; then echo $((l + 1)); else echo 1; fi
}

# gline FILE REGEX: first line matching REGEX (grep -E), 1 when none
gline() { local l; l=$(grep -nE -m1 -- "$2" "$1" | cut -d: -f1); echo "${l:-1}"; }

# is_workflow FILE: has frontmatter with an `on:` key (shared fragments have none)
is_workflow() { [ "$(fm "$1" | yq -p yaml 'has("on")' 2>/dev/null)" = "true" ]; }

# polcfg ID EXPR: read a value from policies/POLnn.yml
polcfg() { yq "$2" "$POL_ROOT/policies/$1.yml"; }

# Safe-output keys that are settings, not outputs (POL08, POL03 use this).
SO_SETTINGS='staged threat-detection github-token allowed-domains allowed-github-references env footer messages runs-on max-patch-size mentions jobs app concurrency-group report-failure-as-issue id-token group-reports'
is_so_setting() { case " $SO_SETTINGS " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

# so_outputs FILE: safe-output keys that are real outputs
so_outputs() { local k; for k in $(q "$1" '.["safe-outputs"] | select(tag == "!!map") | keys | .[]'); do is_so_setting "$k" || echo "$k"; done; }

# fline FILE TEXT: first line containing TEXT literally, 1 when none
fline() { local l; l=$(grep -nF -m1 -- "$2" "$1" | cut -d: -f1); echo "${l:-1}"; }

# repo_mode ARGS...: true when the check runs on the default catalog (no args)
repo_mode() { [ $# -eq 0 ]; }
