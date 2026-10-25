# 024 Footer with run link and AIC

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Ops | [003](003-cost-caps.md) |

## Context

Every agent comment shows run link and AIC so cost is visible where it happens.

## Sources

- https://github.github.com/gh-aw/reference/footers/

## Design

```yaml
safe-outputs:
  messages:
    footer: "> {workflow_name} [run]({run_url}){ai_credits_suffix}"
```

## Code example

Shared in each workflow (messages merge rules: once per workflow).

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Footer set | `rg -c 'ai_credits_suffix' workflows/pr-review.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
