#!/usr/bin/env bash
# POL09 rate limits: every workflow sets concurrency.group; schedules never run more often than hourly.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
for f in $(targets "$@"); do
  is_workflow "$f" || continue
  r=$(rel "$f")
  [ -n "$(q "$f" '.concurrency.group')" ] || hit "$r" "$(qline "$f" .on)" POL09 "concurrency.group missing"
  while IFS= read -r c; do
    [ -z "$c" ] && continue
    min=${c%% *}
    if [[ "$c" =~ ^every\ ([0-9]+)\ ?m ]] && [ "${BASH_REMATCH[1]}" -lt 60 ]; then
      hit "$r" "$(fline "$f" "$c")" POL09 "schedule '$c' runs more often than hourly"
    elif [[ "$c" =~ ^[^\ ]+(\ [^\ ]+){4}$ ]] && ! [[ "$min" =~ ^[0-9]+$ ]]; then
      hit "$r" "$(fline "$f" "$c")" POL09 "cron '$c' runs more often than hourly (minute field must be one number)"
    fi
  done < <(q "$f" '.on.schedule | (select(tag == "!!str")), (select(tag == "!!seq") | .[] | (select(tag == "!!str"), .cron))')
done
pol_done
