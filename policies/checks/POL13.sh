#!/usr/bin/env bash
# POL13 threat detection never off: no `threat-detection: false` (or enabled: false) in workflows or shared files.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
for f in $(targets "$@"); do
  v=$(q "$f" '.["safe-outputs"]["threat-detection"] | select(tag == "!!bool"), (select(tag == "!!map") | .enabled)')
  [ "$v" = false ] && hit "$(rel "$f")" "$(qline "$f" '.["safe-outputs"]["threat-detection"]')" POL13 "threat detection turned off"
done
pol_done
