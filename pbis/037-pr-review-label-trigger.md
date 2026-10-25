# 037 pr-review: label trigger alternative

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | pr-review | [033](033-skip-bots-drafts.md) |

## Context

Busy repos: drop `synchronize`, review only on label `review`.

## Sources

- https://github.github.com/gh-aw/reference/triggers/
- https://github.github.com/gh-aw/patterns/label-ops/

## Design

```yaml
on:
  label_command:
    name: review
    events: [pull_request]
```

## Code example

Consumer choice documented in CONSUMING.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Documented | `rg -c 'label_command' docs/CONSUMING.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
