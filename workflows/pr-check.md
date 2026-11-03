---
description: When Copilot opens a PR, check the diff with the skills in .github/skills/ and post findings as a review with @copilot so Copilot fixes them. No merge, no push.
on:
  pull_request:
    types: [opened, ready_for_review]
  workflow_dispatch:
    inputs:
      pr_number:
        description: PR number to check
        required: true
        type: string
if: ${{ github.event_name == 'workflow_dispatch' || github.event.pull_request.user.login == 'Copilot' }}
permissions:
  contents: read
  pull-requests: read
network:
  allowed: []
tools:
  github:
    toolsets: [repos, pull_requests]
safe-outputs:
  create-pull-request-review-comment:
    target: "*"
    max: 10
  submit-pull-request-review:
    target: "*"
    allowed-events: [COMMENT, REQUEST_CHANGES]
    max: 1
---

# PR check (skills)

PR: `${{ github.event.pull_request.number || github.event.inputs.pr_number }}` in `${{ github.repository }}`. Flow: [pr-check README](README.md#pr-check).

Only Copilot PRs start this run (the `if:` above), so other PRs cost nothing.

1. Read every `SKILL.md` under `.github/skills/` on the default branch. These are the rules (for example deslop).
2. Read the PR diff. Check only changed lines against those rules.
3. Each finding: one inline review comment on the line, naming the skill and the concrete fix. Max 10.
4. Submit one review:
   - findings: `REQUEST_CHANGES`, body starts with `@copilot please fix the comments below.`, then a short list.
   - no findings: `COMMENT` with `Skills check clean.` and the skill names used.

Never merge, never push, never approve.
