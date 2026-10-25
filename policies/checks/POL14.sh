#!/usr/bin/env bash
# POL14 no merge: no merge-pull-request output; no pull_request_target that touches the PR head.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
for f in $(targets "$@"); do
  r=$(rel "$f")
  [ "$(q "$f" '.["safe-outputs"] | has("merge-pull-request")')" = "true" ] && hit "$r" "$(qline "$f" '.["safe-outputs"]["merge-pull-request"]')" POL14 "merge-pull-request output is forbidden (Sven merges)"
  if [ "$(q "$f" '.on | has("pull_request_target")')" = "true" ] && grep -qE 'pull_request\.head|head_ref|head\.sha' "$f"; then
    hit "$r" "$(qline "$f" .on.pull_request_target)" POL14 "pull_request_target with PR head checkout"
  fi
done
pol_done
