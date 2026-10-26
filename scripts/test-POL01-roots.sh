#!/usr/bin/env bash
# VF02a repo-mode proof for POL01 yml_roots, run in temp copies of the tree (offline, no writes here).
# Prints `file:line POL01T message` per failed case and `N failures`; exit 0 only when N is 0.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 2
N=0; V=.github/workflows/verify.yml; C=policies/POL01.yml

# case NAME WANT_EXIT WANT_TEXT SETUP [WANT_HITS]: run POL01 repo mode in a fresh copy after SETUP
case_() {
  local name=$1 want=$2 text=$3 setup=$4 hits=${5:-} t out rc
  t=$(mktemp -d)
  git ls-files -co --exclude-standard -z | xargs -0 cp --parents -t "$t"
  out=$(cd "$t" && eval "$setup" && bash policies/checks/POL01.sh 2>&1); rc=$?
  rm -rf "$t"
  if [ "$rc" -ne "$want" ] || ! grep -qF -- "$text" <<<"$out" || { [ -n "$hits" ] && [ "$(grep -c ' POL01 ' <<<"$out")" -ne "$hits" ]; }; then
    echo "scripts/test-POL01-roots.sh:1 POL01T $name: want exit $want with '$text', got exit $rc: ${out//$'\n'/ | }"; N=$((N + 1))
  else echo "ok $name (exit $rc)"; fi
}

case_ baseline 0 '' ':'
case_ roots-deleted 1 "$C:1 POL01 yml_roots missing or not a list" "yq -i 'del(.yml_roots)' $C"
case_ roots-empty 1 'POL01 yml_roots empty' "yq -i '.yml_roots = []' $C"
case_ roots-string 1 'POL01 yml_roots missing or not a list' "yq -i '.yml_roots = \"workflows/shared/verify/*.yml\"' $C"
case_ roots-map 1 'POL01 yml_roots missing or not a list' "yq -i '.yml_roots = {\"a\": \"b\"}' $C"
case_ roots-null 1 'POL01 yml_roots missing or not a list' "yq -i '.yml_roots = null' $C"
case_ roots-blank-entry 1 'POL01 yml_roots entry is not a glob string' "yq -i '.yml_roots = [\"\"]' $C"
case_ config-broken 1 "$C:1 POL01 yml_roots unreadable (yq error)" "printf 'yml_roots: [\n' >> $C"
case_ roots-deleted-tag-still-caught 1 "$V:20 POL01 action not pinned to a full SHA: actions/checkout@v4" \
  "yq -i 'del(.yml_roots)' $C && sed -i -E 's#actions/checkout@[0-9a-f]{40}#actions/checkout@v4#' $V"
case_ roots-without-github-still-caught 1 "$V:20 POL01 action not pinned to a full SHA: actions/checkout@v4" \
  "yq -i '.yml_roots = [\"workflows/shared/verify/*.yml\"]' $C && sed -i -E 's#actions/checkout@[0-9a-f]{40}#actions/checkout@v4#' $V"
case_ root-glob-no-match 0 '' "yq -i '.yml_roots = [\"nothing-here/*.yml\"]' $C"
case_ verify-template-tag 1 'workflows/shared/verify/verify.yml:13 POL01 action not pinned to a full SHA: actions/checkout@v4' \
  'mkdir -p workflows/shared/verify && cp test/fixtures/bad/POL01-verify-template-tag.yml workflows/shared/verify/verify.yml'
case_ verify-template-broken 1 'workflows/shared/verify/verify.yml:8 POL01 parse error' \
  'mkdir -p workflows/shared/verify && cp test/fixtures/bad/POL01-verify-template-broken.yml workflows/shared/verify/verify.yml'

D='printf "on: workflow_dispatch\njobs:\n  d:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n"'
case_ roots-empty-unpinned-d-yml 1 '.github/workflows/d.yml:6 POL01 action not pinned to a full SHA: actions/checkout@v4' \
  "yq -i '.yml_roots = []' $C && $D > .github/workflows/d.yml"
case_ always-on-yaml 1 '.github/workflows/d.yaml:6 POL01 action not pinned to a full SHA: actions/checkout@v4' \
  "yq -i 'del(.yml_roots)' $C && $D > .github/workflows/d.yaml"
case_ verify-template-yaml 1 'workflows/shared/verify/verify.yaml:13 POL01 action not pinned to a full SHA: actions/checkout@v4' \
  'mkdir -p workflows/shared/verify && cp test/fixtures/bad/POL01-verify-template-tag.yaml workflows/shared/verify/verify.yaml'
DK='printf "on: workflow_dispatch\njobs:\n  d:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: %s\n"'
case_ docker-tag 1 '.github/workflows/d.yml:6 POL01 docker image not pinned to @sha256:<64-hex>: docker://alpine:3.20' \
  "$DK docker://alpine:3.20 > .github/workflows/d.yml"
case_ docker-no-digest 1 'POL01 docker image not pinned to @sha256:<64-hex>: docker://alpine' \
  "$DK docker://alpine > .github/workflows/d.yml"
case_ docker-digest 0 '' \
  "$DK docker://alpine@sha256:$(printf '0%.0s' {1..64}) > .github/workflows/d.yml"
case_ local-action 0 '' "$DK ./local-action > .github/workflows/d.yml"
case_ root-not-yml 1 "$C:23 POL01 yml_roots entry does not end in .yml or .yaml" "yq -i '.yml_roots = [\"workflows/shared/verify/*\"]' $C"
case_ lock-yml-in-github 1 '.github/workflows/evil.lock.yml:6 POL01 action not pinned to a full SHA: actions/checkout@v4' \
  "$D > .github/workflows/evil.lock.yml"
case_ lock-yaml-in-github 1 '.github/workflows/evil.lock.yaml:6 POL01 action not pinned to a full SHA: actions/checkout@v4' \
  "$D > .github/workflows/evil.lock.yaml"
case_ yaml-root-walks-yml-twin 1 'workflows/shared/verify/verify.yml:13 POL01 action not pinned to a full SHA: actions/checkout@v4' \
  "yq -i '.yml_roots = [\"workflows/shared/verify/*.yaml\"]' $C && mkdir -p workflows/shared/verify && cp test/fixtures/bad/POL01-verify-template-tag.yml workflows/shared/verify/verify.yml"
case_ twin-roots-walk-once 1 'workflows/shared/verify/verify.yaml:13 POL01 action not pinned to a full SHA: actions/checkout@v4' \
  "yq -i '.yml_roots = [\"workflows/shared/verify/*.yml\", \"workflows/shared/verify/*.yaml\"]' $C && mkdir -p workflows/shared/verify && cp test/fixtures/bad/POL01-verify-template-tag.yaml workflows/shared/verify/verify.yaml" 1

# File mode: a .yaml by name takes the whole-file walk (POL23 globs only bad/POLnn-*.md|yml, so it runs here).
for x in test/fixtures/bad/POL01-*.yaml; do
  out=$(bash policies/checks/POL01.sh "$x" 2>&1); rc=$?
  if [ "$rc" -ne 1 ] || ! grep -qF "$x:13 POL01 action not pinned" <<<"$out"; then
    echo "scripts/test-POL01-roots.sh:1 POL01T file-mode $x: want exit 1, got exit $rc: $out"; N=$((N + 1))
  else echo "ok file-mode $x (exit $rc)"; fi
done

echo "$N failures"
[ "$N" -eq 0 ]
