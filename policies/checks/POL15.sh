#!/usr/bin/env bash
# POL15 timeouts: every workflow sets timeout-minutes, at most the POL15 ceiling.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
MAX=$(polcfg POL15 '.max_timeout_minutes')
for f in $(targets "$@"); do
  is_workflow "$f" || continue
  v=$(q "$f" '.["timeout-minutes"]')
  if [ -z "$v" ]; then hit "$(rel "$f")" "$(qline "$f" .on)" POL15 "timeout-minutes missing"
  elif ! [[ "$v" =~ ^[0-9]+$ ]] || [ "$v" -gt "$MAX" ]; then hit "$(rel "$f")" "$(qline "$f" '.["timeout-minutes"]')" POL15 "timeout-minutes=$v above $MAX"; fi
done
pol_done
