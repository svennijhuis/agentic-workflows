---
description: Triage one issue as bug or wayfinder, set that label and explain why in one comment. Assigns nothing and starts nothing.
on:
  issues:
    types: [labeled]
    names: [triage]
  workflow_dispatch:
    inputs:
      issue_number:
        description: Issue number to triage
        required: true
        type: string
concurrency:
  group: issue-triage-${{ github.event.issue.number || github.event.inputs.issue_number }}
  job-discriminator: ${{ github.run_id }}
permissions:
  copilot-requests: write
  contents: read
  issues: read
network:
  allowed: []
tools:
  github:
    toolsets: [repos, issues]
safe-outputs:
  add-labels:
    allowed: [bug, wayfinder]
    target: "*"
    max: 1
  add-comment:
    target: "*"
    max: 1
---

# Issue Triage

Issue: `${{ github.event.issue.number || github.event.inputs.issue_number }}` in `${{ github.repository }}`. Flow: [README](README.md#issue-triage).

Read the issue (title, body, comments) and choose exactly one label.

## Rules

- **bug**: something that already worked or is described is broken now. It can be reproduced, fits in one PR, and needs no design. Goes to `bug-fix`.
- **wayfinder**: something new, or there are choices to make, or it will be more than one PR. Goes to the wayfinder chain (map, spec, plan, delivery).
- **In doubt: wayfinder.** Thinking too much is cheaper than a builder PR going the wrong way.

## Output

1. Add the label `bug` or `wayfinder`.
2. Post one comment: the label, the reason in two or three sentences, and the next step:
   - bug: "Sven adds `agent-fix` to hand it to the builder."
   - wayfinder: "Sven adds `to-spec` (or makes it a `wayfinder:map` with decision sub-issues) to start the chain."
3. For a bug without clear reproduction steps, ask for them in the same comment (steps, expected, actual).

Never assign the issue, never add `agent-fix`, `to-spec` or `wayfinder:map`, and change no code. Nothing starts without Sven's label.
