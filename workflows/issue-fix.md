---
description: Hand one unblocked issue to the Copilot cloud agent. Blocked issues get a comment and the run stops. Sven merges.
on:
  issues:
    types: [labeled]
    names: [agent-fix]
  workflow_dispatch:
    inputs:
      issue_number:
        description: Issue number to hand to Copilot
        required: true
        type: string
permissions:
  contents: read
  issues: read
  pull-requests: read
  copilot-requests: write
network:
  allowed: []
tools:
  github:
    toolsets: [repos, issues, pull_requests]
safe-outputs:
  assign-to-agent:
    allowed: [copilot]
    target: "*"
    max: 1
  add-comment:
    target: "*"
    max: 1
  # Optional: ask Copilot code review on the PR. Needs GH_AW_AGENT_TOKEN (Sven sets it).
  add-reviewer:
    target: "*"
    allowed-reviewers: [copilot]
    github-token: ${{ secrets.GH_AW_AGENT_TOKEN }}
    max: 1
---

# Issue Fix (Copilot cloud agent)

Issue: `${{ github.event.issue.number || github.event.inputs.issue_number }}` in `${{ github.repository }}`. Flow: [issue-fix README](README.md#issue-fix).

This workflow writes no code. The implementation agent is the Copilot cloud agent.

## 1. Blocker check first

The issue is **blocked** when any of these is true:

- it has the label `blocked`
- it has an open `blocked_by` dependency (an issue it is blocked by that is still open)
- a predecessor issue it depends on has a linked PR that is not merged yet

When blocked: post one comment that lists each blocker (label, open issue number and title, or unmerged PR), says Copilot starts once they are cleared, and stop. Assign nobody.

Also stop with one comment when Copilot is already assigned to this issue, or another issue with label `agent-fix` already has an open Copilot PR. One active ticket at a time.

## 2. Hand to Copilot

Only when nothing blocks: assign the issue to `copilot` with these instructions:

- Work on this issue only. Stay inside what it asks.
- Run the smallest validation that proves the change.
- Open one PR that closes the issue (`Fixes #<issue>`).
- When something is unclear, ask a question on the issue instead of guessing.

## 3. Follow-ups

When run again for an issue that already has an open Copilot PR:

- Open review points: post one `@copilot` comment on the PR that lists them.
- Optional: request a Copilot code review with `add-reviewer` (only works when `GH_AW_AGENT_TOKEN` is set).
- Never merge. Sven reviews and merges.
