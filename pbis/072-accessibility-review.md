# 072 Accessibility review for web apps

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Web repos (e.g. Next.js): Playwright pass over key pages, one discussion with WCAG findings.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/accessibility-review.md
- https://github.github.com/gh-aw/reference/playwright/

## Design

Files: `workflows/accessibility-review.md`, `workflows/accessibility-review.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Accessibility review for web apps"
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
  discussions: read
  issues: read
  copilot-requests: none
tools:
  playwright:
  github:
    toolsets: [repos]
network:
  allowed: [defaults, playwright]
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
Open the 3 main routes. Report WCAG 2.2 AA failures with selector and fix.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/accessibility-review@v1
git add .github/workflows/accessibility-review.md .github/workflows/accessibility-review.lock.yml
gh aw update accessibility-review            # later, 3-way merge
gh aw logs accessibility-review --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/accessibility-review.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/accessibility-review.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/accessibility-review.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/accessibility-review.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/accessibility-review.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/accessibility-review.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/accessibility-review.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/accessibility-review.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/accessibility-review.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[accessibility-review' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/accessibility-review.lock.yml` | workflows/accessibility-review.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/accessibility-review/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/accessibility-review.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
