# 071 Repo assist (budget gated)

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md), F00 |

## Context

Twice-daily triage+fix is costly; adopt only with a weekly schedule and a hard 1 PR cap.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/repo-assist.md
- https://github.github.com/gh-aw/gallery/maintaining-repos/

## Design

Files: `workflows/repo-assist.md`, `workflows/repo-assist.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Repo assist (budget gated)"
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
  issues: read
  pull-requests: read
  copilot-requests: none
tools:
  github:
    toolsets: [repos, issues, pull_requests]
  edit:
safe-outputs:
  add-comment:
    max: 3
  create-pull-request:
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
  D --> S["safe-outputs: add-comment, create-pull-request"]
```

## Code example

Prompt body:

```markdown
Pick the single most valuable open issue labelled `ready`. Fix it or comment why not.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/repo-assist@v1
git add .github/workflows/repo-assist.md .github/workflows/repo-assist.lock.yml
gh aw update repo-assist            # later, 3-way merge
gh aw logs repo-assist --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/repo-assist.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/repo-assist.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/repo-assist.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/repo-assist.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/repo-assist.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/repo-assist.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/repo-assist.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/repo-assist.md` | >= 2 |
| 9 | In manifest | `rg -c 'workflows/repo-assist.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[repo-assist' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/repo-assist.lock.yml` | workflows/repo-assist.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/repo-assist/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/repo-assist.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Cost: highest of the gallery. Keep weekly and watch 076.

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
