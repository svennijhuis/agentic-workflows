# 034 pr-review: ignore docs-only and lock-only PRs

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | pr-review | [033](033-skip-bots-drafts.md) |

## Context

Docs-only or `.lock.yml`-only diffs do not need review agents.

## Sources

- https://github.github.com/gh-aw/reference/triggers/

## Design

```yaml
on:
  pull_request:
    paths-ignore: ['**/*.md', '**/*.lock.yml', 'docs/**']
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | paths-ignore | `rg -c 'paths-ignore:' workflows/pr-review.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
