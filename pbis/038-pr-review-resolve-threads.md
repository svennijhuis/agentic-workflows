# 038 pr-review: resolve fixed threads

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | pr-review | F00 |

## Context

When a later push fixes a finding, resolve that bot thread.

## Sources

- https://github.github.com/gh-aw/reference/safe-outputs/

## Design

```yaml
safe-outputs:
  resolve-pull-request-review-thread:
    max: 10
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Set | `rg -c 'resolve-pull-request-review-thread:' workflows/pr-review.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
