---
description: Bad POL03 case. Promoted agentic md uses workflow_call (SM05 step 9).
on:
  workflow_dispatch:
  workflow_call:
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
concurrency:
  group: bad-pol03-smoke-promoted-agentic-${{ github.ref }}
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

# Bad POL03 promoted agentic call

Staged first.
