---
description: Bad POL17 fixture. The lock beside it is stale.
on:
  workflow_dispatch:
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate]
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 12
timeout-minutes: 10
concurrency:
  group: bad-pol17-${{ github.ref }}
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

# Bad POL17

workflow.lock.yml was compiled before max-turns changed.
