---
description: Report-only PR review. Skills and the review command come from agentPacks, not this file. Manual only.
intent: Run IDE /squad-review in GitHub Actions without copying squad contracts.
emoji: "🔎"
on:
  workflow_dispatch:
    inputs:
      pr:
        description: Pull request number to review
        required: true
        type: string
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate, github-actions]
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
concurrency:
  group: squad-review-${{ github.event.inputs.pr }}
  cancel-in-progress: true
  job-discriminator: ${{ github.run_id }}
imports:
  - shared/defaults.md
  - shared/security.md
  - shared/reporting.md
  - shared/agentpacks.md
  - svennijhuis/agentPacks/plugins/squad/commands/squad-review.md@34e1dec3535baa1d77cb441ea8c98498dc9b3684
permissions:
  contents: read
  issues: read
  pull-requests: read
  copilot-requests: none
network:
  allowed: [defaults]
tools:
  github:
    toolsets: [repos, issues, pull_requests]
    min-integrity: approved
  bash: [cat, grep, head, ls, wc, "git diff:*", "git log:*", "git show:*"]
safe-outputs:
  staged: true
  create-pull-request-review-comment:
    max: 10
  submit-pull-request-review:
    max: 1
    allowed-events: [COMMENT]
---

# Actions adapter (do not fork the squad loop)

Imported above: the agentPacks `squad` skill and the `/squad-review` command. Follow that command. Do not restate the review contract here.

- Repository: `${{ github.repository }}`
- Pull request: `#${{ github.event.inputs.pr }}`

Fetch the pull request diff and files yourself with the GitHub tools; nothing from the repo is pasted here. Review this pull request against its base (the command's `--pr`). Skills are already installed; do not `plugin install` at runtime.

Override only the IDE I/O:

- Do not ask "Save report as markdown?"
- Do not write `docs/reviews/` or `docs/learnings.md`
- Do not start `/squad` plan, implement, verifier, or fix rounds
- Publish the merged list with `create-pull-request-review-comment` (changed lines, max 10) and one `submit-pull-request-review` event `COMMENT` (never `REQUEST_CHANGES`), in the shared report format

Empty product diff: one COMMENT saying so, spawn nobody.

Staged: until `squad-review` is listed in `governance/rollout.yml` (Sven's yes after 3 audited runs), outputs are previews only.
