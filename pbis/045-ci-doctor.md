# 045 CI Doctor: root-cause failed CI

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Failed CI on main costs the most attention. Investigate the failed run, dedupe against open `[ci-doctor]` issues, comment or open one issue. Matt `diagnosing-bugs` loop (reproduce, minimise, hypothesise) shapes the prompt. Gist: reproduce on main before fixing; group related failures so one shared root cause is found.

## Sources

- https://github.github.com/gh-aw/gallery/ci-failure-investigation/
- https://github.com/githubnext/agentics/blob/main/workflows/ci-doctor.md
- https://github.com/mattpocock/skills/blob/main/skills/engineering/diagnosing-bugs/SKILL.md
- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (points 16, 17)

## Design

Files: `workflows/ci-doctor.md`, `workflows/ci-doctor.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "CI Doctor: root-cause failed CI"
on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]
    branches: [main]
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
  actions: read
  issues: read
  copilot-requests: none
tools:
  github:
    toolsets: [repos, issues, actions]
safe-outputs:
  create-issue:
    title-prefix: "[ci-doctor] "
    labels: [ci-doctor]
    max: 1
    close-older-issues: true
    expires: 7
  add-comment:
    max: 1
---
```

```mermaid
flowchart LR
  T["workflow_run"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: create-issue, add-comment"]
```

## Code example

Prompt body:

```markdown
Only act when `${{ github.event.workflow_run.conclusion }}` is `failure`; else noop.
Read failed job logs (`gh run view --log-failed` via actions toolset). Search open issues with title prefix `[ci-doctor]` for the same failing step: comment there instead of opening a new one.
Report: failing step, first error line, likely cause, smallest fix, confidence.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/ci-doctor@v1
git add .github/workflows/ci-doctor.md .github/workflows/ci-doctor.lock.yml
gh aw update ci-doctor            # later, 3-way merge
gh aw logs ci-doctor --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/ci-doctor.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/ci-doctor.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/ci-doctor.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/ci-doctor.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/ci-doctor.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/ci-doctor.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/ci-doctor.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/ci-doctor.md` | >= 2 |
| 9 | In manifest | `rg -c 'workflows/ci-doctor.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[ci-doctor' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/ci-doctor.lock.yml` | workflows/ci-doctor.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/ci-doctor/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/ci-doctor.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |
| 15 | Skips green runs | `rg -n "conclusion != 'failure'\|if:" workflows/ci-doctor.md` | >= 1 line (job-level if or noop rule) |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
