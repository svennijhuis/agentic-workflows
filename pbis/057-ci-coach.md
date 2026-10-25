# 057 CI coach: cheaper, faster Actions

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Review `.github/workflows/*.yml` for cache misses, redundant jobs, missing path filters, missing concurrency. One draft PR.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/ci-coach.md
- https://github.github.com/gh-aw/reference/cost-management/

## Design

Files: `workflows/ci-coach.md`, `workflows/ci-coach.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "CI coach: cheaper, faster Actions"
on:
  schedule: weekly
  skip-if-match: 'is:pr is:open in:title "[ci-coach]"'
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
  github:
    toolsets: [repos, actions]
  edit:
safe-outputs:
  create-pull-request:
    title-prefix: "[ci-coach] "
    draft: true
    max: 1
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: create-pull-request"]
```

## Code example

Prompt body:

```markdown
Read workflow files and the last 20 run durations. Propose the top 1 to 3 changes with minutes saved. Edit only `.github/workflows/*.yml`, never `*.lock.yml`.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/ci-coach@v1
git add .github/workflows/ci-coach.md .github/workflows/ci-coach.lock.yml
gh aw update ci-coach            # later, 3-way merge
gh aw logs ci-coach --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/ci-coach.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/ci-coach.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/ci-coach.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/ci-coach.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/ci-coach.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/ci-coach.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/ci-coach.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/ci-coach.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/ci-coach.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[ci-coach' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/ci-coach.lock.yml` | workflows/ci-coach.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/ci-coach/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/ci-coach.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
