---
description: Bad POL03 case. Agentic md listed with workflow_call; agentic never gets workflow_call.
on:
  workflow_dispatch:
  workflow_call:
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
concurrency:
  group: bad-pol03-smoke-agentic-call-${{ github.ref }}
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
  create-issue:
    max: 1
---

# Bad POL03 smoke agentic call

Staged first.
