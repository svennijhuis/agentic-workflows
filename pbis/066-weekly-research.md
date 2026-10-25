# 066 Weekly research digest

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Weekly digest of gh-aw / Copilot / agentPacks-relevant changes from primary sources.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/weekly-research.md
- https://github.com/githubnext/agentic-ops/blob/main/.github/workflows/daily-agentic-research.md
- https://github.com/mattpocock/skills/blob/main/skills/engineering/research/SKILL.md

## Design

Files: `workflows/weekly-research.md`, `workflows/weekly-research.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Weekly research digest"
on:
  schedule: weekly on monday
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
    toolsets: [repos]
safe-outputs:
  create-issue:
    title-prefix: "[research] "
    max: 1
    close-older-issues: true
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: create-issue"]
```

## Code example

Prompt body:

```markdown
Read gh-aw releases (github/gh-aw via GitHub tools; Copilot native web tools are off in this mode). List changes that affect this catalog with links. Max 15 bullets.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/weekly-research@v1
git add .github/workflows/weekly-research.md .github/workflows/weekly-research.lock.yml
gh aw update weekly-research            # later, 3-way merge
gh aw logs weekly-research --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/weekly-research.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/weekly-research.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/weekly-research.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/weekly-research.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/weekly-research.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/weekly-research.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/weekly-research.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/weekly-research.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/weekly-research.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[weekly-research' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/weekly-research.lock.yml` | workflows/weekly-research.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/weekly-research/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/weekly-research.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
