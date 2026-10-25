# 030 cache-memory conventions

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Platform | [001](001-central-catalog-layout.md) |

## Context

Trend workflows (076, 078) need state across runs. `cache-memory` stores files at `/tmp/gh-aw/cache-memory/` with a workflow key.

## Sources

- https://github.github.com/gh-aw/reference/cache-memory/
- https://github.github.com/gh-aw/patterns/memory-ops/

## Design

```yaml
tools:
  cache-memory:
    key: <workflow-name>
```
Rule: one key per workflow, JSON lines, 30 day horizon.

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Key equals workflow name | `rg -n 'key: ' workflows/token-audit.md` | key: token-audit |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
