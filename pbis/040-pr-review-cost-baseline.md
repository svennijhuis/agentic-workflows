# 040 pr-review: AIC baseline after 10 runs

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | pr-review | F00 |

## Context

Caps are guesses. Measure, then set caps to p90 + 20%. Gist: measure a skill's impact, do not fly blind.

## Sources

- https://github.github.com/gh-aw/reference/audit/
- https://github.github.com/gh-aw/reference/cost-management/
- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (points 31)

## Design

```bash
gh aw logs pr-review --start-date -30d --json | jq '[.runs[].aic] | sort | .[(length*0.9|floor)]'
```

## Code example

Result into GOVERNANCE cost table.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Baseline recorded | `rg -n 'pr-review p90' docs/GOVERNANCE.md` | 1 line |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
