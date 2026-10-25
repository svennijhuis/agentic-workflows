# 055 Test improver: one missing test per run

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Find one untested behaviour, add one behaviour test, open a draft PR. Matt `tdd` + pstack test-behavior principle. Gist: kill tautological tests; a test that cannot fail is deleted, not added.

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/test-improver.md
- https://github.com/mattpocock/skills/blob/main/skills/engineering/tdd/SKILL.md
- https://github.com/cursor/plugins/tree/main/pstack/skills/principle-test-behavior-not-implementation
- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (points 26)

## Design

Files: `workflows/test-improver.md`, `workflows/test-improver.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Test improver: one missing test per run"
on:
  schedule: weekly
  skip-if-match: 'is:pr is:open in:title "[test-improver]"'
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
  bash:
    - git:*
    - dotnet:*
    - npm:*
    - cargo:*
network:
  allowed: [defaults, dotnet, node, rust]
safe-outputs:
  create-pull-request:
    title-prefix: "[test-improver] "
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
Pick one public behaviour without a test. Write a test that asserts behaviour, not implementation. Run the suite. Draft PR with the test output.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/test-improver@v1
git add .github/workflows/test-improver.md .github/workflows/test-improver.lock.yml
gh aw update test-improver            # later, 3-way merge
gh aw logs test-improver --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/test-improver.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/test-improver.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/test-improver.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/test-improver.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/test-improver.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/test-improver.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/test-improver.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/test-improver.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/test-improver.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[test-improver' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/test-improver.lock.yml` | workflows/test-improver.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/test-improver/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/test-improver.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
