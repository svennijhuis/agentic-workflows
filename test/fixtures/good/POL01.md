---
description: Good POL01 fixture. Pinned remote import (SHA) on the allowlist.
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
  group: good-pol01-${{ github.ref }}
permissions:
  contents: read
  copilot-requests: none
imports:
  - svennijhuis/agentPacks/plugins/squad/commands/squad-review.md@34e1dec3535baa1d77cb441ea8c98498dc9b3684
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

# Good POL01

SHA pin.
