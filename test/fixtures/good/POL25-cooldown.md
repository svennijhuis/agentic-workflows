---
description: Good POL25 fixture. workflow_dispatch plus R01 admission guards, no schedule.
on:
  workflow_dispatch:
    inputs:
      pr:
        description: Pull request number
        required: true
        type: number
  cooldown: 15m
  skip-if-match:
    query: "is:issue is:open label:status-report"
    max: 1
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate]
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
concurrency:
  group: good-pol25-cooldown-${{ github.ref }}
permissions:
  contents: read
  copilot-requests: none
network:
  allowed: [defaults]
tools:
  github:
    toolsets: [repos]
    min-integrity: approved
  bash: [cat, ls]
safe-outputs:
  staged: true
  noop:
    max: 1
---

# Gate minimal

workflow_dispatch only. cooldown and skip-if-match are settings, not triggers.
