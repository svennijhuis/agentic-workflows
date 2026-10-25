# 070 Glossary maintainer

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Keep GLOSSARY.md in sync with domain terms (Matt domain-modeling).

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/glossary-maintainer.md
- https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md

## Design

Files: `workflows/glossary-maintainer.md`, `workflows/glossary-maintainer.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Glossary maintainer"
on:
  schedule: weekly
  skip-if-match: 'is:pr is:open in:title "[glossary]"'
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
    toolsets: [repos]
  edit:
safe-outputs:
  create-pull-request:
    title-prefix: "[glossary] "
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
  D --> S["safe-outputs: create-pull-request"]
```

## Code example

Prompt body:

```markdown
Find new domain terms in merged PRs of the last 7 days. Add or fix entries in GLOSSARY.md only.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/glossary-maintainer@v1
git add .github/workflows/glossary-maintainer.md .github/workflows/glossary-maintainer.lock.yml
gh aw update glossary-maintainer            # later, 3-way merge
gh aw logs glossary-maintainer --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/glossary-maintainer.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/glossary-maintainer.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/glossary-maintainer.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/glossary-maintainer.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/glossary-maintainer.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/glossary-maintainer.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/glossary-maintainer.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/glossary-maintainer.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/glossary-maintainer.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[glossary-maintainer' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/glossary-maintainer.lock.yml` | workflows/glossary-maintainer.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/glossary-maintainer/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/glossary-maintainer.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
