# 092 MemoryOps for watcher dedupe

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Patterns | [030](030-cache-memory-fragment.md), [078](078-exception-watcher.md) |

## Context

Watcher keeps last-seen problemIds in cache-memory to avoid comment spam.

## Sources

- https://github.github.com/gh-aw/patterns/memory-ops/

## Design

```yaml
tools:
  cache-memory:
    key: exception-watcher
```
File: `/tmp/gh-aw/cache-memory/seen.json`.

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Key set | `rg -c 'key: exception-watcher' workflows/exception-watcher.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
