# Triggers, fuzzy schedule, cooldown

Catalog rule: every workflow lists `workflow_dispatch` first and, until Sven says otherwise, that is the only trigger ([POL25](../../policies/POL25.yml)). Shared fragments have no `on:`. Class defaults and the admission order live in [shared/defaults.md](../../workflows/shared/defaults.md). This page is the syntax reference. It does not enable a schedule.

## Dispatch and safe inputs

```yaml
on:
  workflow_dispatch:
    inputs:
      pr:
        description: Pull request number to review
        required: true
        type: number
```

Safe inputs:

- Id starts with a letter or `_` and then uses only letters, digits, `-`, or `_`. Prefer lowercase.
- `description` is set.
- `required: true` when the run needs a target.
- `type` is `string`, `choice`, `boolean`, `number`, or `environment`. `choice` also needs `options`.
- No default that starts the agent with an empty target.

`workflows/squad-review.md` is the catalog review workflow: required `pr` number, `on.cooldown: 15m`, and concurrency `squad-review-${{ github.event.inputs.pr }}` with `job-discriminator: ${{ github.run_id }}`. The review-class `user-rate-limit` (5 runs per 60 minutes, `ignored-roles: []` so the owner is not exempt) is compiled on `test/fixtures/r01/review-dispatch.md`. The compiler prints `experimental feature: rate limiting` for that key, so the installed workflow does not carry it.

## Schedule stays off

A `schedule` key is not added until both of these exist:

1. A `sven_yes` row in `policies/POL25.yml` whose `workflow` is the basename (no `.md` or `.lock.yml`), with a non-blank `date` and a non-blank `quote`.
2. The same yes recorded in that workflow's PBI Evidence.

`sven_yes` is empty. M03 and F03 stay on `workflow_dispatch` only. This page describes the strings Sven would approve later. Do not copy them into catalog frontmatter before that yes.

## Fuzzy schedule syntax

gh-aw v0.93.4 accepts a shorthand string or a cron string. Fuzzy forms scatter the minute (and sometimes the hour) from a repository seed so repos do not fire together. Fixed clock times use cron, not `at`.

Rejected: `daily at 9am`. The compiler error says to use `daily`, `daily around <time>`, `daily between <start> and <end>`, or cron.

Proven with `gh aw compile --strict` and `--schedule-seed svennijhuis/agentic-workflows` on a throwaway file that was not committed (it contained `schedule`, so it cannot live in this repo):

| String | Scattered cron for this seed |
| --- | --- |
| `hourly` | `24 */1 * * *` |
| `every 1h` | `24 */1 * * *` |
| `daily` | `21 13 * * *` |
| `daily around 9am` | `49 8 * * *` |
| `daily between 9:00 and 11:00` | `49 9 * * *` |
| `weekly on monday` | `21 13 * * 1` |
| `weekly on monday around 9am` | `49 8 * * 1` |
| `every 30 minutes` | `19/30 * * * *` |

Another repository slug scatters to a different minute. The minimum interval is 5 minutes. `on.cooldown` shorter than `5m` fails compile (`4m` was rejected).

Future use, still disabled:

- M03 exception watcher: primary trigger `workflow_dispatch`. After Sven's yes, fuzzy `hourly` or `every 1h` (same scatter for this seed). Suggested cooldown `45m` so a manual run and the hourly scatter do not stack.
- F03 daily repo status: primary trigger `workflow_dispatch`. After Sven's yes, fuzzy `daily` or `daily around 9am`. Suggested cooldown `20h`.

## Cooldown and rate limit by class

`on.cooldown` uses Go duration syntax (`5m`, `15m`, `1h`, `1h30m`, `20h`). It is the wait after the last completed run whose agent job started. It applies to every actor, including admins. GitHub Actions expressions are not allowed in the value.

`user-rate-limit` is top level (the old `rate-limit` key is renamed by the compiler):

- `max-runs-per-window` (required): integer 1 to 10
- `window`: minutes, 1 to 180, default 60
- `events`: optional, includes `workflow_dispatch`
- `ignored-roles`: default admin, maintain, and write. The owner is exempt unless this is `[]`

Review class (PR review, squad-review, later F01). Cooldown is what the catalog workflow sets. The rate limit stays on `test/fixtures/r01/review-dispatch.md` (`ignored-roles: []`) until the experimental warning is gone.

```yaml
on:
  workflow_dispatch:
    inputs:
      pr:
        description: Pull request number to review
        required: true
        type: number
  cooldown: 15m
concurrency:
  group: squad-review-${{ github.event.inputs.pr }}
  cancel-in-progress: true
  job-discriminator: ${{ github.run_id }}
```

`15m` compiles to `GH_AW_COOLDOWN_SECONDS` `900`.

Daily report class (F03 and similar, not enabled). Cooldown and `skip-if-match` are the class guards. The 1 run per 180 minutes key, with `ignored-roles: []`, stays on `test/fixtures/r01/daily-report-dispatch.md`.

```yaml
on:
  workflow_dispatch: {}
  cooldown: 20h
  skip-if-match:
    query: "is:issue is:open label:status-report"
    max: 1
concurrency:
  group: daily-report-${{ github.repository }}
  cancel-in-progress: false
  job-discriminator: ${{ github.run_id }}
```

`20h` compiles to `72000` seconds. The rate-limit window cannot cover a full day (max 180 minutes), so the day guard is cooldown, not the window.

## Admission before the agent

Compiler pre-activation order when the keys are set: roles, then `user-rate-limit`, then `on.cooldown`, then `on.skip-if-match`, then skip-bots. A failed check leaves `activated` false, so the agent job does not start (0 AIC). `skip-if-match` is a GitHub search scoped to the current repository. A string form implies max 1. The object form needs `query` and optional `max`.

`skip-if-no-match` is the opposite: no search hit skips the run. Issue and label filters that use it belong to R02.

When activation passes and there is nothing to do, the workflow's deterministic pre-check writes noop and still spends 0 AIC. Only the remaining path starts the capped agent.

Token-using checks (search, rate limit, cooldown history) are not run here. The offline proof is `make compile`, which runs `gh aw compile --strict` on `workflows/` and on a copy of `test/fixtures/r01/`. POL25 also scans that directory, so a `schedule` key there fails the gate. The review fixture sets `ignored-roles: []`.
