# 03 Cost caps

Goal: a run cannot burn the month.

DoD:
- [x] `max-ai-credits: 50`, `max-daily-ai-credits: 200`, `max-turns: 15`, `timeout-minutes: 10` on every workflow
- [x] In frontmatter (compiler ignores them in imports, verified)
- [x] Lock shows `GH_AW_MAX_AI_CREDITS: "50"`, `GH_AW_MAX_DAILY_AI_CREDITS: "200"`, `GH_AW_MAX_TURNS: 15`, `timeout-minutes: 10`

Status: done.
