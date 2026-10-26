#!/usr/bin/env bash
# VF02d1 proof for POL28 run_allow, run in temp copies of the tree (offline, no writes here).
# Fail closed: a missing, empty, non-list or broken run_allow makes POL28 exit 1. Mutation: run_allow
# [".*"] makes POL23 report the allowlist-only POL28 bad cases as passing (the allowlist is load bearing).
# Prints `file:line POL28T message` per failed case and `N failures`; exit 0 only when N is 0.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 2
N=0; C=policies/POL28.yml

# case_ NAME CMD WANT_EXIT SETUP WANT_TEXT...: run CMD in a fresh copy after SETUP; every WANT_TEXT must show
case_() {
  local name=$1 cmd=$2 want=$3 setup=$4 t out rc x bad=""
  shift 4
  t=$(mktemp -d)
  git ls-files -co --exclude-standard -z | xargs -0 cp --parents -t "$t"
  out=$(cd "$t" && eval "$setup" && bash "$cmd" 2>&1); rc=$?
  rm -rf "$t"
  for x in "$@"; do grep -qF -- "$x" <<<"$out" || bad="$bad '$x'"; done
  if [ "$rc" -ne "$want" ] || [ -n "$bad" ]; then
    echo "scripts/test-POL28-allow.sh:1 POL28T $name: want exit $want with$bad, got exit $rc: ${out//$'\n'/ | }"; N=$((N + 1))
  else echo "ok $name (exit $rc)"; fi
}

P=policies/checks/POL28.sh
case_ baseline "$P" 0 ':'
case_ allow-deleted "$P" 1 "yq -i 'del(.run_allow)' $C" 'POL28 run_allow missing or not a list (fail closed)'
case_ allow-empty "$P" 1 "yq -i '.run_allow = []' $C" 'POL28 run_allow empty (fail closed)'
case_ allow-string "$P" 1 "yq -i '.run_allow = \".*\"' $C" 'POL28 run_allow missing or not a list (fail closed)'
case_ allow-null "$P" 1 "yq -i '.run_allow = null' $C" 'POL28 run_allow missing or not a list (fail closed)'
case_ allow-blank-entry "$P" 1 "yq -i '.run_allow = [\"\"]' $C" 'POL28 run_allow entry is not a non-empty regex string (fail closed)'
case_ allow-bad-regex "$P" 1 "yq -i '.run_allow = [\"(\"]' $C" 'POL28 run_allow entry is not a valid regex'
case_ config-broken "$P" 1 "printf 'run_allow: [\n' >> $C" 'POL28 run_allow unreadable (yq error)'
M=()
for b in ci-unknown-run.yml ci-bash-c-actionlint.yml ci-if-actionlint.yml ci-go-run-actionlint.yml ci-npx-shellcheck.yml \
  ci-sudo-u-root-actionlint.yml ci-env-u-path-actionlint.yml ci-xargs-i-actionlint.yml ci-yaml-actionlint.yaml; do
  M+=("POL23 POL28 passes bad case $b (tautological)")
done
case_ mutation-allow-all policies/checks/POL23.sh 1 "yq -i '.run_allow = [\".*\"]' $C" "${M[@]}"
echo "$N failures"
[ "$N" -eq 0 ]
