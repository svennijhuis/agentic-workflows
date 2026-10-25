# 044 Disable and uninstall runbook

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Governance | [001](001-central-catalog-layout.md) |

## Context

Fast kill switch: `gh aw disable`, delete lock file, or remove workflow.

## Sources

- https://github.github.com/gh-aw/guides/safe-rollout/
- https://github.github.com/gh-aw/setup/cli/

## Design

```bash
gh aw disable pr-review
git rm .github/workflows/pr-review.md .github/workflows/pr-review.lock.yml
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Runbook | `rg -c 'gh aw disable' docs/GOVERNANCE.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
