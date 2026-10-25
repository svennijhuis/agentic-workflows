# 059 Large file simplifier

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Largest source file gets one issue with a split plan.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/large-file-simplifier.md
- https://github.com/cursor/plugins/tree/main/pstack/skills/principle-minimize-reader-load

## Design

Files: `workflows/large-file-simplifier.md`, `workflows/large-file-simplifier.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Large file simplifier"
on:
  schedule: weekly
  skip-if-match: 'is:issue is:open in:title "[large-file]"'
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
  bash:
    - wc
    - find
safe-outputs:
  create-issue:
    title-prefix: "[large-file] "
    max: 1
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
Find the largest non-generated source file. Propose a split into deep modules with one seam each.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/large-file-simplifier@v1
git add .github/workflows/large-file-simplifier.md .github/workflows/large-file-simplifier.lock.yml
gh aw update large-file-simplifier            # later, 3-way merge
gh aw logs large-file-simplifier --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/large-file-simplifier.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/large-file-simplifier.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/large-file-simplifier.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/large-file-simplifier.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/large-file-simplifier.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/large-file-simplifier.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/large-file-simplifier.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/large-file-simplifier.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/large-file-simplifier.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[large-file-simplifier' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/large-file-simplifier.lock.yml` | workflows/large-file-simplifier.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/large-file-simplifier/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/large-file-simplifier.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
