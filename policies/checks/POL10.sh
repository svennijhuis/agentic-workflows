#!/usr/bin/env bash
# POL10 who can trigger: on.roles lists only allowed roles (never `all`), on.skip-bots is set.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
mapfile -t OK < <(polcfg POL10 '.roles_allowed[]')
for f in $(targets "$@"); do
  is_workflow "$f" || continue
  r=$(rel "$f")
  if [ "$(q "$f" '.on.roles | tag')" != "!!seq" ]; then hit "$r" "$(qline "$f" .on)" POL10 "on.roles list missing"
  else
    for x in $(q "$f" '.on.roles[]'); do [[ " ${OK[*]} " == *" $x "* ]] || hit "$r" "$(qline "$f" .on.roles)" POL10 "role '$x' not allowed (${OK[*]})"; done
  fi
  [ -n "$(q "$f" '.on["skip-bots"]')" ] || hit "$r" "$(qline "$f" .on)" POL10 "on.skip-bots missing"
done
pol_done
