#!/usr/bin/env bash
# POL18 runtime vars: workflow `env:` keys must be on the policies/POL18.yml allowlist, and cap overrides
# may not exceed the POL02 ceilings.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
mapfile -t OK < <(polcfg POL18 '.allowed_env[]')
for f in $(targets "$@"); do
  r=$(rel "$f")
  for k in $(q "$f" '.env | select(tag == "!!map") | keys | .[]'); do
    if [[ " ${OK[*]} " != *" $k "* ]]; then hit "$r" "$(qline "$f" ".env.[\"$k\"]")" POL18 "env '$k' is not a documented runtime var (policies/POL18.yml)"; continue; fi
    cap=$(polcfg POL18 ".caps[\"$k\"] // \"\""); [ -z "$cap" ] && continue
    ceil=$(polcfg POL02 ".ceilings[\"$cap\"]"); v=$(q "$f" ".env.[\"$k\"]")
    { [[ "$v" =~ ^[0-9]+$ ]] && [ "$v" -le "$ceil" ]; } || hit "$r" "$(qline "$f" ".env.[\"$k\"]")" POL18 "env $k=$v above $cap ceiling $ceil"
  done
done
pol_done
