---
description: R01 offline fixture. Daily-report cooldown, rate limit, and skip-if-match. Not installed. No schedule.
engine:
  id: copilot
  version: "1.0.101"
on:
  workflow_dispatch:
  cooldown: 20h
  skip-if-match:
    query: "is:issue is:open label:status-report"
    max: 1
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate, github-actions]
permissions:
  contents: read
  issues: read
network:
  allowed: [defaults]
tools:
  github:
    toolsets: [issues]
    min-integrity: approved
timeout-minutes: 10
max-turns: 2
max-ai-credits: 50
max-daily-ai-credits: 200
user-rate-limit:
  max-runs-per-window: 1
  window: 180
  events: [workflow_dispatch]
  ignored-roles: []
concurrency:
  group: r01-daily-${{ github.repository }}
  cancel-in-progress: false
  job-discriminator: ${{ github.run_id }}
safe-outputs:
  staged: true
---

Offline fixture for R01 daily-report admission. Do not install. workflow_dispatch only. Fuzzy daily stays off until Sven says yes.
