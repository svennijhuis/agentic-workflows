#!/usr/bin/env bash
# POL02 cost caps required: each workflow's OWN frontmatter sets every cap (imports do not carry caps),
# and no cap is above the ceiling in policies/POL02.yml.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
for f in $(targets "$@"); do
  is_workflow "$f" || continue
  r=$(rel "$f")
  for cap in max-ai-credits max-daily-ai-credits max-turns timeout-minutes; do
    v=$(q "$f" ".[\"$cap\"]"); ceil=$(polcfg POL02 ".ceilings[\"$cap\"]")
    if [ -z "$v" ]; then hit "$r" 1 POL02 "missing $cap in own frontmatter (caps in imports are ignored)"
    elif ! [[ "$v" =~ ^[0-9]+$ ]] || [ "$v" -gt "$ceil" ]; then hit "$r" "$(qline "$f" ".[\"$cap\"]")" POL02 "$cap=$v above ceiling $ceil"; fi
  done
done
pol_done
