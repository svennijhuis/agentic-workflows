# 063 Issue arborist: link sub-issues

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Daily: link related open issues as sub-issues.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/issue-arborist.md

## Design

Files: `workflows/issue-arborist.md`, `workflows/issue-arborist.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Issue arborist: link sub-issues"
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
  copilot-requests: none
tools:
  github:
    toolsets: [issues]
safe-outputs:
  link-sub-issue:
    max: 5
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: link-sub-issue"]
```

## Code example

Prompt body:

```markdown
Find open issues that are clearly parts of an epic. Link at most 5.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/issue-arborist@v1
git add .github/workflows/issue-arborist.md .github/workflows/issue-arborist.lock.yml
gh aw update issue-arborist            # later, 3-way merge
gh aw logs issue-arborist --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/issue-arborist.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/issue-arborist.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/issue-arborist.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/issue-arborist.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/issue-arborist.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/issue-arborist.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/issue-arborist.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/issue-arborist.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/issue-arborist.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[issue-arborist' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/issue-arborist.lock.yml` | workflows/issue-arborist.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/issue-arborist/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/issue-arborist.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
