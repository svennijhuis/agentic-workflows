#!/usr/bin/env bash
# POL06 network allowlist: workflows declare network.allowed as a list; no entry anywhere holds a wildcard.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
for f in $(targets "$@"); do
  r=$(rel "$f")
  n=$(q "$f" '.network')
  if [ "$n" = "*" ] || [ "$n" = "all" ]; then hit "$r" "$(qline "$f" .network)" POL06 "network: $n is a wildcard"; continue; fi
  if is_workflow "$f" && [ "$(q "$f" '.network.allowed | tag')" != "!!seq" ]; then
    hit "$r" "$(qline "$f" .network)" POL06 "network.allowed list missing"
  fi
  while IFS= read -r d; do
    [[ "$d" == *"*"* ]] && hit "$r" "$(fline "$f" "$d")" POL06 "wildcard in network.allowed: $d"
  done < <(q "$f" '.network.allowed[]?')
done
pol_done
