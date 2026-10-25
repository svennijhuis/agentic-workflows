# 074 Unbloat docs: /unbloat

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Shorten verbose docs on demand. Fits Sven style: short, no essays.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/unbloat-docs.md
- https://github.com/mattpocock/skills/blob/main/skills/productivity/writing-for-agents/SKILL.md

## Design

Files: `workflows/unbloat-docs.md`, `workflows/unbloat-docs.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Unbloat docs: /unbloat"
on:
  slash_command:
    name: unbloat
    strategy: centralized
    events: [pull_request_comment]
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
  push-to-pull-request-branch:
    max: 1
  add-comment:
    max: 1
---
```

```mermaid
flowchart LR
  T["slash_command"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: push-to-pull-request-branch, add-comment"]
```

## Code example

Prompt body:

```markdown
Cut words in changed `.md` files without losing facts. No em dash. Report chars before/after.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/unbloat-docs@v1
git add .github/workflows/unbloat-docs.md .github/workflows/unbloat-docs.lock.yml
gh aw update unbloat-docs            # later, 3-way merge
gh aw logs unbloat-docs --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/unbloat-docs.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/unbloat-docs.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/unbloat-docs.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/unbloat-docs.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/unbloat-docs.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/unbloat-docs.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/unbloat-docs.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/unbloat-docs.md` | >= 2 |
| 9 | In manifest | `rg -c 'workflows/unbloat-docs.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[unbloat-docs' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/unbloat-docs.lock.yml` | workflows/unbloat-docs.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/unbloat-docs/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/unbloat-docs.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
