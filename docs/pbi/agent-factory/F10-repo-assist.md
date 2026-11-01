# F10: Repository maintainer assist
- Status: todo
- Area: agent-factory
- Wave: W6
- Block: 6
- Lane: Builder
- Depends on: C03, C04, C06, X01, F06, F07, F00
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/repo-assist.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- feedback: `make compile` (`gh aw compile --strict`)
- door: one-way
- one-way gate: Sven's exact yes required (named ask in its block). Rollback: disable workflow via workflow_dispatch off or remove schedule trigger
## Goal
Friendly maintainer: triage plus small fix PRs (high overlap, budget gated).
## Context
Upstream reference: `maintaining-repos` (https://github.github.com/gh-aw/gallery/maintaining-repos/).
**What it does:** Friendly maintainer: triage plus small fix PRs (high overlap, budget gated).
**Value for Sven repos:** See workflow-ratings.md row; prioritize NOW set for daily maintenance and security.
**How ours beats the example (Bar H):** Twice-daily example capped to weekly dispatch for Sven
**Trigger:** `workflow_dispatch` only until budget proof
**Safe outputs and limits:** `create-pull-request` max 1, issues
**Issue/PR format:** Title prefix `[F10]`, body uses `shared/reporting.md` audit footer with workflow id, run URL, and AIC when known.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal PAT). No `copilot-requests: write` (org billing only).

## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`, `pull-requests: read`); no write permission.
- Writes only through `safe-outputs`: mixed issue/PR outputs capped (`max: 3` total writes), `staged: true` until Sven's yes.
- `timeout-minutes:` 15.
- Trigger: `workflow_dispatch` only (POL25). Any other trigger is a named ask for Sven, recorded in `policies/POL25.yml` `sven_yes` first.

## Steps
1. Add `workflows/repo-assist.md`; import `shared/defaults.md` and `shared/security.md`.
2. Set frontmatter security (read-only `permissions`, `safe-outputs` with `staged: true` and a `max` per output, `timeout-minutes`, `workflow_dispatch` only).
3. Add deterministic pre-check step; writes `noop` when there is nothing to do.
4. Run `make compile` and commit the `.lock.yml`.
5. Run `make verify`.

## Definition of Done
- [ ] `workflows/repo-assist.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] `workflows/repo-assist.md` imports `shared/defaults.md` (engine copilot, caps, admission)
- [ ] Deterministic `steps:` pre-check; writes `noop` when nothing to do (0 AIC)
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant Sven
  participant WF as repo-assist
  participant Agent as Copilot
  participant GH as GitHub
  Sven->>WF: workflow_dispatch
  activate WF
  WF->>Agent: Triage + small fix
  Agent-->>WF: Plan
  WF->>GH: issue and/or PR (capped)
  deactivate WF
```
## Named asks for Sven
none
## Cost
L tier, ~80-120 AIC per run (unverified)
## Sources
- https://github.github.com/gh-aw/gallery/maintaining-repos/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/workflows/
- docs/pbi/workflow-ratings.md
