# 022 stop-after on pilot workflows

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Cost | F00 |

## Context

Pilots should die on their own. `on.stop-after: +30d` disables after the deadline.

## Sources

- https://github.github.com/gh-aw/reference/triggers/

## Design

```yaml
on:
  schedule: daily
  stop-after: "+30d"
```

## Code example

`gh aw add ... --stop-after +14d` for consumers.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Pilots have deadline | `rg -c 'stop-after:' workflows/*.md` | >= 1 per pilot |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
