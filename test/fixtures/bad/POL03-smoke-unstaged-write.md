---
description: Bad POL03 case. workflow_dispatch only, a write output, no safe-outputs.staged true (SM08 f3).
on:
  workflow_dispatch:
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
concurrency:
  group: bad-pol03-smoke-unstaged-${{ github.ref }}
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
  create-issue:
    max: 1
---

# Bad POL03 smoke unstaged write

Writes without a staged run.
