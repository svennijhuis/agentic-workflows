---
description: Bad POL25 case. sven_yes names a longer workflow, substring must not lift schedule (SM05c fix 1).
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
  group: good-pol25-smoke-yes-superstring-${{ github.ref }}
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

# Bad POL25 sven yes superstring

Staged first.
