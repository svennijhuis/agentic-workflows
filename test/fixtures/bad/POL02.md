---
description: Bad POL02 fixture. Caps only in a shared import.
on:
  workflow_dispatch:
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate]
engine: copilot
imports:
  - shared/caps.md
timeout-minutes: 10
concurrency:
  group: bad-pol02-${{ github.ref }}
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

# Bad POL02

Caps live in an import, which the compiler ignores.
