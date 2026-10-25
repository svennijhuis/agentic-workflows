# 085 Forecast monthly AIC

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Ops | [076](076-token-audit.md) |

## Context

Predict month spend vs 1,500 AIC Pro budget.

## Sources

- https://github.github.com/gh-aw/specs/forecast-specification/

## Design

```bash
gh aw forecast --repo svennijhuis/<repo> --json
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Forecast in audit | `rg -c 'forecast' workflows/token-audit.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
