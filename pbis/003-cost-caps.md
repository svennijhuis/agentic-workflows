# 003 Low cost caps on every workflow

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Done | Cost | [001](001-central-catalog-layout.md) |

## Context

Defaults are 1,000 AIC/run and 5,000 AIC/day; Copilot Pro is 1,500 AIC/month. Cap low.

## Sources

- https://github.github.com/gh-aw/reference/cost-management/
- https://github.github.com/gh-aw/reference/billing/
- https://docs.github.com/en/copilot/concepts/billing-and-usage/individuals/billing

## Design

```yaml
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
```
Observed: in an imported fragment the compiler prints `Ignoring unexpected frontmatter fields in .../shared/defaults.md: max-ai-credits, max-daily-ai-credits, max-turns, timeout-minutes`. Caps must be in each workflow's own frontmatter.

## Code example

Lock output: `GH_AW_MAX_AI_CREDITS: "50"`, `GH_AW_MAX_DAILY_AI_CREDITS: "200"`, `GH_AW_MAX_TURNS: 15`, `timeout-minutes: 10`.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Caps in every workflow | `for f in workflows/*.md; do [ $f = workflows/README.md ] \|\| rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' $f; done` | 4 per workflow |
| 2 | Lock per-run cap | `rg -c 'GH_AW_MAX_AI_CREDITS: "50"' workflows/pr-review.lock.yml` | >= 1 |
| 3 | Lock daily cap | `rg -c 'GH_AW_MAX_DAILY_AI_CREDITS: "200"' workflows/pr-review.lock.yml` | >= 1 |
| 4 | Lock turns | `rg -c 'GH_AW_MAX_TURNS: 15$' workflows/pr-review.lock.yml` | 1 |

## Evidence

Lock lines 126/233/234/1185/1100 show the four caps (see PR #2 body).

## Non-goals

No admission service. No org-level defaults (014).

## Risks

Daily cap is cooperative; concurrent runs can overshoot. 50 AIC may be too low for big PRs: measure with `gh aw logs` (040).

## Post-merge

See PR #2 post-merge list: tag v1.0.0 + v1, set COPILOT_GITHUB_TOKEN, decide visibility.
