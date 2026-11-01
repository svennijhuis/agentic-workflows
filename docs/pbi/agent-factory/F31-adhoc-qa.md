# F31: Ad hoc QA
- Status: todo
- Area: agent-factory
- Wave: W6
- Block: 6
- Lane: Builder
- Depends on: C03, C04, C06, X01, F00
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/adhoc-qa.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- feedback: `make compile` (`gh aw compile --strict`)
- door: one-way
- one-way gate: Sven's exact yes required (named ask in its block). Rollback: disable workflow via workflow_dispatch off or remove schedule trigger
## Goal
QA discussion plus optional PR from prompt.
## Context
Upstream reference: `adhoc-qa` (https://github.com/githubnext/agentics/tree/main/workflows/adhoc-qa.md).
**What it does:** QA discussion plus optional PR from prompt.
**Value for Sven repos:** See workflow-ratings.md row; prioritize NOW set for daily maintenance and security.
**How ours beats the example (Bar H):** Manual trigger only
**Trigger:** `workflow_dispatch`
**Safe outputs and limits:** issue + optional PR
**Issue/PR format:** Title prefix `[F31]`, body uses `shared/reporting.md` audit footer with workflow id, run URL, and AIC when known.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal PAT). No `copilot-requests: write` (org billing only).
## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`, `pull-requests: read`); no write permission in `permissions:`.
- Writes only through `safe-outputs` (`create-issue` max 1, `create-pull-request` max 1), `staged: true` until Sven's yes.
- `timeout-minutes:` 25
- Trigger: `workflow_dispatch` only (POL25). Schedule, `issues`, slash, or other triggers are named asks for Sven, recorded in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Add `workflows/adhoc-qa.md`; import `shared/defaults.md` and `shared/security.md`.
2. Set frontmatter security: read-only `permissions`, `safe-outputs` with a `max` per output and `staged: true`, `timeout-minutes`, `workflow_dispatch` only (POL25).
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile`; commit `workflows/adhoc-qa.lock.yml`.
5. Run `make verify`.
## Definition of Done
- [ ] `workflows/adhoc-qa.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Workflow imports `shared/defaults.md` and `shared/security.md`
- [ ] Deterministic pre-check; writes `noop` when nothing to do (0 AIC)
- [ ] First rollout is `workflow_dispatch` with `staged: true` on all write outputs until Sven approves live writes
- [ ] Dedupe via title, `group-by-day`, `close-older-issues`, and expiry
- [ ] Issue and PR bodies follow `shared/reporting.md` footer format
## Evidence
(commands, verify log on SHA)
## Flow
```mermaid
sequenceDiagram
  participant Sven
  participant WF as adhoc-qa
  participant Agent as Copilot
  participant GH as GitHub
  Sven->>WF: workflow_dispatch
  activate WF
  WF->>Agent: QA plan
  WF->>GH: issue/PR
  deactivate WF
```
## Named asks for Sven
- X01 live trial and first 3 measured AIC runs: Sven exact yes (spends tokens); not in offline proof DoD
## Cost
L tier, ~80-120 AIC per QA pass (unverified)
## Sources
- https://github.com/githubnext/agentics/tree/main/workflows/adhoc-qa.md
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/workflows/
- docs/pbi/workflow-ratings.md
