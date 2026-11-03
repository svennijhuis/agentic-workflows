---
description: Fix one issue with a PR, but only when nothing blocks it. Blocked issues get a comment and the run stops. Sven merges.
on:
  issues:
    types: [labeled]
    names: [agent-fix]
  workflow_dispatch:
    inputs:
      issue_number:
        description: Issue number to fix
        required: true
        type: string
permissions:
  contents: read
  issues: read
  pull-requests: read
network:
  allowed: []
tools:
  github:
    toolsets: [repos, issues]
  edit:
  bash: true
safe-outputs:
  add-comment:
    max: 1
  create-pull-request:
    title-prefix: "[issue-fix] "
    max: 1
---

# Issue Fix

Issue: `${{ github.event.issue.number || github.event.inputs.issue_number }}` in `${{ github.repository }}`. Flow: [issue-fix README](README.md#issue-fix).

## 1. Blocker check first

Read the issue. It is **blocked** when any of these is true:

- it has the label `blocked`
- it has an open "blocked by" dependency (an issue it is blocked by that is still open)
- it has an open sub-issue

When blocked: post one comment that lists each blocker (label, or the open issue number and title), says the fix starts once they are closed, and stop. Make no code changes and open no PR.

## 2. Fix

Only when nothing blocks:

1. Make the smallest change that fixes the issue. Stay inside what the issue asks.
2. Open one pull request. Title: the issue title. Body: `Fixes #<issue>`, a short summary of the change, and anything you could not do.
3. Never merge. Sven reviews and merges.

If the issue is unclear or too big for one PR, post one comment that says what is missing and stop.
