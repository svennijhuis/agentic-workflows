# 069 Markdown linter

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Deterministic markdownlint in steps, agent only summarises violations into one issue.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/markdown-linter.md
- https://github.com/cursor/plugins/tree/main/pstack/skills/principle-build-the-lever

## Design

Files: `workflows/markdown-linter.md`, `workflows/markdown-linter.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Markdown linter"
on:
  schedule: weekly
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
steps:
  - run: npx --yes markdownlint-cli2 '**/*.md' > /tmp/gh-aw/agent/mdlint.txt 2>&1 || true
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
network:
  allowed: [defaults, node]
safe-outputs:
  create-issue:
    title-prefix: "[markdown] "
    max: 1
    close-older-issues: true
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["steps (deterministic)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: create-issue"]
```

## Code example

Prompt body:

```markdown
Read `/tmp/gh-aw/agent/mdlint.txt`. Group by rule. One issue.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/markdown-linter@v1
git add .github/workflows/markdown-linter.md .github/workflows/markdown-linter.lock.yml
gh aw update markdown-linter            # later, 3-way merge
gh aw logs markdown-linter --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/markdown-linter.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/markdown-linter.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/markdown-linter.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/markdown-linter.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/markdown-linter.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/markdown-linter.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/markdown-linter.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/markdown-linter.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/markdown-linter.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[markdown-linter' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/markdown-linter.lock.yml` | workflows/markdown-linter.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/markdown-linter/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/markdown-linter.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
