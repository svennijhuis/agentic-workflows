---
description: Bad POL25 fixture. workflow_dispatch plus cooldown plus schedule (schedule still fails).
on:
  workflow_dispatch:
  cooldown: 15m
  schedule:
    - cron: "30 7 * * 1"
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate]
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
concurrency:
  group: bad-pol25-cooldown-schedule-${{ github.ref }}
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

cooldown is a setting. schedule next to workflow_dispatch is still one POL25 hit.
