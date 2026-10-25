#!/usr/bin/env bash
# POL11 least permissions: workflows declare permissions, the agent job is read-only (no write scope, no write-all).
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
for f in $(targets "$@"); do
  is_workflow "$f" || continue
  r=$(rel "$f")
  p=$(q "$f" '.permissions | tag')
  if [ -z "$p" ] || [ "$p" = "!!null" ]; then hit "$r" "$(qline "$f" .on)" POL11 "permissions block missing"; continue; fi
  if [ "$p" = "!!str" ]; then hit "$r" "$(qline "$f" .permissions)" POL11 "permissions: $(q "$f" .permissions) is not least privilege"; continue; fi
  for k in $(q "$f" '.permissions | keys | .[]'); do
    [ "$(q "$f" ".permissions.[\"$k\"]")" = write ] && hit "$r" "$(qline "$f" ".permissions.[\"$k\"]")" POL11 "agent job has $k: write (writes go through safe-outputs)"
  done
done
pol_done
