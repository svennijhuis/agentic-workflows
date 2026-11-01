# F24: Agentic workflow audit agent
- Status: todo
- Area: agent-factory
- Wave: W6
- Block: 6
- Lane: Builder
- Depends on: C03, C04, C06, X01, F17, F00
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/audit-agent.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- feedback: `make compile` (`gh aw compile --strict`)
- door: one-way
- one-way gate: Sven's exact yes required (named ask in its block). Rollback: disable workflow via workflow_dispatch off or remove schedule trigger
## Goal
Audit workflows for compile-strict cleanliness and frontmatter security (POL25, POL31).
## Context
Upstream reference: `Agentic Workflow Audit Agent` (https://github.github.com/gh-aw/agent-factory-status/).
**What it does:** Audit workflows for compile-strict cleanliness and frontmatter security (POL25, POL31).
**Value for Sven repos:** See workflow-ratings.md row; prioritize NOW set for daily maintenance and security.
**How ours beats the example (Bar H):** Outputs map to gate checks
**Trigger:** `workflow_dispatch`
**Safe outputs and limits:** `create-issue` checklist
**Issue/PR format:** Title prefix `[F24]`, body uses `shared/reporting.md` audit footer with workflow id, run URL, and AIC when known.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal PAT). No `copilot-requests: write` (org billing only).

## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`, `pull-requests: read`, `actions: read`); no write permission.
- Writes only through `safe-outputs`: `create-issue` (`max: 1`), `staged: true` until Sven's yes.
- `timeout-minutes:` 15.
- Trigger: `workflow_dispatch` only (POL25). Any other trigger is a named ask for Sven, recorded in `policies/POL25.yml` `sven_yes` first.

## Steps
1. Add `workflows/audit-agent.md`; import `shared/defaults.md` and `shared/security.md`.
2. Set frontmatter security (read-only `permissions`, `safe-outputs` with `staged: true` and a `max` per output, `timeout-minutes`, `workflow_dispatch` only).
3. Add deterministic pre-check step; writes `noop` when there is nothing to do.
4. Run `make compile` and commit the `.lock.yml`.
5. Run `make verify`.

## Definition of Done
- [ ] `workflows/audit-agent.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] `workflows/audit-agent.md` imports `shared/defaults.md` (engine copilot, caps, admission)
- [ ] Deterministic `steps:` pre-check; writes `noop` when nothing to do (0 AIC)
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant WF as audit-agent
  participant Agent as Copilot
  participant Issues as GitHub Issues
  Sven->>WF: workflow_dispatch
  activate WF
  WF->>Agent: POL compliance review
  WF->>Issues: checklist issue
  deactivate WF
```
## Named asks for Sven
none
## Cost
M tier, ~35-55 AIC per audit (unverified)
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/workflows/
- docs/pbi/workflow-ratings.md
