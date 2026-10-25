# 084 Measure impact with outcomes

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Ops | F00 |

## Context

Count accepted safe outputs (resolved comments, merged PRs) per workflow; drop workflows nobody acts on.

## Sources

- https://github.github.com/gh-aw/reference/outcomes/
- https://github.github.com/gh-aw/guides/measuring-impact/
- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (points 20, 31)

## Design

```bash
gh aw logs --outcomes --start-date -30d --json
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Report in token-audit | `rg -c 'outcomes' workflows/token-audit.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
