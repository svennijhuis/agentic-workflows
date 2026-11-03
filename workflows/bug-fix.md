---
description: Hand one unblocked issue to the builder. Blocked issues get a comment and the run stops. A maintainer merges.
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
concurrency:
  group: bug-fix-${{ github.event.issue.number || github.event.inputs.issue_number }}
  job-discriminator: ${{ github.run_id }}
max-ai-credits: 75
max-daily-ai-credits: 750
max-turns: 30
timeout-minutes: 10
imports:
  - shared/defaults.md
# gh aw add follows dispatch-workflow one level deep; builder's reviewer and its skills come through resources.
resources:
  - pr-reviewer.md
  - shared/skills/code-review/SKILL.md
  - shared/skills/deslop/SKILL.md
permissions:
  copilot-requests: write
  contents: read
  issues: read
  pull-requests: read
network:
  allowed: []
tools:
  github:
    mode: gh-proxy
    toolsets: [repos, issues, pull_requests]
safe-outputs:
  add-comment:
    target: "*"
    max: 1
  dispatch-workflow:
    workflows: [issue-builder]
    max: 1
---

# Issue Fix

Issue: `${{ github.event.issue.number || github.event.inputs.issue_number }}` in `${{ github.repository }}`. Flow: [bug-fix README](README.md#bug-fix).

This workflow writes no code. The builder workflow does the implementation.

## 1. Blocker check first

The issue is **blocked** when any of these is true:

- it has the label `blocked`
- it has an open `blocked_by` dependency (an issue it is blocked by that is still open)
- a predecessor issue it depends on has a linked PR that is not merged yet

When blocked: post one comment that lists each blocker (label, open issue number and title, or unmerged PR), says the builder starts once they are cleared, and stop.

Also stop with one comment when this issue or another issue with label `agent-fix` is **active**. One active ticket at a time. An issue is active when it is open and any of these holds:

- an open PR with label `builder` closes it;
- its newest comment starting with `Builder started:` (written by `github-actions[bot]`) is less than 90 minutes old and no builder PR for it exists yet: a build is still running;
- its newest comment starting with `Builder question:` (written by `github-actions[bot]`) has no comment from a human account after it.

A `Builder started:` comment of 90 minutes or older without a builder PR is a failed build: it does not block a new start.

## 2. Start the builder

Only when nothing blocks, emit both, in this order:

1. `dispatch_workflow` for `issue-builder` with input `issue_number` = this issue;
2. `add_comment` on this issue: `Builder started: <link to this run>`.

Never emit one without the other. The builder opens the PR and starts the reviewer. Never merge. A maintainer reviews and merges.
