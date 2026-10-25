# 088 DispatchOps template with typed inputs

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Patterns | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Every catalog workflow gets `workflow_dispatch` with typed inputs for manual runs and trials.

## Sources

- https://github.github.com/gh-aw/patterns/dispatch-ops/

## Design

Files: `workflows/dispatch-template.md`, `workflows/dispatch-template.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "DispatchOps template with typed inputs"
on:
  workflow_dispatch:
    inputs:
      target:
        description: "PR or issue number"
        required: false
        type: string
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
  noop:
---
```

```mermaid
flowchart LR
  T["workflow_dispatch"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: noop"]
```

## Code example

Prompt body:

```markdown
Echo the inputs and exit. Template only.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/dispatch-template@v1
git add .github/workflows/dispatch-template.md .github/workflows/dispatch-template.lock.yml
gh aw update dispatch-template            # later, 3-way merge
gh aw logs dispatch-template --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/dispatch-template.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/dispatch-template.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/dispatch-template.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/dispatch-template.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/dispatch-template.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/dispatch-template.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/dispatch-template.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/dispatch-template.md` | >= 0 |
| 9 | In manifest | `rg -c 'workflows/dispatch-template.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[dispatch-template' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/dispatch-template.lock.yml` | workflows/dispatch-template.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/dispatch-template/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/dispatch-template.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
