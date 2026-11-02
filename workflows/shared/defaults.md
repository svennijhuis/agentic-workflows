---
description: Catalog defaults imported by every workflow. Engine copilot (pinned version), read-only GitHub tools. No caps here.
engine:
  id: copilot
  version: "1.0.101"
tools:
  github:
    toolsets: [repos, issues, pull_requests]
---

Catalog defaults (C03). Engine: copilot, version pinned in `.github/aw.json` and here (C06). Read-only GitHub tools; writes only through the importing workflow's safe-outputs.

Caps are not importable (the compiler ignores them in imports). Each workflow sets `max-ai-credits` (at most 50), `max-daily-ai-credits` (at most 200), `max-turns` and `timeout-minutes` in its own frontmatter.

Fetch your own context with the GitHub tools and the imports above. Do not expect repo content pasted into this prompt (gist A7).

## Dispatch, cooldown, and rate limits (R01)

`workflow_dispatch` is the only live trigger ([POL25](../../../policies/POL25.yml)). This fragment has no `on:`. Do not add `schedule` until Sven's exact yes is in that workflow's PBI Evidence and in `policies/POL25.yml` `sven_yes`. Fuzzy strings for a later yes (not enabled here): M03 `hourly` or `every 1h`; F03 `daily` or `daily around 9am`. `daily at 9am` is rejected. Grammar and scattered cron from gh-aw v0.93.4: [triggers](../../../docs/reference/triggers.md).

Safe dispatch inputs: lowercase id, `description`, `required: true` when the run needs a target, `type` one of `string`, `choice`, `boolean`, `number`, `environment`. No default that starts work with an empty target.

`on.cooldown` is a Go duration of at least `5m` (a `4m` value fails compile). It stops the next agent start for every actor. `user-rate-limit.max-runs-per-window` is 1 to 10. `window` is minutes from 1 to 180 (default 60). Default ignored roles are admin, maintain, and write, so the owner is exempt from the rate limit. Cooldown is not role based.

Review class (this catalog's PR review): cooldown `15m` on the workflow, at most 5 dispatch runs per 60 minutes (fixture, because `user-rate-limit` still warns as experimental), concurrency per pull request with `cancel-in-progress: true`.

```yaml
on:
  workflow_dispatch: {}
  cooldown: 15m
user-rate-limit:
  max-runs-per-window: 5
  window: 60
  events: [workflow_dispatch]
concurrency:
  group: review-<pull-request-number>
  cancel-in-progress: true
```

Daily report class (F03, not enabled): cooldown `20h`, at most 1 dispatch run per 180 minutes, concurrency per repository with `cancel-in-progress: false`. Before the agent, `on.skip-if-match` for an open report issue (max 1) or a deterministic noop.

```yaml
on:
  workflow_dispatch: {}
  cooldown: 20h
  skip-if-match:
    query: "is:issue is:open label:status-report"
    max: 1
user-rate-limit:
  max-runs-per-window: 1
  window: 180
  events: [workflow_dispatch]
concurrency:
  group: daily-report-<repository>
  cancel-in-progress: false
```

Admission before the agent, in compiler order (the agent stays off, 0 AIC, when a check fails): roles, then `user-rate-limit`, then `on.cooldown`, then `on.skip-if-match`, then skip-bots. A deterministic noop covers "nothing to do" when those checks pass. Only then does the capped agent start.
