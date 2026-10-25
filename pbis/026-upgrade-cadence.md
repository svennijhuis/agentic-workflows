# 026 gh-aw upgrade cadence

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Platform | [006](006-release-tags.md) |

## Context

gh-aw ships weekly (v0.93.4 now). Monthly: `gh extension upgrade gh-aw`, `gh aw upgrade --create-pull-request`, recompile, read weekly-update blog. Gist: much of agent volume is gardening; keep the tooling current.

## Sources

- https://github.github.com/gh-aw/setup/cli/
- https://github.github.com/gh-aw/reference/releases/
- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (points 19)

## Design

```bash
gh extension upgrade gh-aw
gh aw upgrade --create-pull-request
gh aw fix --write
gh aw compile --dir workflows --strict
```

## Code example

Version recorded in CHANGELOG per release.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Version noted | `rg -c 'gh-aw v[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md` | >= 1 |
| 2 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
