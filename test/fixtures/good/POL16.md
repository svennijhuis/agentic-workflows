---
description: Good POL16 fixture. Plain hyphens; writes import shared/reporting.md.
on:
  workflow_dispatch:
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate]
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
concurrency:
  group: good-pol16-${{ github.ref }}
permissions:
  contents: read
  copilot-requests: none
imports:
  - shared/reporting.md
network:
  allowed: [defaults]
tools:
  github:
    toolsets: [repos]
    min-integrity: approved
  bash: [cat, ls]
safe-outputs:
  staged: true
  create-issue:
    max: 1
---

# Good POL16

House style - plain hyphen.
