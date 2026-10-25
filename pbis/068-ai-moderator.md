# 068 AI moderator for public repos

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md), [011](011-repo-visibility.md) |

## Context

Public repo: hide spam comments, label spam issues.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/ai-moderator.md
- https://github.github.com/gh-aw/reference/integrity/

## Design

Files: `workflows/ai-moderator.md`, `workflows/ai-moderator.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "AI moderator for public repos"
on:
  issues:
    types: [opened]
  issue_comment:
    types: [created]
  roles: all
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
  copilot-requests: none
tools:
  github:
    toolsets: [issues]
safe-outputs:
  add-labels:
    allowed: [spam]
    max: 1
  hide-comment:
    max: 3
---
```

```mermaid
flowchart LR
  T["issues"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: add-labels, hide-comment"]
```

## Code example

Prompt body:

```markdown
Only act on clear spam or abuse. When unsure, do nothing.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/ai-moderator@v1
git add .github/workflows/ai-moderator.md .github/workflows/ai-moderator.lock.yml
gh aw update ai-moderator            # later, 3-way merge
gh aw logs ai-moderator --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/ai-moderator.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/ai-moderator.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/ai-moderator.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/ai-moderator.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/ai-moderator.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/ai-moderator.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/ai-moderator.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/ai-moderator.md` | >= 2 |
| 9 | In manifest | `rg -c 'workflows/ai-moderator.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[ai-moderator' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/ai-moderator.lock.yml` | workflows/ai-moderator.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/ai-moderator/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/ai-moderator.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
