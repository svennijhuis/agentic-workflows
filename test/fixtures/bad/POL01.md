---
description: Bad POL01 fixture. Imports a remote file at a branch ref.
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
  group: bad-pol01-${{ github.ref }}
permissions:
  contents: read
  copilot-requests: none
imports:
  - svennijhuis/agentPacks/plugins/squad/commands/squad-review.md@main
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

# Bad POL01

Import at `@main` is not a pin.
