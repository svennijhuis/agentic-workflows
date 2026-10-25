---
description: Bad POL12 fixture. Cross-repo output with no target-repo; m05.repos entry with another owner.
on:
  workflow_dispatch:
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate]
engine: copilot
m05:
  repos: [some-other-owner/app]
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
concurrency:
  group: bad-pol12-${{ github.ref }}
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
---

# Bad POL12

Custom token, no repo scope, foreign owner.
