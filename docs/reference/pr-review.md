# pr-review

[`workflows/pr-review.md`](../../workflows/pr-review.md) is the report-only pull request review. Review behaviour lives in [agentPacks](https://github.com/svennijhuis/agentPacks). This catalog pins the skill and the review command. Trigger is `workflow_dispatch` only ([POL25](../../policies/POL25.yml)).

## Behaviour

- Engine copilot via [`workflows/shared/defaults.md`](../../workflows/shared/defaults.md).
- Read-only `permissions` (`contents`, `pull-requests`, `issues`, `actions`). `copilot-requests: none` until org billing. Writes go through `safe-outputs` only: one `submit-pull-request-review` event `COMMENT`, `staged: true`, plus `noop`.
- Caps in the workflow frontmatter, including `timeout-minutes: 15`.
- Committed `pr-review.lock.yml` (`make compile`).
- `skills:` in `pr-review.md` frontmatter, same 40-hex pin as C12b. Not in `workflows/shared/` ([POL31](../../policies/POL31.yml)).
- Review command import: `plugins/squad/commands/squad-review.md` at that same pin (tag or tagged-commit SHA when Q7 lands; not a branch ref).
- Deterministic pre-check writes `noop` and skips the agent when the diff is empty (0 AIC). Dedupe is the title marker, group-by-day, expiry of 7 days, and `supersede-older-reviews` for the older review (close-older). Token-using API calls are proven offline by `scripts/pr-review-precheck-fixtures.sh`.

Shared wiring: [`workflows/shared/agentpacks.md`](../../workflows/shared/agentpacks.md), [`defaults.md`](../../workflows/shared/defaults.md), [`security.md`](../../workflows/shared/security.md), [`reporting.md`](../../workflows/shared/reporting.md).

## Copy this

An org copies the workflow, its lock, and `workflows/shared/`. Standalone. No secrets in those files. Secret names (`COPILOT_GITHUB_TOKEN` and the compiler token names in the lock) are set in the consumer repo.

- `workflows/pr-review.md` (includes the `skills:` pin and the pre-check)
- `workflows/pr-review.lock.yml`
- `workflows/shared/defaults.md`
- `workflows/shared/security.md`
- `workflows/shared/reporting.md`
- `workflows/shared/agentpacks.md`

Nothing in `workflows/shared/` installs a skill.

## Install in a consumer repo

```bash
gh extension install github/gh-aw
gh aw init
gh aw add svennijhuis/agentic-workflows/pr-review@v1.0.0
git add .github/workflows/pr-review.md .github/workflows/pr-review.lock.yml
```

Run from the Actions tab (`workflow_dispatch`). Set `COPILOT_GITHUB_TOKEN` per [auth.md](auth.md). Do not run it from this catalog build. Live runs are a named ask.

## Not in this workflow

No slash command, no `pull_request`, no `push`. `/pr-review` and [F01b](../pbi/agent-factory/F01b-pr-review-auto-on-push.md) need Sven's exact yes and a row in `policies/POL25.yml` `sven_yes` first.

## Change review behaviour

Edit agentPacks, release a C12 tag, bump the pin in this catalog, recompile, run `make verify`. Do not fork the command text here.

## Removed with this workflow

`squad-review` is removed once `pr-review.md` carries the `skills:` pin:

- `workflows/squad-review.md`
- `workflows/squad-review.lock.yml`
- `workflows/squad-review.card.yml`
- `docs/reference/squad-review.md`
- the `workflows/squad-review.md` line in `aw.yml` `includes:`

`workflows/shared/agentpacks.md` stays. F01 imports it.
