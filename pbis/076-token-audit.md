# 076 AIC token audit across workflows

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | Ops | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Copilot Pro has 1,500 AIC/month. Weekly report of AIC per workflow from `gh aw logs --json`, with trend in cache-memory.

## Sources

- https://github.com/githubnext/agentic-ops/blob/main/.github/workflows/agentic-token-audit.md
- https://github.github.com/gh-aw/reference/cost-management/
- https://github.github.com/gh-aw/reference/audit/

## Design

Files: `workflows/token-audit.md`, `workflows/token-audit.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "AIC token audit across workflows"
on:
  schedule: weekly
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
  actions: read
  issues: read
  copilot-requests: none
tools:
  agentic-workflows:
  cache-memory:
    key: token-audit
safe-outputs:
  create-issue:
    title-prefix: "[token-audit] "
    max: 1
    close-older-issues: true
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
Use agentic-workflows `logs` for the last 7 days. Table: workflow, runs, total AIC, avg AIC, max AIC. Compare with last week from cache-memory. Flag any workflow > 300 AIC/week.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/token-audit@v1
git add .github/workflows/token-audit.md .github/workflows/token-audit.lock.yml
gh aw update token-audit            # later, 3-way merge
gh aw logs token-audit --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/token-audit.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/token-audit.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/token-audit.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/token-audit.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/token-audit.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/token-audit.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/token-audit.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/token-audit.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/token-audit.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[token-audit' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/token-audit.lock.yml` | workflows/token-audit.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/token-audit/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/token-audit.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |
| 15 | Uses logs tool | `rg -n 'agentic-workflows:' workflows/token-audit.md` | 1 line |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
