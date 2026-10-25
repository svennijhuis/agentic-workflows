#!/usr/bin/env bash
# POL17 lock committed and fresh: every workflow has a sibling .lock.yml whose frontmatter_hash equals
# `gh aw hash-frontmatter` and whose compiler_version and copilot engine match .github/aw.json.
# (Full body drift is caught by scripts/verify.sh: compile, then git status on workflows/.)
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
if ! gh aw version >/dev/null 2>&1; then echo "policies/checks/POL17.sh:1 VERIFY missing: gh aw"; exit 1; fi
PIN_AW=$(jq -r '.["gh-aw"]' "$POL_ROOT/.github/aw.json"); PIN_CP=$(jq -r '.engines.copilot' "$POL_ROOT/.github/aw.json")
for f in $(targets "$@"); do
  is_workflow "$f" || continue
  r=$(rel "$f"); lock="${f%.md}.lock.yml"
  if [ ! -f "$lock" ]; then hit "$r" 1 POL17 "lock file not committed: $(rel "$lock") (run gh aw compile)"; continue; fi
  meta=$(head -1 "$lock" | sed -n 's/^# gh-aw-metadata: //p')
  [ -n "$meta" ] || { hit "$(rel "$lock")" 1 POL17 "no gh-aw-metadata header"; continue; }
  want=$(cd "$(dirname "$f")" && gh aw hash-frontmatter "$(basename "$f")" 2>/dev/null)
  have=$(jq -r '.frontmatter_hash' <<<"$meta")
  if [ -z "$want" ] || [ "$want" != "$have" ]; then hit "$(rel "$lock")" 1 POL17 "stale lock: frontmatter hash differs from source (run gh aw compile)"; fi
  cv=$(jq -r '.compiler_version' <<<"$meta"); ev=$(jq -r '.engine_versions.copilot // ""' <<<"$meta")
  [ "$cv" = "$PIN_AW" ] || hit "$(rel "$lock")" 1 POL17 "compiled with gh-aw $cv, pin is $PIN_AW (.github/aw.json)"
  [ "$ev" = "$PIN_CP" ] || hit "$(rel "$lock")" 1 POL17 "copilot engine $ev, pin is $PIN_CP (.github/aw.json)"
done
pol_done
