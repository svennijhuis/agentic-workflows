# 041 Graders/evals for review quality

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | pr-review | F00 |

## Context

Score reviews on seeded-bug PRs to catch regressions after agentPacks bumps.

## Sources

- https://github.github.com/gh-aw/specs/graders-specification/
- https://github.github.com/gh-aw/experimental/trace-graders/

## Design

Seeded PR set in a trial repo; grader checks the seeded bug is mentioned.

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Grader run | `gh aw trial ./workflows/pr-review.md --repeat 3` | 3 runs, seeded bug found 3/3 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Experimental feature; spec may change.

## Post-merge

None beyond merge.
