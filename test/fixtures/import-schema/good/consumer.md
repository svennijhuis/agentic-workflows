---
description: C05 good consumer. import-schema input declared.
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
  group: c05-good-${{ github.ref }}
permissions:
  contents: read
  copilot-requests: none
imports:
  - uses: shared/reporting.md
    with:
      title-prefix: "[team-a]"
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
