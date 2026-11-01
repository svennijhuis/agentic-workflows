# F06: Daily issue triage batch
- Status: todo
- Area: agent-factory
- Wave: W3
- Block: 3
- Lane: Builder
- Depends on: C03, C04, C06, R02
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/daily-issue-triage.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: two-way
- triage: build (Block 3 workflow)
- feedback: `make compile` (`gh aw compile --strict`)
- harness: gh-aw, engine copilot via shared/defaults.md (when built)
- review-input: diff + this PBI + DoD (+ linked spec) + PR description, never builder session logs (PA6)
- kind: skill
- Source: PA8 (pre-link PBI from PR #4, origin in its Sources) https://github.com/svennijhuis/agentic-workflows/pull/4 https://github.github.com/gh-aw/gallery/ai-issue-triage/
- Module boundary: `workflows/daily-issue-triage.md`, its lock and `workflows/shared/` are the copy unit; no agentPacks import in this PBI
## Goal
Once per day, triage open issues: labels, duplicates, needs-info (batch not per-open).
## Context
Upstream reference: `ai-issue-triage` (https://github.github.com/gh-aw/gallery/ai-issue-triage/).
**What it does:** Once per day, triage open issues: labels, duplicates, needs-info (batch not per-open).
**Value for Sven repos:** See workflow-ratings.md row; prioritize NOW set for daily maintenance and security.
**How ours beats the example (Bar H):** Skips if zero open issues (noop); noop when zero open issues
**Trigger:** `workflow_dispatch` only (POL25). A daily schedule is a named ask for a later Sven yes, recorded in `policies/POL25.yml` `sven_yes` before it exists.
**Safe outputs and limits:** `add-labels`, `create-issue-comment` staged first
**Issue/PR format:** Title prefix `[F06]`, body uses `shared/reporting.md` audit footer with workflow id, run URL, and AIC when known.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal PAT). No `copilot-requests: write` (org billing only).

## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`); no write permission.
- Writes only through `safe-outputs`: `add-labels` (`max: 20`), `create-issue-comment` (`max: 10`), `staged: true` until Sven's yes.
- `timeout-minutes:` 15.
- Trigger: `workflow_dispatch` only (POL25). A daily schedule is a named ask for Sven, recorded in `policies/POL25.yml` `sven_yes` first.

## Steps
1. Add `workflows/daily-issue-triage.md`; import `shared/defaults.md` and `shared/security.md`.
2. Set frontmatter security (read-only `permissions`, `safe-outputs` with `staged: true` and a `max` per output, `timeout-minutes`, `workflow_dispatch` only).
3. Add deterministic pre-check step; writes `noop` when there is nothing to do.
4. Run `make compile` and commit the `.lock.yml`.
5. Run `make verify`.
6. Write the "copy this" note at `docs/reference/daily-issue-triage.md`: the md, its lock, and `workflows/shared/` files an org copies, standalone, no secrets.

## Definition of Done
- [ ] `workflows/daily-issue-triage.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] `workflows/daily-issue-triage.md` imports `shared/defaults.md` (engine copilot, caps, admission)
- [ ] Deterministic `steps:` pre-check; writes `noop` when nothing to do (0 AIC)
- [ ] `workflow_dispatch` only, plus the "copy this" note at `docs/reference/daily-issue-triage.md` (step 7): the md, lock and `shared/` files an org copies, standalone, no secrets
- [ ] [X07](../testing/X07-workflow-benchmark.md) benchmark cases: 5 or more fixed cases with known answers written in `docs/benchmarks/<workflow>.md`, docs only, no run; the X07 score is a named ask
## Evidence
(commands, verify log on SHA)
## Flow
```mermaid
sequenceDiagram
  participant Cron as Daily dispatch
  participant WF as daily-issue-triage
  participant Agent as Copilot
  participant Issues as GitHub Issues
  Cron->>WF: workflow_dispatch
  activate WF
  WF->>Issues: List open (read)
  alt none
    WF->>WF: noop
  else
    WF->>Agent: Batch triage
    Agent-->>WF: Labels/comments plan
    WF->>Issues: staged labels/comments
  end
  deactivate WF
```
## Named asks for Sven
- X01 live trial plus `gh aw audit` on the first 3 runs with measured AIC in Evidence (B02, Bar H live part): Sven exact yes, it spends tokens
- A daily schedule: Sven exact yes per trigger, row in `policies/POL25.yml` `sven_yes` first
- X07 benchmark score at or above baseline (Bar H): each score is a live [X07](../testing/X07-workflow-benchmark.md) run on the X01 repo (`door: one-way`), Sven exact yes per run, it spends tokens
## Cost
M tier, ~25-40 AIC per batch (unverified)
## Sources
- https://github.github.com/gh-aw/gallery/ai-issue-triage/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/workflows/
- docs/pbi/workflow-ratings.md
