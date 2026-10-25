# 053 Dependency analysis: risky dependency changes

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

When a PR touches `*.csproj`, `package.json`, `Cargo.toml`, summarise added deps (license, maintainers, size).

## Sources

- https://github.github.com/gh-aw/gallery/dependency-analysis/

## Design

Files: `workflows/dependency-analysis.md`, `workflows/dependency-analysis.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Dependency analysis: risky dependency changes"
on:
  pull_request:
    types: [opened, synchronize]
    paths: ['**/*.csproj', '**/package.json', '**/Cargo.toml', 'Directory.Packages.props']
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
network:
  allowed: [defaults, dotnet, node, rust]
safe-outputs:
  add-comment:
    max: 1
    hide-older-comments: true
---
```

```mermaid
flowchart LR
  T["pull_request"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: add-comment"]
```

## Code example

Prompt body:

```markdown
List added or bumped packages from the diff. For each: license, last release date, known advisories. One table comment.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/dependency-analysis@v1
git add .github/workflows/dependency-analysis.md .github/workflows/dependency-analysis.lock.yml
gh aw update dependency-analysis            # later, 3-way merge
gh aw logs dependency-analysis --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/dependency-analysis.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/dependency-analysis.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/dependency-analysis.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/dependency-analysis.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/dependency-analysis.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/dependency-analysis.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/dependency-analysis.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/dependency-analysis.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/dependency-analysis.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[dependency-analysis' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/dependency-analysis.lock.yml` | workflows/dependency-analysis.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/dependency-analysis/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/dependency-analysis.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
