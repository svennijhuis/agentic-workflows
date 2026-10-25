# 043 pr-review consumer page

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | pr-review | F00 |

## Context

One page: install, secret, trim stacks, triggers, cost, uninstall.

## Sources

- https://github.github.com/gh-aw/guides/sharing-workflows/

## Design

`docs/CONSUMING.md#pr-review` with a 10-line quickstart.

## Code example

```bash
gh aw add svennijhuis/agentic-workflows/pr-review@v1
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Section | `rg -c '^## pr-review' docs/CONSUMING.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
