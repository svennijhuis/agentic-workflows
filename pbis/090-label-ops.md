# 090 LabelOps: agent runs when a label is added

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Patterns | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

`label_command` is a low-noise trigger: add label `agent:review` to run.

## Sources

- https://github.github.com/gh-aw/patterns/label-ops/
- https://github.github.com/gh-aw/reference/triggers/

## Design

Files: `workflows/label-ops.md`, `workflows/label-ops.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "LabelOps: agent runs when a label is added"
on:
  label_command:
    name: agent-review
    events: [pull_request]
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
    toolsets: [pull_requests]
safe-outputs:
  add-comment:
    max: 1
---
```

```mermaid
flowchart LR
  T["label_command"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: add-comment"]
```

## Code example

Prompt body:

```markdown
Run the requested task, then the label is removed by gh-aw.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/label-ops@v1
git add .github/workflows/label-ops.md .github/workflows/label-ops.lock.yml
gh aw update label-ops            # later, 3-way merge
gh aw logs label-ops --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/label-ops.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/label-ops.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/label-ops.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/label-ops.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/label-ops.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/label-ops.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/label-ops.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/label-ops.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/label-ops.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[label-ops' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/label-ops.lock.yml` | workflows/label-ops.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/label-ops/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/label-ops.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
