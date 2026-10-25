# 054 Release notes draft

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md), [006](006-release-tags.md) |

## Context

On a published release, draft notes from merged PRs since the previous tag.

## Sources

- https://github.github.com/gh-aw/gallery/ai-release-notes/

## Design

Files: `workflows/release-notes.md`, `workflows/release-notes.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Release notes draft"
on:
  release:
    types: [published]
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
    toolsets: [repos, pull_requests]
safe-outputs:
  update-release:
    max: 1
---
```

```mermaid
flowchart LR
  T["release"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: update-release"]
```

## Code example

Prompt body:

```markdown
Collect PRs merged between the previous tag and this one. Group: Added, Changed, Fixed. One line each with PR link. Update the release body.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/release-notes@v1
git add .github/workflows/release-notes.md .github/workflows/release-notes.lock.yml
gh aw update release-notes            # later, 3-way merge
gh aw logs release-notes --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/release-notes.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/release-notes.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/release-notes.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/release-notes.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/release-notes.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/release-notes.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/release-notes.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/release-notes.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/release-notes.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[release-notes' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/release-notes.lock.yml` | workflows/release-notes.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/release-notes/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/release-notes.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
