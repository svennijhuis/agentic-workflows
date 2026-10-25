# 114 Sven decision: pr-review auto trigger or slash only

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | pr-review | [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

`pr-review.md` fires on `pull_request` opened/synchronize/ready_for_review, so every push in a consuming repo spends AIC once `COPILOT_GITHUB_TOKEN` is set. Gist point 23: automate two-way doors with gates sized to cost. Explicit yes/no for Sven, no code until decided.

## Sources

- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (point 23)
- https://github.github.com/gh-aw/reference/cost-management/
- https://github.github.com/gh-aw/reference/command-triggers/

## Design

Option A (today):
```yaml
on:
  pull_request:
    types: [opened, synchronize, ready_for_review]
  workflow_dispatch:
  slash_command:
    strategy: centralized
    name: pr-review
    events: [pull_request_comment]
```
Option B (slash + manual only):
```yaml
on:
  workflow_dispatch:
  slash_command:
    strategy: centralized
    name: pr-review
    events: [pull_request_comment]
```

## Code example

Cost per option: A = runs x avg AIC (capped 50, 200/day); B = only when asked.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Decision recorded | `rg -n 'pr-review trigger: (A\|B)' docs/GOVERNANCE.md` | 1 line |
| 2 | Frontmatter matches decision | `rg -c '^  pull_request:' workflows/pr-review.md` | 1 for A, 0 for B |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No change before Sven answers.

## Risks

A on a busy repo hits the 200/day cap quickly; B needs people to remember /pr-review.

## Post-merge

None beyond merge.
