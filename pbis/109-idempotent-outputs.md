# 109 Idempotent outputs: dedupe keys everywhere

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Cross-repo | [001](001-central-catalog-layout.md) |

## Context

Re-runs must converge: every create-issue has `title-prefix` + `close-older-issues` or a search-then-comment rule; every PR workflow has `skip-if-match` on its own open PR. Gist: a buffer issue that collects findings beats N noisy issues.

## Sources

- https://github.com/cursor/plugins/tree/main/pstack/skills/principle-make-operations-idempotent
- https://github.github.com/gh-aw/reference/safe-outputs/
- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (points 18)

## Design

```yaml
safe-outputs:
  create-issue:
    title-prefix: "[<wf>] "
    close-older-issues: true
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Every create-issue deduped | `rg -l 'create-issue:' workflows/*.md \| xargs rg -L 'close-older-issues\|search open'` | no output |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
