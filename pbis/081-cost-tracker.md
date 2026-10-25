# 081 Cost tracker comment on agent PRs

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Ops | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md), [048](048-pr-fix.md), [049](049-code-simplifier.md) |

## Context

Comment AIC cost on PRs created by agent workflows.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/cost-tracker.md

## Design

Files: `workflows/cost-tracker.md`, `workflows/cost-tracker.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Cost tracker comment on agent PRs"
on:
  workflow_run:
    workflows: ["pr-fix", "code-simplifier"]
    types: [completed]
    branches: [main]
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
  actions: read
  pull-requests: read
  issues: read
  copilot-requests: none
tools:
  agentic-workflows:
safe-outputs:
  add-comment:
    max: 1
---
```

```mermaid
flowchart LR
  T["workflow_run"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: add-comment"]
```

## Code example

Prompt body:

```markdown
Find the PR the run touched. Comment run AIC and turns.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/cost-tracker@v1
git add .github/workflows/cost-tracker.md .github/workflows/cost-tracker.lock.yml
gh aw update cost-tracker            # later, 3-way merge
gh aw logs cost-tracker --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/cost-tracker.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/cost-tracker.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/cost-tracker.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/cost-tracker.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/cost-tracker.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/cost-tracker.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/cost-tracker.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/cost-tracker.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/cost-tracker.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[cost-tracker' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/cost-tracker.lock.yml` | workflows/cost-tracker.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/cost-tracker/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/cost-tracker.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
