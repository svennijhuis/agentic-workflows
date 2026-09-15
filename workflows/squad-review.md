---
description: Report-only PR review. Skills and agents come from agentPacks, not this file.
intent: Run IDE /squad-review in GitHub Actions without copying squad contracts.
emoji: "🔎"
on:
  pull_request:
    types: [opened, synchronize, ready_for_review]
  workflow_dispatch:
  slash_command:
    strategy: centralized
    name: squad-review
    events: [pull_request_comment]
engine: copilot
timeout-minutes: 20
imports:
  - shared/org-defaults.md
  - shared/security.md
  - shared/squad.md
  - svennijhuis/agentPacks/plugins/squad/commands/squad-review.md@marketplace
permissions:
  contents: read
  issues: read
  pull-requests: read
  copilot-requests: write
tools:
  github:
    toolsets: [repos, issues, pull_requests]
  bash:
    - cat
    - git:*
    - grep
    - head
    - ls
    - wc
safe-outputs:
  create-pull-request-review-comment:
    max: 10
  submit-pull-request-review:
    max: 1
    allowed-events: [COMMENT]
---

# Actions adapter (do not fork the squad loop)

Imported above: agentPacks `squad` skill, plugin agents, and the `/squad-review` command. Follow that command. Do not restate the review contract here.

- Repository: `${{ github.repository }}`
- Event: `${{ github.event_name }}`
- Pull request: `#${{ github.event.issue.number || github.event.pull_request.number }}`

Pin **this pull request** vs its base (the command's `--pr`). Skills and agents are already installed; do not `plugin install` at runtime.

Override only the IDE I/O:

- Do not ask “Save report as markdown?”
- Do not write `docs/reviews/` or `docs/learnings.md`
- Do not start `/squad` plan, implement, verifier, or fix rounds
- Publish the merged list with `create-pull-request-review-comment` (changed lines, max 10) and one `submit-pull-request-review` event `COMMENT` (never `REQUEST_CHANGES`)

Empty product diff: one COMMENT saying so, spawn nobody.
