# 017 Threat detection budget

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Security | [003](003-cost-caps.md) |

## Context

Threat detection runs on every safe-output run with its own 400 AIC default. Cap it low for small workflows.

## Sources

- https://github.github.com/gh-aw/reference/threat-detection/
- https://github.github.com/gh-aw/reference/cost-management/

## Design

```yaml
safe-outputs:
  threat-detection:
    max-ai-credits: 40
```

## Code example

Applies to pr-review first.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Cap set | `rg -c 'max-ai-credits: 40' workflows/pr-review.md` | 1 |
| 2 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Too low a cap may fail detection; watch first 10 runs.

## Post-merge

None beyond merge.
