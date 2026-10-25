---
description: Good POL12 fixture. Cross-repo output scoped to an owned repo.
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
  group: good-pol12-${{ github.ref }}
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
  github-token: ${{ secrets.GH_AW_GITHUB_TOKEN }}
  create-issue:
    max: 1
    target-repo: svennijhuis/agentic-workflows
---

# Good POL12

Scoped.
