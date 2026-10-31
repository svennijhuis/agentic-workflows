---
description: Bad POL25 case. sven_yes row with blank date must not lift schedule (SM05c fix 3).
on:
  workflow_dispatch:
  schedule:
    - cron: "0 9 * * 1"
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
concurrency:
  group: good-pol25-smoke-yes-date-blank-${{ github.ref }}
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

# Bad POL25 sven yes date-blank

Staged first.
