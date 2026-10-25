#!/usr/bin/env bash
# POL10 who can trigger: on.roles lists only allowed roles (never `all`), on.skip-bots is set.
# on: is read through scripts/lib/on-triggers.sh: the string or list form has no roles or skip-bots, so it
# is a hit naming the trigger; a parse error is a hit (fail closed).
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
# shellcheck source=../../scripts/lib/on-triggers.sh
. "$POL_ROOT/scripts/lib/on-triggers.sh"
mapfile -t OK < <(polcfg POL10 '.roles_allowed[]')
for f in $(targets "$@"); do
  r=$(rel "$f")
  trig=$(on_triggers "$f"); rc=$?
  [ $rc -eq 3 ] && continue
  if [ $rc -eq 2 ]; then hit "$r" "$(on_line "$f")" POL10 "on: does not parse as a string, list or map (fail closed)"; continue; fi
  if [ "$(on_shape "$f")" != map ]; then
    hit "$r" "$(on_line "$f")" POL10 "on: short form ($(paste -sd, <<<"$trig")) has no roles or skip-bots; use the map form"; continue
  fi
  if [ "$(q "$f" '.on.roles | tag')" != "!!seq" ]; then hit "$r" "$(qline "$f" .on)" POL10 "on.roles list missing"
  else
    for x in $(q "$f" '.on.roles[]'); do [[ " ${OK[*]} " == *" $x "* ]] || hit "$r" "$(qline "$f" .on.roles)" POL10 "role '$x' not allowed (${OK[*]})"; done
  fi
  [ -n "$(q "$f" '.on["skip-bots"]')" ] || hit "$r" "$(qline "$f" .on)" POL10 "on.skip-bots missing"
done
pol_done
