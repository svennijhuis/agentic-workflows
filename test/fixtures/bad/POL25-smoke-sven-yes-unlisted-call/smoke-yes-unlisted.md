---
description: Bad POL25 case. sven_yes does not lift unlisted workflow_call (SM08 f4).
on:
  workflow_dispatch:
  workflow_call:
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
concurrency:
  group: bad-pol25-smoke-yes-unlisted-${{ github.ref }}
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

# Bad POL25 sven yes unlisted call

Staged first.
