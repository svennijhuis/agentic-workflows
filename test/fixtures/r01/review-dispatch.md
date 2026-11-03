---
description: R01 offline fixture. Review-class dispatch, cooldown, and rate limit. Not installed. No schedule.
engine:
  id: copilot
  version: "1.0.101"
on:
  workflow_dispatch:
    inputs:
      pr:
        description: Pull request number to review
        required: true
        type: number
  cooldown: 15m
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate, github-actions]
permissions:
  contents: read
  pull-requests: read
network:
  allowed: [defaults]
tools:
  github:
    toolsets: [pull_requests]
    min-integrity: approved
timeout-minutes: 10
max-turns: 2
max-ai-credits: 50
max-daily-ai-credits: 200
user-rate-limit:
  max-runs-per-window: 5
  window: 60
  events: [workflow_dispatch]
  ignored-roles: []
concurrency:
  group: r01-review-${{ github.event.inputs.pr }}
  cancel-in-progress: true
  job-discriminator: ${{ github.run_id }}
safe-outputs:
  staged: true
---

Offline fixture for R01 review-class admission. Do not install. workflow_dispatch only.
