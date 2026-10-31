---
description: Bad POL25 case. sven_yes does not lift deployment_status (SM08 f4).
on:
  workflow_dispatch:
  deployment_status:
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
concurrency:
  group: bad-pol25-smoke-yes-ds-${{ github.ref }}
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

# Bad POL25 sven yes deployment status

Staged first.
