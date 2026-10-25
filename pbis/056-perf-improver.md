# 056 Perf improver: one measured win

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Weekly: find one hot path, measure before/after, draft PR only when the number improves.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/perf-improver.md
- https://github.com/cursor/plugins/tree/main/pstack/skills/principle-explain-the-number

## Design

Files: `workflows/perf-improver.md`, `workflows/perf-improver.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Perf improver: one measured win"
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
  pull-requests: read
  issues: read
  copilot-requests: none
tools:
  github:
    toolsets: [repos]
  edit:
  bash:
    - git:*
    - dotnet:*
    - cargo:*
network:
  allowed: [defaults, dotnet, rust]
safe-outputs:
  create-pull-request:
    title-prefix: "[perf-improver] "
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
Pick one benchmark or hot loop. Measure 3 runs before and after. Open a PR only if median improves > 5%. Explain the number.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/perf-improver@v1
git add .github/workflows/perf-improver.md .github/workflows/perf-improver.lock.yml
gh aw update perf-improver            # later, 3-way merge
gh aw logs perf-improver --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/perf-improver.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/perf-improver.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/perf-improver.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/perf-improver.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/perf-improver.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/perf-improver.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/perf-improver.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/perf-improver.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/perf-improver.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[perf-improver' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/perf-improver.lock.yml` | workflows/perf-improver.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/perf-improver/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/perf-improver.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
