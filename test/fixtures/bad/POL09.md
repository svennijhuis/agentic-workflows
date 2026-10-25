---
description: Bad POL09 fixture. Every 5 minutes, no concurrency.
on:
  workflow_dispatch:
  schedule:
    - cron: "*/5 * * * *"
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate]
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
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

# Bad POL09

Schedule faster than hourly and no concurrency group.
