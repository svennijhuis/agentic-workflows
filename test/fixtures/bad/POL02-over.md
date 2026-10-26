---
description: Bad POL02 case, every cap set in its own frontmatter but max-turns is above the ceiling of 30.
on:
  workflow_dispatch:
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate]
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 31
timeout-minutes: 10
concurrency:
  group: gate-minimal-${{ github.ref }}
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

# Gate minimal

Report "nothing to do" with noop.
