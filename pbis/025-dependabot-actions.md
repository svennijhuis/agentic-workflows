# 025 Dependabot for compiled actions

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Security | [001](001-central-catalog-layout.md) |

## Context

`gh aw compile --dependabot` emits manifests so action pins in lock files get update PRs.

## Sources

- https://github.github.com/gh-aw/reference/dependabot/
- https://github.github.com/gh-aw/setup/cli/

## Design

```bash
gh aw compile --dir workflows --dependabot
```
Commit generated `.github/dependabot.yml` entries.

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Manifest generated | `test -f .github/dependabot.yml && echo ok` | ok |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
