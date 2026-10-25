# 050 Docs updater: keep docs in sync with code

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Weekly scan of merged PRs for doc drift; one draft PR updating README/docs.

## Sources

- https://github.github.com/gh-aw/gallery/docs-automation/
- https://github.com/githubnext/agentics/blob/main/workflows/update-docs.md
- https://github.com/githubnext/agentics/blob/main/workflows/doc-updater.md

## Design

Files: `workflows/docs-updater.md`, `workflows/docs-updater.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Docs updater: keep docs in sync with code"
on:
  schedule: weekly
  skip-if-match: 'is:pr is:open in:title "[docs-updater]"'
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
safe-outputs:
  create-pull-request:
    title-prefix: "[docs-updater] "
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
List PRs merged in the last 7 days. For each user-visible change, check README and docs/. Edit only docs. Open one draft PR.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/docs-updater@v1
git add .github/workflows/docs-updater.md .github/workflows/docs-updater.lock.yml
gh aw update docs-updater            # later, 3-way merge
gh aw logs docs-updater --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/docs-updater.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/docs-updater.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/docs-updater.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/docs-updater.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/docs-updater.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/docs-updater.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/docs-updater.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/docs-updater.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/docs-updater.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[docs-updater' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/docs-updater.lock.yml` | workflows/docs-updater.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/docs-updater/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/docs-updater.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
