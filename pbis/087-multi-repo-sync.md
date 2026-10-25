# 087 MultiRepoOps: sync catalog updates to consumers

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Patterns | [086](086-control-plane.md) |

## Context

After a catalog tag, open `gh aw update` PRs in each consumer.

## Sources

- https://github.github.com/gh-aw/patterns/multi-repo-ops/
- https://github.github.com/gh-aw/gallery/multi-repo/feature-sync/

## Design

Worker runs `gh aw update --create-pull-request` in the target checkout.

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | PR per consumer | `gh pr list --repo OWNER/REPO --search 'gh aw update' \| wc -l` | >= 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
