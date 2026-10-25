# 016 Model routing (later)

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Cost | [015](015-cheap-model-tier.md) |

## Context

Task-level routing picks a model per request; classifier overhead costs AIC. Evaluate only after 076 shows spend.

## Sources

- https://github.github.com/gh-aw/reference/model-routing/

## Design

```yaml
model-routing:
  enabled: true
```
(Exact keys from reference/model-routing before use.)

## Code example

`gh aw logs --format markdown` shows selected-model cost.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Decision logged | `rg -n 'model-routing' docs/GOVERNANCE.md` | 1 line |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No routing in v1.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
