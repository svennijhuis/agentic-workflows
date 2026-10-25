# 023 Manual approval environment for writes

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Security | [020](020-staged-rollout.md) |

## Context

Writes to main-adjacent branches can require an Actions environment approval. Gist: two-way doors (revertible: draft PR, staged) can be automated; one-way doors (push to branch, release, delete) get this approval gate.

## Sources

- https://github.github.com/gh-aw/reference/frontmatter/
- https://github.github.com/gh-aw/guides/safe-rollout/
- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (points 23)

## Design

```yaml
on:
  manual-approval: production
```

## Code example

Environment `production` with Sven as reviewer.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Set on write workflows | `rg -c 'manual-approval:' workflows/pr-fix.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Adds latency; only for workflows that push.

## Post-merge

None beyond merge.
