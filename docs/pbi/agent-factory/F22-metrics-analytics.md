# F22: Workflow metrics collector
- Status: todo
- Area: agent-factory
- Wave: W6
- Block: 6
- Lane: Builder
- Depends on: C03, C04, C06, X01, B03, Y02, F00
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/metrics-analytics.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- feedback: `make compile` (`gh aw compile --strict`)
- door: one-way
- one-way gate: Sven's exact yes required (named ask in its block). Rollback: disable workflow via workflow_dispatch off or remove schedule trigger
## Goal
Repo-memory style metrics snapshots; noop if unchanged.
## Context
Upstream reference: `metrics-analytics` (https://github.github.com/gh-aw/gallery/metrics-analytics/).
**What it does:** Repo-memory style metrics snapshots; noop if unchanged.
**Value for Sven repos:** See workflow-ratings.md row; prioritize NOW set for daily maintenance and security.
**How ours beats the example (Bar H):** Feeds B03 outcomes
**Trigger:** `workflow_dispatch`
**Safe outputs and limits:** `create-issue` or memory write per Y02 design
**Issue/PR format:** Title prefix `[F22]`, body uses `shared/reporting.md` audit footer with workflow id, run URL, and AIC when known.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal PAT). No `copilot-requests: write` (org billing only).

## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`, `actions: read`); no write permission.
- Writes only through `safe-outputs`: `create-issue` (`max: 1`), `staged: true` until Sven's yes.
- `timeout-minutes:` 10.
- Trigger: `workflow_dispatch` only (POL25). A schedule is a named ask for Sven, recorded in `policies/POL25.yml` `sven_yes` first.

## Steps
1. Add `workflows/metrics-analytics.md`; import `shared/defaults.md` and `shared/security.md`.
2. Set frontmatter security (read-only `permissions`, `safe-outputs` with `staged: true` and a `max` per output, `timeout-minutes`, `workflow_dispatch` only).
3. Add deterministic pre-check step; writes `noop` when there is nothing to do.
4. Run `make compile` and commit the `.lock.yml`.
5. Run `make verify`.

## Definition of Done
- [ ] `workflows/metrics-analytics.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] `workflows/metrics-analytics.md` imports `shared/defaults.md` (engine copilot, caps, admission)
- [ ] Deterministic `steps:` pre-check; writes `noop` when nothing to do (0 AIC)
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant WF as metrics-analytics
  participant Agent as Copilot
  participant Mem as repo-memory
  Sven->>WF: workflow_dispatch
  activate WF
  WF->>Agent: Collect metrics
  alt unchanged
    WF->>WF: noop
  else
    WF->>Mem: snapshot
  end
  deactivate WF
```
## Named asks for Sven
none
## Cost
M tier, ~25-40 AIC per snapshot (unverified)
## Sources
- https://github.github.com/gh-aw/gallery/metrics-analytics/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/workflows/
- docs/pbi/workflow-ratings.md
