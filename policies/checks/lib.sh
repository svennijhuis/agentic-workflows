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

# shape_hits FILE ID (VF02d1 round 2): the gate job is a key allowlist, not a denylist (Tester 6424839165,
#   Cursor 5657508090 f1 to f6). A YAML anchor or alias anywhere is one hit. Then, on the exploded map:
#   top-level keys only name, run-name, on, permissions, concurrency, jobs, env, defaults; permissions exactly
#   contents: read (workflow, and job when set); job keys only name, runs-on (ubuntu-latest), timeout-minutes,
#   permissions, steps, defaults, env (so no if, container, services, uses, outputs, strategy); step keys only
#   name, id, uses, with, run, env, shell, timeout-minutes (so no if or working-directory); continue-on-error
#   anywhere is a hit; shell: (step, job or workflow defaults.run) only bash, sh or bash --noprofile --norc
#   -eo pipefail {0}; defaults only run.shell; every env: is a plain map whose only entry is
#   GH_TOKEN: ${{ github.token }} (no LD_*, BASH_FUNC_*, PATH, fromJSON); uses: only actions/checkout@<40 hex>,
#   one such step per workflow, with: only persist-credentials: false and fetch-depth. Hits on one step or
#   job are joined into one line.
read -r -d '' SHAPE_JQ <<'JQ' || true
def shell_msgs: if . == null or . == "bash" or . == "sh" or . == "bash --noprofile --norc -eo pipefail {0}" then []
  else ["shell: \(.) is not bash, sh or bash --noprofile --norc -eo pipefail {0}, so the step may not run its lines with -e"] end;
def env_msgs: if type != "object" then ["env: is not a plain map (an expression such as fromJSON can set any variable)"]
  else [to_entries[] | select(.key != "GH_TOKEN" or .value != "${{ github.token }}")
    | "env: \(.key) is not allowed; the only env entry is GH_TOKEN: ${{ github.token }} (LD_*, BASH_FUNC_*, PATH and expressions can change what the step runs)"] end;
def defaults_msgs: if type != "object" then ["defaults: is not a map"] else
  [keys[] | select(. != "run") | "defaults.\(.) is not allowed"]
  + (if has("run") then (.run | if type != "object" then ["defaults.run is not a map"] else
      [keys[] | select(. != "shell") | if . == "working-directory" then "defaults.run.working-directory is set, so the gate may run another scripts/verify.sh" else "defaults.run.\(.) is not allowed" end]
      + (.shell | shell_msgs) end) else [] end) end;
def coe: "continue-on-error is set (\(.)), so a failed check does not fail the job";
def perm: if . == {"contents": "read"} then [] else ["permissions must be exactly contents: read"] end;
def step_msgs: if type != "object" then ["step is not a map"] else . as $s |
  [keys[] | select(test("^(name|id|uses|with|run|env|shell|timeout-minutes|__line)$") | not)
    | if . == "if" then "step if: is set, so the step may be skipped and the job still passes"
      elif . == "working-directory" then "working-directory is set, so the step may run another scripts/verify.sh"
      elif . == "continue-on-error" then ($s[.] | coe)
      else "step key \(.) is not allowed in a gate workflow" end]
  + (if has("uses") then
      (if (.uses | type) == "string" and (.uses | test("^actions/checkout@[0-9a-f]{40}$")) then [] else ["uses: \(.uses) is not actions/checkout@<40 hex>; gate only through ./scripts/verify.sh"] end)
      + (if (.with | type) != "object" then ["checkout has no with: persist-credentials: false"] else
          [.with | keys[] | select(. != "persist-credentials" and . != "fetch-depth") | "checkout with: \(.) is not allowed (only persist-credentials: false and fetch-depth), so it may check out other code"]
          + (if .with["persist-credentials"] == false then [] else ["checkout must set with: persist-credentials: false"] end)
          + (if (.with | has("fetch-depth")) and ((.with["fetch-depth"] | type) != "number") then ["checkout fetch-depth is not a number"] else [] end) end)
    elif has("with") then ["with: on a step without uses:"] else [] end)
  + (if has("env") then (.env | env_msgs) else [] end)
  + (.shell | shell_msgs) end;
def job_msgs($j): if type != "object" then ["job \($j) is not a map"] else . as $v |
  [keys[] | select(test("^(name|runs-on|timeout-minutes|permissions|steps|defaults|env|__line)$") | not)
    | if . == "if" then "job \($j) if: is set, so the job may be skipped and the run still passes"
      elif . == "container" or . == "services" then "job \($j) sets \(.), so the gate may run inside or beside another image"
      elif . == "continue-on-error" then ($v[.] | coe)
      else "job \($j) key \(.) is not allowed in a gate workflow" end]
  + (if .["runs-on"] == "ubuntu-latest" then [] else ["job \($j) runs-on must be ubuntu-latest"] end)
  + (if has("permissions") then (.permissions | perm | map("job \($j) " + .)) else [] end)
  + (if has("defaults") then (.defaults | defaults_msgs | map("job \($j) " + .)) else [] end)
  + (if has("env") then (.env | env_msgs | map("job \($j) " + .)) else [] end)
  + (if (.steps | type) == "array" then [] else ["job \($j) steps: is not a list"] end) end;
. as $d
| ([keys[] | select(test("^(name|run-name|on|permissions|concurrency|jobs|env|defaults|__line)$") | not) | {k: ., m: "top-level key \(.) is not allowed in a gate workflow"}]
  + [(.permissions | perm)[] | {k: "permissions", m: .}]
  + (if has("env") then [(.env | env_msgs)[] | {k: "env", m: .}] else [] end)
  + (if has("defaults") then [(.defaults | defaults_msgs)[] | {k: "defaults", m: .}] else [] end)
  + (if (.jobs | type) != "object" then [{k: "jobs", m: "jobs: is not a map"}] else
      [.jobs | to_entries[] | .key as $j | .value as $v | (($v | objects | .__line) // 1) as $l
        | ([($v | job_msgs($j))[] | {l: $l, m: .}]
           + [($v | objects | .steps | arrays | .[]) | ((objects | .__line) // $l) as $sl | (step_msgs[] | {l: $sl, m: .})])[]]
      + [[.jobs[] | objects | .steps | arrays | .[] | objects | select(has("uses")) | .__line] | .[1:][] | {l: ., m: "second uses: step (one actions/checkout per workflow), so another checkout may replace scripts/verify.sh"}]
    end))
| .[] | "\(.l // ("key:" + .k))\u001f\(.m)"
JQ

shape_hits() {
  local f=$1 id=$2 r l m k; r=$(rel "$f")
  l=$(yq '[.. | select(anchor != "" or tag == "")] | .[0] | line' "$f" 2>/dev/null)
  if [ -n "$l" ] && [ "$l" != null ] && [ "$l" != 0 ]; then hit "$r" "$l" "$id" "YAML anchor or alias, so a value may come from a node no check reads"; fi
  local js rows
  js=$(yq -o json -I0 'explode(.) | .__line = 1 | with(.jobs | select(tag == "!!map") | .[] | select(tag == "!!map"); .__line = line) | with(.jobs | select(tag == "!!map") | .[] | select(tag == "!!map") | .steps | select(tag == "!!seq") | .[] | select(tag == "!!map"); .__line = line)' "$f" 2>/dev/null) \
    && [ "$(jq -r type <<<"$js" 2>/dev/null)" = object ] && rows=$(jq -r "$SHAPE_JQ" <<<"$js" 2>/dev/null) \
    || { hit "$r" 1 "$id" "workflow shape unreadable (not a YAML map, or the shape check failed), fail closed"; return; }
  while IFS=$'\037' read -r l m; do [ -n "$l" ] && hit "$r" "$l" "$id" "$m"; done < <(
    while IFS=$'\037' read -r l m; do
      [ -n "$l" ] || continue
      case "$l" in key:*) k=${l#key:}; l=$(grep -nE -m1 "^${k}:" "$f" | cut -d: -f1); l=${l:-1} ;; esac
      printf '%s\037%s\n' "$l" "$m"
    done <<<"$rows" \
      | awk -F '\037' '{ if (!($1 in m)) { o[++n] = $1; m[$1] = $2 } else m[$1] = m[$1] "; " $2 } END { for (i = 1; i <= n; i++) printf "%s\037%s\n", o[i], m[o[i]] }')
  return 0
}

