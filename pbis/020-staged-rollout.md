# 020 Staged mode for new write workflows

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | Security | [001](001-central-catalog-layout.md) |

## Context

Rollout ladder: report-only, `staged: true` (preview outputs, no writes), then prod. Every new write workflow starts staged.

## Sources

- https://github.github.com/gh-aw/reference/staged-mode/
- https://github.github.com/gh-aw/guides/safe-rollout/
- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (points 23)

## Design

```yaml
safe-outputs:
  staged: true
  create-pull-request:
    draft: true
    max: 1
```

## Code example

Flip to false after 5 good runs (evidence in the PBI).

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | New write workflows staged | `rg -l 'create-pull-request:\|push-to-pull-request-branch:' workflows \| xargs rg -L 'staged: true'` | no output until promoted |
| 2 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
