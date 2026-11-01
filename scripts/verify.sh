#!/usr/bin/env bash
# The one gate: `make compile` (gh aw compile --strict), then the two repo checks gh-aw does not cover:
#   POL25 agentic workflows are workflow_dispatch only, POL31 no skills: in a shared fragment.
# Each check runs on the repo, then on its fixtures: every bad case exits 1 with exactly one hit,
# every good case exits 0 with no output. Last line is always `N failures`. Exit 0 ok, 1 failed.
set -uo pipefail
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not inside a git repo"; echo "1 failures"; exit 1; }
cd "$ROOT" || exit 1
N=0
fail() { echo "$1"; N=$((N + 1)); }

# run CHECK PATH: run CHECK on PATH; a case folder with rollout.yml or POL25.yml uses them as config
run() {
  local x=${2%/} env=()
  [ -d "$x" ] && [ -f "$x/rollout.yml" ] && env+=(POL_ROLLOUT="$x/rollout.yml")
  [ -d "$x" ] && [ -f "$x/POL25.yml" ] && env+=(POL25_CFG="$x/POL25.yml")
  env "${env[@]}" bash "policies/checks/$1.sh" "$x"
}

echo "# make compile"
locks() { find workflows .github/workflows -name '*.lock.yml' -type f -exec sha256sum {} + 2>/dev/null | sort; }
before=$(locks)
make --no-print-directory compile || fail "Makefile:1 COMPILE make compile failed"
[ "$(locks)" = "$before" ] || fail "workflows:1 COMPILE a .lock.yml changed after compile (commit the recompiled lock)"

for id in POL25 POL31; do
  echo "# $id repo"
  out=$(bash "policies/checks/$id.sh"); rc=$?
  [ -n "$out" ] && echo "$out"
  [ "$rc" -eq 0 ] || fail "policies/checks/$id.sh:1 $id repo check exits $rc"

  echo "# $id fixtures"
  shopt -s nullglob
  bad=(test/fixtures/bad/"$id"-* test/fixtures/bad/"$id".md* test/fixtures/bad/"$id"/*)
  good=(test/fixtures/good/"$id"-* test/fixtures/good/"$id".md*)
  [ -d "test/fixtures/good/$id" ] && good+=("test/fixtures/good/$id")
  shopt -u nullglob
  [ "${#bad[@]}" -gt 0 ] || fail "test/fixtures/bad:1 $id no bad fixture"
  [ "${#good[@]}" -gt 0 ] || fail "test/fixtures/good:1 $id no good fixture"
  echo "${#bad[@]} bad cases, ${#good[@]} good cases"
  for b in "${bad[@]}"; do
    out=$(run "$id" "$b"); rc=$?
    { [ "$rc" -eq 1 ] && [ "$(grep -c . <<<"$out")" -eq 1 ]; } || fail "$b:1 $id bad case does not exit 1 with exactly one hit (rc $rc)"
  done
  for g in "${good[@]}"; do
    out=$(run "$id" "$g"); rc=$?
    { [ "$rc" -eq 0 ] && [ -z "$out" ]; } || fail "$g:1 $id good case does not exit 0 with no output (rc $rc)"
  done
done

echo "$N failures"
[ "$N" -eq 0 ]
