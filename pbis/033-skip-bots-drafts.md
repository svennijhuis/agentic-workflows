# 033 pr-review: skip bots and drafts

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | pr-review | [002](002-pin-agentpacks-imports.md) |

## Context

Dependabot and draft PRs burn AIC for nothing. Pre-activation skip costs 0 AIC.

## Sources

- https://github.github.com/gh-aw/reference/triggers/
- https://github.github.com/gh-aw/reference/cost-management/

## Design

```yaml
on:
  pull_request:
    types: [opened, synchronize, ready_for_review]
  skip-bots: [dependabot, renovate]
  skip-if-match: 'is:pr is:draft'
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | skip-bots | `rg -c 'skip-bots:' workflows/pr-review.md` | 1 |
| 2 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

skip-if-match is a search query, not the event PR; verify it targets the triggering PR or use `if:`.

## Post-merge

None beyond merge.
