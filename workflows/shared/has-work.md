---
description: Pre-agent check. Emits noop and skips the AI engine (0 AIC) when no open issue matches one of the given label sets.
import-schema:
  label-sets:
    type: string
    description: "Label sets separated by |. Inside a set, labels are comma-separated: a plain label must be present, a label with a leading - must be absent. At least one plain label per set. Example: `to-spec|specced,-to-tickets,-planned`."
steps:
  - name: Skip the agent when there is no work
    env:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      LABEL_SETS: ${{ github.aw.import-inputs.label-sets }}
    run: |
      set -euo pipefail
      IFS='|' read -ra sets <<< "$LABEL_SETS"
      for set in "${sets[@]}"; do
        args=()
        excluded='[]'
        IFS=',' read -ra labels <<< "$set"
        for label in "${labels[@]}"; do
          if [[ "$label" == -* ]]; then
            excluded=$(jq -c --arg l "${label#-}" '. + [$l]' <<< "$excluded")
          else
            args+=(--label "$label")
          fi
        done
        # gh issue list reads live data; the search API behind skip-if-no-match can lag behind a fresh label.
        count=$(gh issue list --repo "$GITHUB_REPOSITORY" --state open "${args[@]}" --limit 200 --json labels \
          | jq --argjson ex "$excluded" '[.[] | select(([.labels[].name] - $ex) == [.labels[].name])] | length')
        if [ "$count" -gt 0 ]; then
          echo "Work found for label set: $set ($count open issues)"
          exit 0
        fi
      done
      message="No open issue matches label sets: $LABEL_SETS"
      echo "$message"
      # The copilot harness skips the engine when a noop is already in the safe outputs file.
      mkdir -p "$(dirname "$GH_AW_SAFE_OUTPUTS")"
      jq -nc --arg m "$message" '{type: "noop", message: $m}' >> "$GH_AW_SAFE_OUTPUTS"
---

A pre-agent step already checked that at least one open issue matches one of these label sets: `${{ github.aw.import-inputs.label-sets }}` (a leading `-` means the label must be absent).
