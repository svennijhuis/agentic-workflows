# 015 Cheap model for triage-class workflows

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Cost | [003](003-cost-caps.md) |

## Context

Labeling, summaries, reports do not need frontier models. Pin a small model per workflow class.

## Sources

- https://github.github.com/gh-aw/reference/cost-management/
- https://github.github.com/gh-aw/reference/engines/copilot/
- https://github.github.com/gh-aw/reference/model-tables/

## Design

```yaml
engine:
  id: copilot
  model: gpt-5-mini     # triage, reports
# pr-review keeps default model
```
Class table in `docs/GOVERNANCE.md#cost`.

## Code example

Compare AIC before/after with `gh aw logs <wf> --json`.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Model set on report workflows | `rg -l 'model: gpt-5-mini' workflows \| wc -l` | >= 3 |
| 2 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Unavailable model id fails first inference; check model tables.

## Post-merge

None beyond merge.
