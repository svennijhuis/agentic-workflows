#!/usr/bin/env bash
# POL22 PR review COMMENT only: submit-pull-request-review sets allowed-events to exactly [COMMENT].
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
for f in $(targets "$@"); do
  [ "$(q "$f" '.["safe-outputs"] | has("submit-pull-request-review")')" = "true" ] || continue
  ev=$(q "$f" '.["safe-outputs"]["submit-pull-request-review"]["allowed-events"] | select(tag == "!!seq") | join(",")')
  [ "$ev" = COMMENT ] || hit "$(rel "$f")" "$(qline "$f" '.["safe-outputs"]["submit-pull-request-review"]')" POL22 "submit-pull-request-review allowed-events must be [COMMENT] (is '${ev:-unset}')"
done
pol_done
