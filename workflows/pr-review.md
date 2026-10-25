---
description: Report-only PR review. Review contract and agents come from agentPacks, not this file.
intent: Run agentPacks /squad-review in GitHub Actions without copying squad contracts.
emoji: "🔎"
on:
  pull_request:
    types: [opened, synchronize, ready_for_review]
  workflow_dispatch:
  slash_command:
    strategy: centralized
    name: pr-review
    events: [pull_request_comment]
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
imports:
  - shared/defaults.md
  - shared/security.md
  - shared/agentpacks.md
  - shared/standards/common.md
  - shared/standards/dotnet.md
  - shared/standards/typescript.md
  - shared/standards/rust.md
  - svennijhuis/agentPacks/plugins/squad/commands/squad-review.md@34e1dec3535baa1d77cb441ea8c98498dc9b3684
permissions:
  contents: read
  issues: read
  pull-requests: read
  copilot-requests: none
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

Imported above: agentPacks `squad` skill, plugin agents, the `/squad-review` command, and the language standards as text. Follow that command. Do not restate the review contract here.

- Repository: `${{ github.repository }}`
- Event: `${{ github.event_name }}`
- Pull request: `#${{ github.event.issue.number || github.event.pull_request.number }}`

Pin **this pull request** vs its base (the command's `--pr`). Skills and agents are already installed; do not `plugin install` at runtime.

Language standards: `<lang>-review` skills are not installed here. Use the imported standards text instead; cite the document heading on each finding. Apply only the stacks the diff touches.

Override only the IDE I/O:

- Do not ask "Save report as markdown?"
- Do not write `docs/reviews/`, `docs/retros/` or `docs/learnings.md`
- Do not spawn `squad-retro` or run `pack-check`
- Do not start `/squad` plan, implement, verifier, or fix rounds
- Publish the merged list with `create-pull-request-review-comment` (changed lines, max 10) and one `submit-pull-request-review` event `COMMENT` (never `REQUEST_CHANGES`)

Empty product diff: one COMMENT saying so, spawn nobody.
