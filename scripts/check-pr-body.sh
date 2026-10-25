#!/usr/bin/env bash
# G02a PR body check (the P04 refuse-without-owner rule, as a fixture-tested script).
#   A PR body needs `owner: @<github user>` on its own line, plus `## Architecture summary` and
#   `## Questions for owner` sections with real text (HTML comments do not count; "none" is fine for questions).
# Usage: check-pr-body.sh FILE...             PR bodies (fixtures, or a body saved with gh pr view --json body)
#        check-pr-body.sh --template FILE     the template only needs the line and both headings
set -uo pipefail
mode=body; [ "${1:-}" = --template ] && { mode=template; shift; }
N=0; out() { echo "$1"; N=$((N + 1)); }
section() { # FILE HEADING: section text without comments and blank lines
  awk -v h="$2" '$0 == h {on=1; next} on && /^## / {exit} on {print}' "$1" | sed 's/<!--.*-->//g' | grep -v '^[[:space:]]*$'
}
for f in "$@"; do
  [ -f "$f" ] || { out "$f:1 G02a no such file"; continue; }
  if [ "$mode" = template ]; then
    grep -qE '^owner: @' "$f" || out "$f:1 G02a template has no owner: line"
  else
    grep -qE '^owner: @[A-Za-z0-9-]+[[:space:]]*$' "$f" || out "$f:1 G02a PR body has no owner: @<user> line (P04 refuses it)"
  fi
  for h in '## Architecture summary' '## Questions for owner'; do
    if ! grep -qxF "$h" "$f"; then out "$f:1 G02a missing section: $h"
    elif [ "$mode" = body ] && [ -z "$(section "$f" "$h")" ]; then out "$f:$(grep -nxF "$h" "$f" | cut -d: -f1) G02a empty section: $h"; fi
  done
done
[ "$N" -eq 0 ]
