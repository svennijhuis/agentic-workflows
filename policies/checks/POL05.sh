#!/usr/bin/env bash
# POL05 min-integrity required: every workflow sets tools.github.min-integrity to an allowed level.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
mapfile -t OK < <(polcfg POL05 '.allowed[]')
for f in $(targets "$@"); do
  is_workflow "$f" || continue
  v=$(q "$f" '.tools.github["min-integrity"]')
  if [ -z "$v" ]; then hit "$(rel "$f")" "$(qline "$f" '.tools')" POL05 "tools.github.min-integrity missing"
  elif [[ " ${OK[*]} " != *" $v "* ]]; then hit "$(rel "$f")" "$(qline "$f" '.tools.github["min-integrity"]')" POL05 "min-integrity '$v' not in: ${OK[*]}"; fi
done
pol_done
