# 006 Release tags v1.0.0 + moving v1

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | Platform | [001](001-central-catalog-layout.md), [002](002-pin-agentpacks-imports.md) |

## Context

Consumers pin `@v1.0.0`; `@v1` follows the major on `gh aw update` unless `--major`. Tags are post-merge, done by Sven.

## Sources

- https://github.github.com/gh-aw/guides/sharing-workflows/
- https://github.github.com/gh-aw/reference/releases/

## Design

```bash
git tag v1.0.0 && git tag v1
git push origin v1.0.0 v1
# later minor: move only the major tag
git tag -f v1 v1.1.0^{} && git push origin v1 --force   # tag ref only
```
CHANGELOG section per tag; `Unreleased` becomes `v1.0.0`.

## Code example

```bash
gh aw add svennijhuis/agentic-workflows/pr-review@v1.0.0
gh aw update pr-review           # stays on v1
gh aw update pr-review --major   # crosses majors
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Tag exists | `git ls-remote --tags origin v1.0.0 v1 \| wc -l` | 2 |
| 2 | CHANGELOG has section | `rg -c '^## v1.0.0' CHANGELOG.md` | 1 |
| 3 | Install from tag works | `gh aw add svennijhuis/agentic-workflows/pr-review@v1.0.0 --dir /tmp/t && ls /tmp/t` | pr-review.md |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No GitHub Release automation yet (054).

## Risks

Moving `v1` needs a tag force update; never a branch force push.

## Post-merge

None beyond merge.
