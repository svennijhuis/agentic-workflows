# 064 Sub-issue closer

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Close parent issues when every sub-issue is closed.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/sub-issue-closer.md

## Design

Files: `workflows/sub-issue-closer.md`, `workflows/sub-issue-closer.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Sub-issue closer"
on:
  schedule: daily
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
  copilot-requests: none
tools:
  github:
    toolsets: [issues]
safe-outputs:
  update-issue:
    max: 5
  add-comment:
    max: 5
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: update-issue, add-comment"]
```

## Code example

Prompt body:

```markdown
For open parents with sub-issues all closed, close the parent with a comment listing them.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/sub-issue-closer@v1
git add .github/workflows/sub-issue-closer.md .github/workflows/sub-issue-closer.lock.yml
gh aw update sub-issue-closer            # later, 3-way merge
gh aw logs sub-issue-closer --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/sub-issue-closer.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/sub-issue-closer.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/sub-issue-closer.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/sub-issue-closer.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/sub-issue-closer.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/sub-issue-closer.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/sub-issue-closer.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/sub-issue-closer.md` | >= 2 |
| 9 | In manifest | `rg -c 'workflows/sub-issue-closer.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[sub-issue-closer' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/sub-issue-closer.lock.yml` | workflows/sub-issue-closer.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/sub-issue-closer/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/sub-issue-closer.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
