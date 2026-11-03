---
description: Triage one issue as bug or wayfinder, flag security, missing info and duplicates, and explain why in one comment. Assigns nothing and starts nothing.
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
max-ai-credits: 75
max-daily-ai-credits: 750
max-turns: 30
timeout-minutes: 10
imports:
  - shared/defaults.md
permissions:
  copilot-requests: write
  contents: read
  issues: read
network:
  allowed: []
tools:
  github:
    mode: gh-proxy
    toolsets: [repos, issues]
safe-outputs:
  add-labels:
    allowed: [bug, wayfinder, security, needs-info, duplicate]
    target: "*"
    max: 2
  add-comment:
    target: "*"
    max: 1
---

# Issue Triage

Issue: `${{ github.event.issue.number || github.event.inputs.issue_number }}` in `${{ github.repository }}`. Flow: [README](README.md#issue-triage).

Read the issue (title, body, comments). Search open issues and issues closed in the last 90 days for the same problem. Base every conclusion on the issue and the repo; invent no details.

## Rules

- **bug**: something that already worked or is described is broken now. It can be reproduced, fits in one PR, and needs no design. Goes to `bug-fix`.
- **wayfinder**: something new, or there are choices to make, or it will be more than one PR. Goes to the wayfinder chain (map, spec, plan, delivery).
- **In doubt: wayfinder.** Thinking too much is cheaper than a builder PR going the wrong way.
- **security**: a vulnerability, a leaked secret, or a trust-boundary flaw. Set it next to `bug` or `wayfinder`.
- **needs-info**: a bug without steps, expected and actual result, or a request without the problem and the wanted outcome. Set it next to `bug` or `wayfinder`.
- **duplicate**: only when an open or recently closed issue clearly describes the same problem. Set it instead of `bug` or `wayfinder`. A related issue is mentioned, not labelled.

## Output

1. Add the labels: `bug` or `wayfinder`, plus at most one of `security` or `needs-info`. A duplicate gets only `duplicate`.
2. Post one comment:
   - The label and the reason in two or three sentences.
   - **Agent fit**: one line, `suitable`, `needs more info` or `needs a maintainer`, with the reason.
   - Related or duplicate issues: at most three, each as `#<n>` with one line why.
   - The next step:
     - bug: "A maintainer adds `agent-fix` to hand it to the builder."
     - wayfinder: "A maintainer adds `to-spec` (or makes it a `wayfinder:map` with decision sub-issues) to start the chain."
     - duplicate: "A maintainer closes this as a duplicate of #<n>, or removes the label."
3. With `needs-info`, ask the specific missing questions in the same comment (for a bug: steps, expected, actual) and leave out the next step.
4. With `security`, ask the reporter to move exploit details to a private security advisory (Security tab, Report a vulnerability). Do not repeat exploit details, secrets, or affected endpoints in the comment.

Never assign the issue, never add `agent-fix`, `to-spec` or `wayfinder:map`, and change no code. Nothing starts without a maintainer's label.
