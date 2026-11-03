---
description: After a builder PR is merged, read the run logs of the whole flow for that PR and open one issue in svennijhuis/agentic-workflows when the core can do better. No comment on the merged PR.
on:
  pull_request:
    types: [closed]
  workflow_dispatch:
    inputs:
      pr_number:
        description: Merged builder PR to run the retro on
        required: true
        type: string
if: >-
  github.event_name == 'workflow_dispatch' ||
  (github.event.pull_request.merged == true &&
   contains(github.event.pull_request.labels.*.name, 'builder'))
max-ai-credits: 300
max-daily-ai-credits: 1500
max-turns: 60
timeout-minutes: 20
concurrency:
  group: retro-${{ github.event.pull_request.number || github.event.inputs.pr_number }}
  job-discriminator: ${{ github.run_id }}
imports:
  - shared/defaults.md
  - shared/security.md
  - shared/skills/retro/SKILL.md
  - shared/skills/writing-for-agents/SKILL.md
permissions:
  copilot-requests: write
  actions: read
  contents: read
  issues: read
  pull-requests: read
tools:
  github:
    mode: gh-proxy
    toolsets: [repos, issues, pull_requests, actions]
  agentic-workflows:
safe-outputs:
  create-issue:
    target-repo: svennijhuis/agentic-workflows
    github-token: ${{ secrets.AW_CORE_ISSUES_TOKEN }}
    title-prefix: "[retro] "
    deduplicate-by-title: true
    max: 1
  noop:
    report-as-issue: false
    max: 1
---

# Retro

PR: `${{ github.event.pull_request.number || github.event.inputs.pr_number }}` in `${{ github.repository }}`. Flow: [retro README](README.md#retro).

Follow `Skill: retro`, with `Skill: writing-for-agents` as the style guide for any proposal. The session to look at is the whole agent flow that led to this PR. This run is unattended: the output is one issue or a `noop`, never a question to the user and never a comment on the merged PR.

## 1. Collect the runs

From the PR body take the issue (`Fixes #<n>`) and, when present, the parent map (`Parent: #<n>`). Then use the `agentic-workflows` tools:

1. `logs` for each workflow of the flow, between the issue's creation and the merge: `issue-triage`, `bug-fix`, `wf-to-spec`, `wf-spec`, `wf-plan`, `wf-delivery`, `builder`, `reviewer`. Keep the runs whose inputs or event point at this issue, its parent map, or this PR. Use `max_tokens` to stay small.
2. `audit` on the kept runs: every builder round, every reviewer round, and the triage, bug-fix or wf-* run that started them.

Read the PR timeline too: reviews, inline comments, builder round comments, and the `needs-help` label when it was set.

## 2. Find where the flow went wrong

Look per category of `Skill: retro` step 3: navigation, automated checks, coding standards, tool economy, no-ops, information access, AGENTS.md. Typical signals: a reviewer round that sent work back, a finding the reviewer missed and a maintainer fixed by hand, a builder that searched long for a file or command, a failed or retried tool call, missing context on the issue, a step that cost many turns.

For each candidate, decide which part of the core should change: `builder`, `reviewer`, `retro`, `issue-triage`, `bug-fix`, a `wf-*` workflow, a skill under `workflows/shared/skills/`, or a shared fragment. A problem that lives only in the target repo (its own AGENTS.md, tests or CI) is not a core issue; mention it in the issue only when a core change would have caught it.

## 3. Output

No core improvement found: call `noop` with one line why.

Otherwise create one issue in `svennijhuis/agentic-workflows`, findings in order of severity. Per finding:

- **What went wrong**: one or two sentences, with the PR and the target repo.
- **Run**: link to the run (and step) that shows it.
- **Part to fix**: the workflow, skill or fragment from step 2.
- **Proposal**: the concrete change, as a one-line rule, a check, or a short diff sketch.

Title: the worst finding in a few words.
