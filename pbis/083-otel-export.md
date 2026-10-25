# 083 OpenTelemetry export (later)

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Ops | [076](076-token-audit.md) |

## Context

Only if multiple repos run agents; 076 covers single repo.

## Sources

- https://github.github.com/gh-aw/reference/open-telemetry/

## Design

```yaml
observability:
  otlp:
    endpoint: ${{ secrets.OTLP_ENDPOINT }}
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Decision logged | `rg -c 'otlp' docs/GOVERNANCE.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No backend chosen in v1.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
