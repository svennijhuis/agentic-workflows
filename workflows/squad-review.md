---
description: Report-only PR review using the agentPacks squad-review loop.
intent: Run the same dual-axis squad review in GitHub Actions that /squad-review runs in the IDE.
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

# Squad review (Actions)

This is the GitHub Actions port of [`/squad-review`](https://github.com/svennijhuis/agentPacks/blob/main/plugins/squad/commands/squad-review.md). The **squad plugin is already installed** via `plugins:` — load skill `squad` by exact name. Do not install plugins at runtime. Do not copy contracts into this prompt; read them from the plugin (`review-contract`, malformed re-ask).

## Context

- Repository: `${{ github.repository }}`
- Event: `${{ github.event_name }}`
- Pull request: `#${{ github.event.issue.number || github.event.pull_request.number }}`

## How this differs from IDE `/squad-review`

| IDE | This workflow |
| --- | --- |
| Pin `--pr` / `--uncommitted` / `--base main` | Always pin the **current pull request** vs its base |
| Ask “Save report as markdown?” | Always post via safe-outputs (no question) |
| Optional `docs/reviews/*.md` | Do **not** write `docs/reviews/` or `docs/learnings.md` |
| No Squad verdict | `submit-pull-request-review` event **COMMENT only** — never REQUEST_CHANGES |
| Human in the loop | Unattended. No `/squad` plan, implement, verifier, or fix rounds |

## Procedure

1. Apply `docs/learnings.md` if it exists (latest `/squad-review` entry only). Do not rewrite skills. Do not append learnings in this run.
2. Resolve the **product diff** for this PR vs its base. Omit run files from the reviewer payload when they appear in the diff (`docs/plans/`, `docs/reviews/`, `docs/learnings.md`, `docs/smoke/`) and list those under Not examined. Product docs that **are** the change stay in. A missing run file is not a finding.
   - Empty or unresolvable product diff → stop. Post one COMMENT review that says so. Spawn nobody.
3. Record whether the **security gate** applies (trust-boundary change) and why.
4. Load only language-pack skills that match the diff (`dotnet-*`, `rust-*`, `typescript-*`). Do not load unrelated stacks.
5. Launch in parallel against the product diff: `squad-reviewer`, `squad-simplifier`, and `squad-security-reviewer` only if gated. If plugin sub-agents are unavailable, perform those three axes yourself using the same review contract — still produce separate axis reports.
6. Pass reports, security decision, `round number: 1`, `plan path: none`, `verifier evidence: none` to `squad-orchestrator` for merge only. One re-ask per malformed producer, same round number, then `accepted — malformed after re-ask` (non-blocking). Orchestrator never launches agents or edits code.
7. Return the ranked merged list. **No** Squad verdict, plan, or fix round.

## Publish (safe-outputs)

- One `create-pull-request-review-comment` per high-signal finding on a **changed line** (path + line). Budget 10. Skip style-only nits.
- One `submit-pull-request-review` with `COMMENT`: ranked merged list, Not examined, security-gate reason, and that this is report-only squad-review.

Do not create issues. Do not open pull requests. Do not commit, merge, or push.
