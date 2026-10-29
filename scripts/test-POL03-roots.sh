#!/usr/bin/env bash
# SM05a round 2 repo-mode proof for POL03, run in temp copies of the tree (offline, no writes here).
# Covers what POL23 cannot (it runs fixtures in file mode): the .github/workflows *.yaml and *.lock.yml walk,
# orphan locks under workflows/, $POL_ROLLOUT ignored in repo mode, and promoted: exact match.
# Prints `file:line POL03T message` per failed case and `N failures`; exit 0 only when N is 0.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 2
N=0; R=governance/rollout.yml

# case NAME WANT_EXIT WANT_TEXT SETUP: run POL03 repo mode in a fresh copy after SETUP
case_() {
  local name=$1 want=$2 text=$3 setup=$4 t out rc
  t=$(mktemp -d)
  git ls-files -co --exclude-standard -z | xargs -0 cp --parents -t "$t"
  out=$(cd "$t" && eval "$setup" && bash policies/checks/POL03.sh 2>&1); rc=$?
  rm -rf "$t"
  if [ "$rc" -ne "$want" ] || ! grep -qF -- "$text" <<<"$out"; then
    echo "scripts/test-POL03-roots.sh:1 POL03T $name: want exit $want with '$text', got exit $rc: ${out//$'\n'/ | }"; N=$((N + 1))
  else echo "ok $name (exit $rc)"; fi
}

# W TRIGGER: a plain workflow on workflow_dispatch plus TRIGGER; M: the gh-aw-metadata header of a lock
W='printf "name: probe\non:\n  workflow_dispatch:\n  %s:\njobs:\n  p:\n    runs-on: ubuntu-latest\n    steps:\n      - run: echo probe\n"'
M='printf "# gh-aw-metadata: {\"fixture\":true}\n"'

case_ baseline 0 '' ':'
case_ yaml-push 1 ".github/workflows/probe.yaml:2 POL03 trigger 'push' needs a governance/rollout.yml promotion" \
  "$W push > .github/workflows/probe.yaml"
case_ yml-push 1 ".github/workflows/probe.yml:2 POL03 trigger 'push' needs a governance/rollout.yml promotion" \
  "$W push > .github/workflows/probe.yml"
case_ yaml-dispatch 0 '' "$W workflow_dispatch > .github/workflows/probe.yaml"
case_ lock-call 1 ".github/workflows/probe.lock.yml:3 POL03 agentic workflow never gets 'workflow_call'" \
  "{ $M; $W workflow_call; } > .github/workflows/probe.lock.yml"
case_ lock-deployment-status 1 ".github/workflows/probe.lock.yml:3 POL03 trigger 'deployment_status' always fails" \
  "{ $M; $W deployment_status; } > .github/workflows/probe.lock.yml"
case_ orphan-lock-in-workflows 1 "workflows/probe.lock.yml:3 POL03 agentic workflow never gets 'workflow_call'" \
  "{ $M; $W workflow_call; } > workflows/probe.lock.yml"
case_ paired-lock-in-workflows 1 "workflows/squad-review.lock.yml:" \
  "f=workflows/squad-review.lock.yml && yq -i '.on.workflow_call = null' \$f"
case_ rollout-env-ignored 1 ".github/workflows/probe.yaml:2 POL03 trigger 'push' needs a governance/rollout.yml promotion" \
  "$W push > .github/workflows/probe.yaml && printf 'promoted: [probe]\n' > /tmp/pol03t-rollout.yml && export POL_ROLLOUT=/tmp/pol03t-rollout.yml"
case_ promoted-exact 0 '' "$W push > .github/workflows/probe.yaml && yq -i '.promoted = [\"probe\"]' $R"
case_ promoted-prefix-only 1 "POL03 trigger 'push' needs a governance/rollout.yml promotion" \
  "$W push > .github/workflows/probe.yaml && yq -i '.promoted = [\"probe-extra\"]' $R"
rm -f /tmp/pol03t-rollout.yml

echo "$N failures"
[ "$N" -eq 0 ]
