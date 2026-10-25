# 075 Plan: weekly plan discussion

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Weekly plan from open issues and milestones as one discussion.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/plan.md
- https://github.com/mattpocock/skills/blob/main/skills/engineering/wayfinder/SKILL.md

## Design

Files: `workflows/daily-plan.md`, `workflows/daily-plan.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Plan: weekly plan discussion"
on:
  schedule: weekly on monday
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
  discussions: read
  copilot-requests: none
tools:
  github:
    toolsets: [issues]
safe-outputs:
  create-discussion:
    category: "General"
    max: 1
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: create-discussion"]
```

## Code example

Prompt body:

```markdown
Rank open issues by value and size. Propose this week's top 5 with reasons.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/daily-plan@v1
git add .github/workflows/daily-plan.md .github/workflows/daily-plan.lock.yml
gh aw update daily-plan            # later, 3-way merge
gh aw logs daily-plan --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/daily-plan.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/daily-plan.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/daily-plan.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/daily-plan.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/daily-plan.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/daily-plan.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/daily-plan.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/daily-plan.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/daily-plan.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[daily-plan' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/daily-plan.lock.yml` | workflows/daily-plan.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/daily-plan/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/daily-plan.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
