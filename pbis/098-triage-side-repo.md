# 098 Triage from side repo

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Patterns | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md), [013](013-github-app-cross-repo.md) |

## Context

Run triage from this catalog against a target repo without installing there.

## Sources

- https://github.github.com/gh-aw/gallery/multi-repo/triage-from-side-repo/
- https://github.github.com/gh-aw/patterns/multi-repo-ops/

## Design

Files: `workflows/triage-side-repo.md`, `workflows/triage-side-repo.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Triage from side repo"
on:
  schedule: daily
  workflow_dispatch:
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
private: true
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
    allowed-repos: [svennijhuis/*]
    min-integrity: approved
safe-outputs:
  add-labels:
    allowed: [needs-triage]
    max: 10
    target-repo: "*"
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: add-labels"]
```

## Code example

Prompt body:

```markdown
For each repo in `targets.txt`, label untriaged issues.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/triage-side-repo@v1
git add .github/workflows/triage-side-repo.md .github/workflows/triage-side-repo.lock.yml
gh aw update triage-side-repo            # later, 3-way merge
gh aw logs triage-side-repo --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/triage-side-repo.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/triage-side-repo.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/triage-side-repo.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/triage-side-repo.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/triage-side-repo.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/triage-side-repo.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/triage-side-repo.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/triage-side-repo.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/triage-side-repo.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[triage-side-repo' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/triage-side-repo.lock.yml` | workflows/triage-side-repo.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/triage-side-repo/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/triage-side-repo.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
