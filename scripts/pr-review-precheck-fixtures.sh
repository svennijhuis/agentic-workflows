#!/usr/bin/env bash
# Offline proof for the pr-review pre-check. No network and no token.
# Extracts decide() from workflows/pr-review.md and runs test/fixtures/pr-review/*.
set -euo pipefail
ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"
src="$ROOT/workflows/pr-review.md"
fix_root="$ROOT/test/fixtures/pr-review"
decide_file=$(mktemp)
sed -n '/# BEGIN DECIDE/,/# END DECIDE/p' "$src" > "$decide_file"
# shellcheck disable=SC1090
source "$decide_file"
rm -f "$decide_file"
fail=0
for dir in "$fix_root"/*; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  files=$(awk '/^files /{print $2}' "$dir/input.txt")
  head=$(awk '/^head /{print $2}' "$dir/input.txt")
  today=$(awk '/^today /{print $2}' "$dir/input.txt")
  expiry=$(awk '/^expiry /{print $2}' "$dir/input.txt")
  reviews=$(mktemp)
  awk '/^review /{print $2, $3, $4}' "$dir/input.txt" > "$reviews"
  got=$(decide "$files" "$head" "$today" "$expiry" "$reviews")
  rm -f "$reviews"
  want=$(tr -d '\r\n' < "$dir/expect.txt")
  if [ "$got" = "$want" ]; then
    echo "ok $name $got"
  else
    echo "FAIL $name got $got want $want" >&2
    fail=1
  fi
done
if ! grep -q 'supersede-older-reviews: true' "$src"; then
  echo "FAIL close-older: supersede-older-reviews missing" >&2
  fail=1
fi
exit "$fail"
