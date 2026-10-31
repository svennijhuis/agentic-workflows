---
description: Good POL25 case. sven_yes schedule lift on md and lock pair.
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
  group: good-pol25-smoke-yes-sched-lock-${{ github.ref }}
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

# Good POL25 sven yes schedule lock md

Staged first.
