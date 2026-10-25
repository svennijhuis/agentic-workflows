#!/usr/bin/env bash
# POL14 no merge: no merge-pull-request output; no pull_request_target that touches the PR head.
# on: is read through scripts/lib/on-triggers.sh, so `on: pull_request_target` (string or list) is seen too;
# a parse error is a hit (fail closed).
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
# shellcheck source=../../scripts/lib/on-triggers.sh
. "$POL_ROOT/scripts/lib/on-triggers.sh"
for f in $(targets "$@"); do
  r=$(rel "$f")
  trig=$(on_triggers "$f"); rc=$?
  if [ $rc -eq 2 ]; then hit "$r" "$(on_line "$f")" POL14 "on: does not parse as a string, list or map (fail closed)"; continue; fi
  [ "$(q "$f" '.["safe-outputs"] | has("merge-pull-request")')" = "true" ] && hit "$r" "$(qline "$f" '.["safe-outputs"]["merge-pull-request"]')" POL14 "merge-pull-request output is forbidden (Sven merges)"
  if grep -qx pull_request_target <<<"$trig" && grep -qE 'pull_request\.head|head_ref|head\.sha' "$f"; then
    hit "$r" "$(on_line "$f")" POL14 "pull_request_target with PR head checkout"
  fi
done
pol_done
