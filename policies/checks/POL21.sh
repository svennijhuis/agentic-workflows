#!/usr/bin/env bash
# POL21 copilot-requests: none on every workflow (personal account, no org Copilot billing).
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
for f in $(targets "$@"); do
  is_workflow "$f" || continue
  v=$(q "$f" '.permissions["copilot-requests"]')
  [ "$v" = none ] || hit "$(rel "$f")" "$(qline "$f" .permissions)" POL21 "permissions.copilot-requests must be none (is '${v:-missing}')"
done
pol_done
