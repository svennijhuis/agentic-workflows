# F68: Workflow opportunity analyzer
- Status: todo
- Area: agent-factory
- Wave: PR 0 (implementation W6)
- Block: 6
- Lane: Builder
- Depends on: C01, C02, C03, C04, C05, C06, R01, X01, L01, F17
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/workflow-opportunity-analyzer.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: one-way
- feedback: `make compile` (`gh aw compile --strict`)
## Goal
Ship `workflow-opportunity-analyzer` as an installable gh-aw workflow for svennijhuis repos that agent factory pick: repository audit suggesting gh-aw workflows.
## Context
Wave W6 later workflow. PR 0 documents intent only.
**What it does:** Agent Factory pick: repository audit suggesting gh-aw workflows.
**Value:** Audits repo for new agentic workflow opportunities (meta).
**How ours beats the example (Bar H):** Cross-links F00 ratings; copilot engine; no auto install.
**Trigger:** `workflow_dispatch` only (POL25). Quarterly schedule is a named ask after Sven yes.
**Safe outputs and limits:** Issue listing candidate workflows mapped to F ids.; `create-issue` max 1, `staged: true`.
**Issue/PR format:** Title prefix `[F68]`, footer from `shared/reporting.md`, dedupe key `workflow-opportunity-analyzer:{date}`.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal fine-grained PAT).

## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`, `pull-requests: read`); no write permission.
- Writes only through `safe-outputs` (`create-issue` max 1), `staged: true` until Sven's yes.
- `timeout-minutes:` 25
- Trigger: `workflow_dispatch` only (POL25). Quarterly schedule is a named ask in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Study upstream `githubnext/agentics` workflow `workflow-opportunity-analyzer` and Agent Factory equivalents.
2. Add `workflows/workflow-opportunity-analyzer.md`; import `shared/defaults.md` and `shared/security.md`; set the frontmatter security above.
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile` and commit `workflows/workflow-opportunity-analyzer.lock.yml`.
5. Run `make verify`; no workflow run, no token spend.

## Definition of Done
- [ ] `workflows/workflow-opportunity-analyzer.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Cross-links F00 ratings; no auto install of suggested workflows
## Evidence
(verify log on SHA when workflow lands)
## Flow
```mermaid
sequenceDiagram
    autonumber
    actor Sven as Sven
    participant WF as opportunity-analyzer
    participant Agent as Copilot agent
    Sven->>WF: dispatch
    activate WF
    WF->>Agent: repo audit
    Agent-->>WF: workflow ideas
    WF->>WF: issue with F map
    deactivate WF
```
## Named asks for Sven
- Secondary triggers listed in Context: Sven exact yes, row in `policies/POL25.yml` `sven_yes` first
- X01 live trial and first 3 audited runs (B02): Sven exact yes, spends tokens
## Cost
Tier L: estimated 60-120 AIC per run (unverified). Daily cap 200 AIC repo-wide suggested.
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/agent-factory-status/
- agentic-workflows-workflow-ratings.md (agent-factory-status PICK row)
