# 049 Code simplifier: daily draft PR

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Pick recently changed code, subtract first (dead code, duplicate guards), open one draft PR. Skip when one is already open.

## Sources

- https://github.github.com/gh-aw/gallery/code-improvement/
- https://github.com/githubnext/agentics/blob/main/workflows/code-simplifier.md
- https://github.com/cursor/plugins/tree/main/pstack/skills/principle-subtract-before-you-add

## Design

Files: `workflows/code-simplifier.md`, `workflows/code-simplifier.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Code simplifier: daily draft PR"
on:
  schedule: daily on weekdays
  skip-if-match: 'is:pr is:open in:title "[code-simplifier]"'
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
    toolsets: [repos, pull_requests]
  edit:
  bash:
    - git:*
safe-outputs:
  create-pull-request:
    title-prefix: "[code-simplifier] "
    draft: true
    max: 1
    labels: [simplify]
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
Look at files changed in the last 7 days. Find one simplification that removes code without changing behaviour. Run tests. Open a draft PR with before/after line counts.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/code-simplifier@v1
git add .github/workflows/code-simplifier.md .github/workflows/code-simplifier.lock.yml
gh aw update code-simplifier            # later, 3-way merge
gh aw logs code-simplifier --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/code-simplifier.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/code-simplifier.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/code-simplifier.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/code-simplifier.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/code-simplifier.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/code-simplifier.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/code-simplifier.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/code-simplifier.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/code-simplifier.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[code-simplifier' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/code-simplifier.lock.yml` | workflows/code-simplifier.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/code-simplifier/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/code-simplifier.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
