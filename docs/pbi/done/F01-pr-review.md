# F01: PR review (replaces squad-review)
- Status: done
- PR: #PENDING
- Area: agent-factory
- Wave: W3
- Block: 2, 3
- Lane: Builder
- Depends on: C03, C04, C05, C06, C12, C12b
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/pr-review.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: two-way
- triage: build (Block 2 workflow)
- feedback: `make compile` (`gh aw compile --strict`)
- harness: gh-aw, engine copilot via shared/defaults.md (when built)
- review-input: diff + this PBI + DoD (+ linked spec) + PR description, never builder session logs (PA6)
- kind: skill
- Source: PA8 (pre-link PBI edited in PR #4, origin in its Sources) https://github.com/svennijhuis/agentic-workflows/pull/4
- Module boundary: the agentPacks review command import is the interface; the review contract stays in agentPacks
## Goal
Ship `pr-review.md` as Copilot report-only PR review with C12 v1.1 agentPacks pins (tag on generated commit, not main SHA), replacing temporary `squad-review.md` after this workflow passes Bar H.
## Context
Upstream reference: [automated-pr-review](https://github.github.com/gh-aw/gallery/automated-pr-review/). Replaces [PR #2](https://github.com/svennijhuis/agentic-workflows/pull/2) pr-review pin `@34e1dec`. **Trigger:** `workflow_dispatch` only (POL25, `sven_yes` empty). The `/pr-review` slash command is a named ask for a later Sven yes, recorded in `policies/POL25.yml` `sven_yes` before it exists. No `pull_request` or `push` trigger. This PBI is offline proof only; the X01 staged smoke and live manual runs are named asks. Auto on push is [F01b](../agent-factory/F01b-pr-review-auto-on-push.md), gated separately.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal fine-grained PAT). Review output COMMENT only via `safe-outputs`; no org billing write scopes.

## Frontmatter security
- `permissions:` read only (`contents: read`, `pull-requests: read`, `issues: read`, `actions: read`); no write permission on the token.
- Writes only through `safe-outputs`: `submit-pull-request-review` (COMMENT only, `max: 1`), `staged: true` until Sven's yes.
- `timeout-minutes:` 15 (fits a single PR review pass).
- Trigger: `workflow_dispatch` only (POL25). `/pr-review` slash or `pull_request` (F01b) are named asks for Sven, recorded in `policies/POL25.yml` `sven_yes` first.

## Steps
1. Add `workflows/pr-review.md`; import `shared/defaults.md`, `shared/security.md`, and the C12-pinned agentPacks review command (`imports:` pin). Put the same `skills:` pin from `workflows/squad-review.md` in `workflows/pr-review.md` frontmatter (not in a shared fragment, POL31).
2. Set frontmatter security (read-only `permissions`, `safe-outputs` with `staged: true` and a `max` per output, `timeout-minutes`, `workflow_dispatch` only).
3. Add deterministic pre-check; writes `noop` when empty diff.
4. Run `make compile` and commit the `.lock.yml`.
5. Run `make verify`.
6. Write the "copy this" note at `docs/reference/pr-review.md` (md, lock, `workflows/shared/` files an org copies, standalone, no secrets).
7. On merge: remove `squad-review.md` only after `pr-review.md` carries the `skills:` pin; list removed files in the PR description.

## Definition of Done
- [x] `workflows/pr-review.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [x] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [x] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [x] `make verify` exits 0; no run, no token spend
- [x] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [x] `workflows/pr-review.md` imports `shared/defaults.md` (engine copilot, admission)
- [x] C12 v1.1 agentPacks `skills:` list in `workflows/pr-review.md` frontmatter (same pin as C12b, moved from `squad-review.md` before it is removed) plus the review command as an `imports:` pin (tag or tagged-commit SHA, not main)
- [x] Deterministic pre-check; writes `noop` when nothing to do (0 AIC)
- [x] Dedupe via title, `group-by-day`, `close-older-issues`, and expiry
- [x] `workflow_dispatch` only, plus the "copy this" note in `docs/reference/pr-review.md`
- [x] No slash, `pull_request` or `push` trigger in this PBI (slash and F01b are named asks)
- [x] [X07](../testing/X07-workflow-benchmark.md) benchmark cases: 5 or more fixed cases with known answers written in `docs/benchmarks/<workflow>.md`, docs only, no run; the X07 score is a named ask
## Technical design
- Components and files: `workflows/pr-review.md`, `workflows/pr-review.lock.yml`, `workflows/pr-review.card.yml`, `docs/reference/pr-review.md`, `docs/benchmarks/pr-review.md`, `scripts/pr-review-precheck-fixtures.sh`, `test/fixtures/pr-review/`. Removed: `workflows/squad-review.md`, `workflows/squad-review.lock.yml`, `workflows/squad-review.card.yml`, `docs/reference/squad-review.md`, and the `aw.yml` includes line for squad-review.
- Module boundary: the agentPacks review command import is the interface; the review contract stays in agentPacks
- Interfaces: `workflow_dispatch` input `pr`; `skills:` and `imports:` pins at `34e1dec3535baa1d77cb441ea8c98498dc9b3684`; `safe-outputs` `noop` (`max: 1`, `report-as-issue: false`) and `submit-pull-request-review` (`max: 1`, `allowed-events: [COMMENT]`, `supersede-older-reviews: true`, `staged: true`); pre-check output `empty`
- Sequence:

```mermaid
sequenceDiagram
  participant Dev as Contributor
  participant GH as GitHub
  participant WF as pr-review
  participant Agent as Copilot
  Dev->>GH: workflow_dispatch (PR number input)
  GH->>WF: start run
  WF->>WF: pre-check (noop if empty)
  alt empty or already reviewed
    WF-->>GH: noop, agent skipped, 0 AIC
  else diff to review
    WF->>Agent: review with caps
    Agent-->>WF: findings
    WF->>GH: COMMENT review only
  end
```

- Failure modes: pre-check API error fails `diff_precheck` and the agent `if` stays false (0 AIC). A non-digit PR number fails the step. Lock drift fails `make verify`.
- Security: frontmatter permissions are read only. Writes only through staged safe-outputs, COMMENT only. No secret values. Threat detection comes from `shared/security.md`. Network allowlist is `defaults`. Tool allowlist is github toolsets plus a bash allowlist. `min-integrity: approved`. `on.roles` and `skip-bots` are set.
- Observability: step summary line `noop: <reason>` or `review: <reason>`. Compile log and `make verify` on the PR head (Q0).
- Cost: 0 AIC for this build. A live review is about 30-50 AIC and is a named ask.
- Rollback: revert this PR. That restores `squad-review` and removes `pr-review`.
- Proof: `make verify` exits 0
- Door: two-way (offline compile, no token spend)
## Evidence
Offline only. No workflow run and no token spend.

`make verify` exit 0. Last line `0 failures`. `gh aw compile --strict` on `workflows/pr-review.md`: 0 errors, 0 warnings, lock unchanged after compile. POL25 repo clean. POL25 fixtures: 37 bad cases, 7 good cases. POL31 repo clean. POL31 fixtures: 8 bad cases, 1 good cases.

`gh aw compile --strict --actionlint` (actionlint 1.7.12 with shellcheck and pyflakes): No issues found.

`scripts/pr-review-precheck-fixtures.sh` (no network, no token): 6 cases ok (`empty-diff`, `new-diff`, `group-by-day`, `title-within-expiry`, `expired`, `new-commits`).

Dedupe is not a `create-issue` block. This workflow does not create issues. Title marker `<!-- aw-pr-review -->`, group-by-day, and a 7 day expiry are the pre-check. Close-older is `supersede-older-reviews: true` on the COMMENT review.

The agentPacks pin is the C12b 40-hex SHA, not a branch ref. A `vX.Y.Z` tag remains named ask Q7.
## Flow
```mermaid
sequenceDiagram
  participant Dev as Contributor
  participant GH as GitHub
  participant WF as pr-review
  participant Agent as Copilot
  Dev->>GH: workflow_dispatch (PR number input)
  GH->>WF: start run
  WF->>WF: pre-check (noop if empty)
  WF->>Agent: review with caps
  Agent-->>WF: findings
  WF->>GH: COMMENT review only
```
## Named asks for Sven
- Q7 (agentPacks tag pin); Q3 (PAT); squad-review removal file list on merge
- X01 staged smoke, then 3 audited manual runs with measured AIC in Evidence (B02, Bar H live part): Sven exact yes, it spends tokens
- `/pr-review` slash command trigger: Sven exact yes, row in `policies/POL25.yml` `sven_yes` first
- X07 benchmark score at or above baseline (Bar H): each score is a live [X07](../testing/X07-workflow-benchmark.md) run on the X01 repo (`door: one-way`), Sven exact yes per run, it spends tokens
## Cost
M tier, ~30-50 AIC per review (unverified)
## Sources
- https://github.github.com/gh-aw/gallery/automated-pr-review/
- https://github.com/svennijhuis/agentic-workflows/pull/2
- docs/pbi/done/C12-agentpacks-import-contract.md
- docs/pbi/workflow-ratings.md
