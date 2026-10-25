---
description: Bad POL19 fixture. A step that force pushes tags.
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
  group: bad-pol19-${{ github.ref }}
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

# Bad POL19

Release step:

```yaml
steps:
  - run: git push --force origin --tags
```
