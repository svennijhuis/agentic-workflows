# 032 Fork PR policy for pr-review

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Security | [019](019-min-integrity.md) |

## Context

Public repo: fork PRs have no secrets. Decide: skip forks, or slash-command only by maintainers.

## Sources

- https://github.github.com/gh-aw/reference/fork-support/
- https://github.github.com/gh-aw/reference/triggers/

## Design

```yaml
on:
  pull_request:
    types: [opened, synchronize, ready_for_review]
  roles: [admin, maintainer, write]
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Roles set | `rg -c 'roles: \[admin, maintainer, write\]' workflows/pr-review.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
