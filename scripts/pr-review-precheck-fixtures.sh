#!/usr/bin/env bash
# Offline proof for the pr-review pre-check and close-older plan. No network and no token.
# Extracts decide() and close_action() from workflows/pr-review.md and runs fixtures.
set -euo pipefail
ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"
src="$ROOT/workflows/pr-review.md"
fix_root="$ROOT/test/fixtures/pr-review"
close_root="$ROOT/test/fixtures/pr-review-close"
decide_file=$(mktemp)
close_file=$(mktemp)
sed -n '/# BEGIN DECIDE/,/# END DECIDE/p' "$src" > "$decide_file"
sed -n '/# BEGIN CLOSE/,/# END CLOSE/p' "$src" > "$close_file"
# shellcheck disable=SC1090
source "$decide_file"
# shellcheck disable=SC1090
source "$close_file"
rm -f "$decide_file" "$close_file"
fail=0

check() {
  local name="$1" rc="$2" got="$3" want="$4" err="$5"
  if [ "$want" = "exit:1" ]; then
    if [ "$rc" -ne 0 ]; then
      echo "ok $name exit:$rc"
    else
      echo "FAIL $name rc $rc got $got want exit:1" >&2
      [ -s "$err" ] && cat "$err" >&2
      fail=1
    fi
    return
  fi
  if [ "$rc" -eq 0 ] && [ "$got" = "$want" ]; then
    echo "ok $name $got"
  else
    echo "FAIL $name rc $rc got [$got] want [$want]" >&2
    [ -s "$err" ] && cat "$err" >&2
    fail=1
  fi
}

for dir in "$fix_root"/*; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  files=$(awk '/^files /{print $2}' "$dir/input.txt")
  head=$(awk '/^head /{print $2}' "$dir/input.txt")
  today=$(awk '/^today /{print $2}' "$dir/input.txt")
  expiry=$(awk '/^expiry /{print $2}' "$dir/input.txt")
  reviews=$(mktemp)
  err=$(mktemp)
  awk '/^review /{print $2, $3, $4, $5}' "$dir/input.txt" > "$reviews"
  set +e
  got=$(decide "$files" "$head" "$today" "$expiry" "$reviews" 2>"$err")
  rc=$?
  set -e
  rm -f "$reviews"
  want=$(tr -d '\r\n' < "$dir/expect.txt")
  check "$name" "$rc" "$got" "$want" "$err"
  rm -f "$err"
done

for dir in "$close_root"/*; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  staged=$(awk '/^staged /{print $2}' "$dir/input.txt")
  run_at=$(awk '/^run /{print $2}' "$dir/input.txt")
  rows=$(mktemp)
  err=$(mktemp)
  awk '/^row /{print $2, $3, $4, $5, $6}' "$dir/input.txt" > "$rows"
  set +e
  got=$(close_action "$staged" "$rows" "$run_at" 2>"$err")
  rc=$?
  set -e
  rm -f "$rows"
  want=$(cat "$dir/expect.txt")
  want=${want%$'\r'}
  want=${want%$'\n'}
  check "close-$name" "$rc" "$got" "$want" "$err"
  rm -f "$err"
done

if grep -q 's+0' "$src"; then
  echo "FAIL files_count: s+0 coerces empty output to 0" >&2
  fail=1
fi
if ! grep -F -q 'files_count must be digits' "$src"; then
  echo "FAIL files_count: digit check missing" >&2
  fail=1
fi
if ! grep -F -q 'minimizeComment' "$src"; then
  echo "FAIL close-older: minimizeComment step missing" >&2
  fail=1
fi
if ! grep -F -q 'staged, write skipped' "$src"; then
  echo "FAIL close-older: staged skip missing" >&2
  fail=1
fi
if grep -q 'close-older via supersede-older-reviews' "$src"; then
  echo "FAIL close-older: supersede-older-reviews still treated as close-older" >&2
  fail=1
fi
if ! grep -F -q 'STAGED: "true"' "$src"; then
  echo "FAIL close-older: STAGED is not true" >&2
  fail=1
fi
if ! grep -F -q 'staged: true' "$src"; then
  echo "FAIL close-older: safe-outputs staged is not true" >&2
  fail=1
fi
exit "$fail"
