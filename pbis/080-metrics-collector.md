# 080 Metrics collector (repo-memory)

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Ops | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Weekly repo metrics snapshot into repo-memory for trends; noop output.

## Sources

- https://github.github.com/gh-aw/gallery/metrics-analytics/
- https://github.github.com/gh-aw/reference/repo-memory/

## Design

Files: `workflows/metrics-collector.md`, `workflows/metrics-collector.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Metrics collector (repo-memory)"
on:
  schedule: weekly
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
  copilot-requests: none
tools:
  repo-memory:
    branch-prefix: memory
  github:
    toolsets: [repos, issues, pull_requests]
safe-outputs:
  noop:
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: noop"]
```

## Code example

Prompt body:

```markdown
Append one JSON line: date, open issues, open PRs, median PR age, CI pass rate.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/metrics-collector@v1
git add .github/workflows/metrics-collector.md .github/workflows/metrics-collector.lock.yml
gh aw update metrics-collector            # later, 3-way merge
gh aw logs metrics-collector --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/metrics-collector.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/metrics-collector.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/metrics-collector.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/metrics-collector.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/metrics-collector.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/metrics-collector.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/metrics-collector.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/metrics-collector.md` | >= 0 |
| 9 | In manifest | `rg -c 'workflows/metrics-collector.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[metrics-collector' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/metrics-collector.lock.yml` | workflows/metrics-collector.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/metrics-collector/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/metrics-collector.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
