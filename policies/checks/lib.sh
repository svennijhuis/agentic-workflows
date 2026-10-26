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

# run_lines FILE: one row per shell line of every step run: in every job (VF02d1), fields split by
#   \x1f: JOB STEP LINE TOP TEXT. Blank lines and comments are dropped and TEXT is trimmed. TOP is 0
#   once an earlier line of the same run: block opened if, then, else, elif, case, while, until, for,
#   do, select, a { or ( group, a heredoc (<<) or ended in a \ continuation; else 1. Prints nothing
#   when FILE does not parse (the caller reports the parse error).
run_lines() {
  # shellcheck disable=SC2016 # $j is a yq variable, not a shell one
  yq -o json -I0 '[(.jobs // {}) | to_entries | .[] | .key as $j | (.value.steps // []) | to_entries | .[] | select(.value | has("run")) | {"job": $j, "step": .key, "line": (.value.run | line), "block": ((.value.run | style) == "literal" or (.value.run | style) == "folded"), "run": (.value.run | tostring)}]' "$1" 2>/dev/null \
    | jq -r '.[] | . as $s | ($s.run | split("\n")) | to_entries[] | "\($s.job)\u001f\($s.step)\u001f\($s.line + .key + (if $s.block then 1 else 0 end))\u001f\(.value)"' \
    | awk -F '\037' -v OFS='\037' '
        { k = $1 OFS $2; if (k != cur) { cur = k; open = 0; cont = 0 }
          t = $4; sub(/(^|[[:space:]])#.*$/, "", t); gsub(/^[[:space:]]+|[[:space:]]+$/, "", t)
          if (t == "") next
          top = (open || cont) ? 0 : 1
          print $1, $2, $3, top, t
          if (t ~ /^(if|then|else|elif|case|while|until|for|do|select|function)([[:space:];(]|$)/ || t ~ /^[{(]/ || t ~ /<</) open = 1
          cont = (t ~ /\\$/) ? 1 : 0 }'
}

# errexit_hits FILE ID: hit when a step or job sets continue-on-error (any value), or a step shell:,
#   job defaults.run.shell or workflow defaults.run.shell is set and not bash or sh (both run with -e
#   on GitHub) and names no -e flag or errexit, or names a +e flag (Cursor 5655973880 medium 3). An env:
#   (workflow, job or step) that sets PATH, BASH_ENV, ENV, SHELLOPTS or BASHOPTS is a hit too: it can
#   swap sha256sum or turn errexit off before the first line runs.
errexit_hits() {
  local f=$1 id=$2 r l k v; r=$(rel "$f")
  while read -r l k v; do
    [ -n "$l" ] || continue
    case "$k" in PATH | BASH_ENV | ENV | SHELLOPTS | BASHOPTS) hit "$r" "$l" "$id" "env: sets $k, so the step may not run the commands or errexit it shows"; continue ;; esac
    if [ "$k" = continue-on-error ]; then hit "$r" "$l" "$id" "continue-on-error is set ($v), so a failed check does not fail the job"; continue; fi
    case "$v" in bash | sh) continue ;; esac
    if grep -qE -- '(^|[[:space:]])(-[A-Za-z]*e[A-Za-z]*|-o[[:space:]]+errexit)([[:space:]]|$)' <<<"$v" && ! grep -qE -- '(^|[[:space:]])\+[A-Za-z]*e' <<<"$v"; then continue; fi
    hit "$r" "$l" "$id" "shell: $v runs without -e, so a failed command does not stop the step"
  done < <(yq '[.. | select((path | join(".")) | test("^((env|jobs\\.[^.]+\\.env|jobs\\.[^.]+\\.steps\\.[0-9]+\\.env)\\.(PATH|BASH_ENV|ENV|SHELLOPTS|BASHOPTS)|defaults\\.run\\.shell|jobs\\.[^.]+\\.(continue-on-error|defaults\\.run\\.shell|steps\\.[0-9]+\\.(continue-on-error|shell)))$"))] | .[] | (line | tostring) + " " + (key | tostring) + " " + (. | tostring)' "$f" 2>/dev/null)
}
