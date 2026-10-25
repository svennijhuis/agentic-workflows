# 079 Deployment incident monitor

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Ops | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Failed deployment workflow opens one deduped incident issue.

## Sources

- https://github.com/github/gh-aw/blob/main/.github/workflows/deployment-incident-monitor.md
- https://github.github.com/gh-aw/patterns/monitor-ops/

## Design

Files: `workflows/deployment-incident-monitor.md`, `workflows/deployment-incident-monitor.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Deployment incident monitor"
on:
  workflow_run:
    workflows: ["Deploy"]
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
  issues: read
  copilot-requests: none
tools:
  github:
    toolsets: [actions, issues]
safe-outputs:
  create-issue:
    title-prefix: "[deploy-incident] "
    max: 1
    close-older-issues: true
---
```

```mermaid
flowchart LR
  T["workflow_run"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: create-issue"]
```

## Code example

Prompt body:

```markdown
Only on failure. Summarise the failing job and last successful deploy SHA.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/deployment-incident-monitor@v1
git add .github/workflows/deployment-incident-monitor.md .github/workflows/deployment-incident-monitor.lock.yml
gh aw update deployment-incident-monitor            # later, 3-way merge
gh aw logs deployment-incident-monitor --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/deployment-incident-monitor.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/deployment-incident-monitor.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/deployment-incident-monitor.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/deployment-incident-monitor.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/deployment-incident-monitor.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/deployment-incident-monitor.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/deployment-incident-monitor.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/deployment-incident-monitor.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/deployment-incident-monitor.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[deployment-incident-monitor' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/deployment-incident-monitor.lock.yml` | workflows/deployment-incident-monitor.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/deployment-incident-monitor/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/deployment-incident-monitor.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
