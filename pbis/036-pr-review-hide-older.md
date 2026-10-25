# 036 pr-review: hide older review summaries

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | pr-review | F00 |

## Context

Each push re-reviews; old summary comments pile up.

## Sources

- https://github.github.com/gh-aw/reference/safe-outputs/

## Design

```yaml
safe-outputs:
  add-comment:
    max: 1
    hide-older-comments: true
```
Summary moves to one hidden-older comment; inline comments stay.

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Set | `rg -c 'hide-older-comments: true' workflows/pr-review.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
