# 021 Rate limits and concurrency on event workflows

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Cost | [003](003-cost-caps.md) |

## Context

`pull_request` and comment triggers scale with activity. Cap per-user runs and serialise.

## Sources

- https://github.github.com/gh-aw/reference/rate-limiting-controls/
- https://github.github.com/gh-aw/reference/concurrency/

## Design

```yaml
user-rate-limit:
  max-runs-per-window: 3
  window: 60
concurrency:
  group: pr-review-${{ github.event.pull_request.number || github.event.issue.number }}
  cancel-in-progress: true
```

## Code example

Applies to pr-review, pr-fix, repo-ask.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | pr-review limited | `rg -c 'max-runs-per-window: 3' workflows/pr-review.md` | 1 |
| 2 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
