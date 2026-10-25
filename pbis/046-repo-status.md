# 046 Repo status: daily report issue

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

One daily issue summarising PRs, issues, CI and releases. Old report auto-closes.

## Sources

- https://github.github.com/gh-aw/gallery/
- https://github.com/githubnext/agentics/blob/main/workflows/repo-status.md
- https://github.com/githubnext/agentics/blob/main/workflows/daily-repo-status.md

## Design

Files: `workflows/repo-status.md`, `workflows/repo-status.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Repo status: daily report issue"
on:
  schedule: daily on weekdays
  workflow_dispatch:
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
imports:
  - shared/defaults.md
  - shared/security.md
permissions:
  contents: read
  issues: read
  pull-requests: read
  actions: read
  copilot-requests: none
tools:
  github:
    toolsets: [repos, issues, pull_requests, actions]
safe-outputs:
  create-issue:
    title-prefix: "[repo-status] "
    labels: [report]
    max: 1
    close-older-issues: true
    expires: 2
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: create-issue"]
```

## Code example

Prompt body:

```markdown
Summarise the last 24h: merged PRs, open PRs waiting > 2 days, failing workflows, new issues. Max 25 lines. Link every item.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/repo-status@v1
git add .github/workflows/repo-status.md .github/workflows/repo-status.lock.yml
gh aw update repo-status            # later, 3-way merge
gh aw logs repo-status --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/repo-status.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/repo-status.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/repo-status.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/repo-status.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/repo-status.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/repo-status.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/repo-status.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/repo-status.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/repo-status.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[repo-status' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/repo-status.lock.yml` | workflows/repo-status.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/repo-status/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/repo-status.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
