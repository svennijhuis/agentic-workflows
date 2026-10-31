# F02: CI failure investigator
- Status: todo
- Area: agent-factory
- Wave: W3
- Block: 3
- Lane: Builder
- Depends on: C03, C04, C06, O01, O02, O03, R04
- proof: `bash scripts/verify.sh` exits 0 with `0 failures` (offline: `gh aw compile --dir workflows --strict workflows/ci-doctor.md`, lock drift, `--no-emit` fixture); no run, no token spend
- door: two-way
- triage: build (Block 3 workflow)
- feedback: gh aw compile --dir workflows --strict, offline `scripts/verify.sh`
- harness: gh-aw, engine copilot via shared/defaults.md (when built)
- review-input: diff + this PBI + DoD (+ linked spec) + PR description, never builder session logs (PA6)
- kind: skill
- Source: PA8 (pre-link PBI from PR #4, origin in its Sources) https://github.com/svennijhuis/agentic-workflows/pull/4 https://github.github.com/gh-aw/gallery/ci-failure-investigation/
- Module boundary: `workflows/ci-doctor.md`, its lock and `workflows/shared/` are the copy unit; no agentPacks import in this PBI
## Goal
On failed CI, investigate logs and file a deduped issue with root cause and next steps.
## Context
Upstream reference: `ci-failure-investigation` (https://github.github.com/gh-aw/gallery/ci-failure-investigation/).
**What it does:** On failed CI, investigate logs and file a deduped issue with root cause and next steps.
**Value for Sven repos:** See workflow-ratings.md row; prioritize NOW set for daily maintenance and security.
**How ours beats the example (Bar H):** Pre-step skips if fingerprint issue open; central vs per-repo dispatch documented
**Trigger:** `workflow_dispatch` only (POL25). A `workflow_run` trigger (on failed CI) is a named ask for a later Sven yes, recorded in `policies/POL25.yml` `sven_yes` before it exists.
**Safe outputs and limits:** `create-issue`, `create-issue-comment` with dedupe title
**Issue/PR format:** Title prefix `[F02]`, body uses `shared/reporting.md` audit footer with workflow id, run URL, and AIC when known.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal PAT). No `copilot-requests: write` (org billing only).

## Steps
1. Add `workflows/ci-doctor.md` from upstream pattern; import `shared/defaults.md` and `shared/security.md`.
2. Set staged/report-only outputs; wire `workflow_dispatch` as the only live trigger.
3. Add deterministic pre-check step returning `noop` when there is nothing to do.
4. Run `scripts/verify.sh` on PR SHA; compile with pinned gh-aw version.
5. Offline proof only: `scripts/verify.sh` (compile --strict --actionlint, lock drift, `--no-emit` fixture). X01 live trial and AIC audit are a named ask (Sven exact yes), not in this DoD.
6. No other trigger in this PBI. A `workflow_run` trigger (on failed CI) is a named ask (Sven exact yes, row in `policies/POL25.yml` `sven_yes` first), built in a later PBI.
7. Write the "copy this" note at `docs/reference/ci-doctor.md`: the md, its lock and the `workflows/shared/` files an org copies, standalone, no secrets.

## Definition of Done
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] `workflows/ci-doctor.md` imports `shared/defaults.md` (engine copilot, caps, admission)
- [ ] Pinned `gh aw` compiler version and all imports use tag or SHA (no `@main`, no `@marketplace`)
- [ ] `max-ai-credits: 50`, `max-daily-ai-credits: 200`, `max-turns` and `timeout-minutes` set per C03
- [ ] Deterministic `steps:` pre-check; writes `noop` when nothing to do (0 AIC)
- [ ] Staged/report-only outputs; no schedule, no other trigger and no token spend in this PBI
- [ ] Dedupe via title, `group-by-day`, `close-older-issues`, and expiry per O03
- [ ] `min-integrity: approved` and threat detection enabled (POL05, POL13)
- [ ] Network allowlist and tool/MCP/bash allowlists (POL06, POL07); no wildcard network
- [ ] `on.roles` and skip-bots configured (POL10)
- [ ] Issue/PR bodies follow `shared/reporting.md` footer format (POL16)
- [ ] Offline proof: `scripts/verify.sh` log on exact SHA, 0 failures (no X01 trial, no token spend)
- [ ] `workflow_dispatch` only, plus the "copy this" note at `docs/reference/ci-doctor.md` (step 7): the md, lock and `shared/` files an org copies, standalone, no secrets
- [ ] [X07](../testing/X07-workflow-benchmark.md) benchmark cases: 5 or more fixed cases with known answers written in `docs/benchmarks/<workflow>.md`, docs only, no run; the X07 score is a named ask
## Evidence
(commands, verify log on SHA)
## Flow
```mermaid
sequenceDiagram
  participant Sven
  participant WF as ci-doctor
  participant Agent as Copilot
  participant Issues as GitHub Issues
  Sven->>WF: workflow_dispatch (failed run id input)
  activate WF
  WF->>WF: fingerprint dedupe check
  alt duplicate open issue
    WF->>WF: noop
  else new failure
    WF->>Agent: Analyze logs
    activate Agent
    Agent-->>WF: Root cause draft
    deactivate Agent
    WF->>Issues: create-issue (footer)
  end
  deactivate WF
```
## Named asks for Sven
- Q1 (central dispatch vs install per repo for ci-doctor)
- X01 live trial plus `gh aw audit` on the first 3 runs with measured AIC in Evidence (B02, Bar H live part): Sven exact yes, it spends tokens
- A `workflow_run` trigger (on failed CI): Sven exact yes per trigger, row in `policies/POL25.yml` `sven_yes` first
- X07 benchmark score at or above baseline (Bar H): each score is a live [X07](../testing/X07-workflow-benchmark.md) run on the X01 repo (`door: one-way`), Sven exact yes per run, it spends tokens
## Cost
M tier, ~25-45 AIC per failure (unverified)
## Sources
- https://github.github.com/gh-aw/gallery/ci-failure-investigation/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/workflows/
- docs/pbi/workflow-ratings.md
