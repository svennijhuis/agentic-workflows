# 031 repo-memory conventions

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Platform | [030](030-cache-memory-fragment.md) |

## Context

Durable memory on a `memory/<id>` branch for metrics (080). Branch prefix 4-32 chars, not `copilot`.

## Sources

- https://github.github.com/gh-aw/reference/repo-memory/

## Design

```yaml
tools:
  repo-memory:
    branch-prefix: memory
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Branch created after run | `git ls-remote origin 'refs/heads/memory/*' \| wc -l` | >= 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
