# 086 CentralRepoOps orchestrator (private)

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Patterns | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md), [013](013-github-app-cross-repo.md) |

## Context

One orchestrator in this repo dispatches a worker per target repo (e.g. rollout of pr-review). Lives in `.github/workflows/`, `private: true`.

## Sources

- https://github.github.com/gh-aw/patterns/central-repo-ops/
- https://github.github.com/gh-aw/patterns/orchestrator-ops/
- https://github.github.com/gh-aw/reference/cross-repository/

## Design

Files: `workflows/control-plane.md`, `workflows/control-plane.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "CentralRepoOps orchestrator (private)"
on:
  schedule: weekly
  workflow_dispatch:
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
private: true
imports:
  - shared/defaults.md
  - shared/security.md
permissions:
  contents: read
  issues: read
  copilot-requests: none
tools:
  github:
    toolsets: [repos]
safe-outputs:
  dispatch-workflow:
    workflows: [rollout-worker]
    max: 5
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: dispatch-workflow"]
```

## Code example

Prompt body:

```markdown
List target repos from `targets.txt`. For each without `pr-review.lock.yml`, dispatch `rollout-worker` with `target_repo`.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/control-plane@v1
git add .github/workflows/control-plane.md .github/workflows/control-plane.lock.yml
gh aw update control-plane            # later, 3-way merge
gh aw logs control-plane --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/control-plane.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/control-plane.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/control-plane.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/control-plane.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/control-plane.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/control-plane.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/control-plane.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/control-plane.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/control-plane.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[control-plane' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/control-plane.lock.yml` | workflows/control-plane.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/control-plane/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/control-plane.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No direct writes from the orchestrator.

## Risks

Needs GitHub App scoped to targets (013). Compile fails until `rollout-worker` exists: observed `dispatch-workflow: workflow 'rollout-worker' not found`. Ship worker first.

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
