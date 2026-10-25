# 082 Report failed runs as issues

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Ops | [003](003-cost-caps.md) |

## Context

Silent failures waste days. Failed agent runs open one deduped issue.

## Sources

- https://github.github.com/gh-aw/reference/frontmatter/
- https://github.github.com/gh-aw/patterns/monitor-ops/

## Design

```yaml
safe-outputs:
  report-failure-as-issue: true
```
(key name verified in frontmatter-full; confirm placement before use)

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Set on pr-review | `rg -c 'report-failure-as-issue' workflows/pr-review.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
