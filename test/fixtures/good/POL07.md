---
description: Good POL07 fixture. Explicit bash and a scoped MCP server.
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
  group: good-pol07-${{ github.ref }}
permissions:
  contents: read
  copilot-requests: none
network:
  allowed: [defaults]
tools:
  github:
    toolsets: [repos]
    min-integrity: approved
  bash: [cat, ls, "git diff:*"]
mcp-servers:
  docs:
    url: https://example.invalid/mcp
    allowed: [search]
safe-outputs:
  staged: true
  noop:
    max: 1
---

# Good POL07

Allowlists.
