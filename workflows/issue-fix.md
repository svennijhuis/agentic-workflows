---
description: Hand one unblocked issue to the builder. Blocked issues get a comment and the run stops. Sven merges.
on:
  issues:
    types: [labeled]
    names: [agent-fix]
  workflow_dispatch:
    inputs:
      issue_number:
        description: Issue number to hand to the builder
        required: true
        type: string
# gh aw add follows dispatch-workflow one level deep; builder's reviewer and its skills come through resources.
resources:
  - reviewer.md
  - shared/skills/code-review.md
  - shared/skills/deslop.md
permissions:
  copilot-requests: write
  contents: read
  issues: read
  pull-requests: read
network:
  allowed: []
tools:
  github:
    toolsets: [repos, issues, pull_requests]
safe-outputs:
  add-comment:
    target: "*"
    max: 1
  dispatch-workflow:
    workflows: [builder]
    max: 1
---

# Issue Fix

Issue: `${{ github.event.issue.number || github.event.inputs.issue_number }}` in `${{ github.repository }}`. Flow: [issue-fix README](README.md#issue-fix).

This workflow writes no code. The builder workflow does the implementation.

## 1. Blocker check first

The issue is **blocked** when any of these is true:

- it has the label `blocked`
- it has an open `blocked_by` dependency (an issue it is blocked by that is still open)
- a predecessor issue it depends on has a linked PR that is not merged yet

When blocked: post one comment that lists each blocker (label, open issue number and title, or unmerged PR), says the builder starts once they are cleared, and stop.

Also stop with one comment when an open PR with label `builder` already closes this issue, or another issue with label `agent-fix` already has an open `builder` PR. One active ticket at a time.

## 2. Start the builder

Only when nothing blocks: emit `dispatch_workflow` for `builder` with input `issue_number` = this issue. The builder opens the PR and starts the reviewer. Never merge. Sven reviews and merges.
