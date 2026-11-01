# F54: Repository quality improver
- Status: todo
- Area: agent-factory
- Wave: PR 0 (implementation W6)
- Block: 6
- Lane: Builder
- Depends on: C01, C02, C03, C04, C05, C06, R01, X01, L01
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/repository-quality-improver.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: one-way
- feedback: `make compile` (`gh aw compile --strict`)
## Goal
Ship `repository-quality-improver` as an installable gh-aw workflow for svennijhuis repos that picks one quality theme (tests, docs, deps) and files a actionable issue.
## Context
Wave W6 later workflow. PR 0 documents intent only.
**What it does:** Picks one quality theme (tests, docs, deps) and files a actionable issue.
**Value:** Daily focus area rotated into a quality improvement issue.
**How ours beats the example (Bar H):** Rotating focus config in repo; no auto PR.
**Trigger:** `workflow_dispatch` only (POL25). Daily schedule is a named ask after measured cost.
**Safe outputs and limits:** One issue per day with checklist.; `create-issue` max 1, `staged: true`.
**Issue/PR format:** Title prefix `[F54]`, footer from `shared/reporting.md`, dedupe key `repository-quality-improver:{date}`.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal fine-grained PAT).

## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`); no write permission.
- Writes only through `safe-outputs` (`create-issue` max 1), `staged: true` until Sven's yes.
- `timeout-minutes:` 15
- Trigger: `workflow_dispatch` only (POL25). Daily schedule is a named ask in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Study upstream `githubnext/agentics` workflow `repository-quality-improver` and Agent Factory equivalents.
2. Add `workflows/repository-quality-improver.md`; import `shared/defaults.md` and `shared/security.md`; set the frontmatter security above.
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile` and commit `workflows/repository-quality-improver.lock.yml`.
5. Run `make verify`; no workflow run, no token spend.

## Definition of Done
- [ ] `workflows/repository-quality-improver.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Rotating focus config in repo; no auto PR
- [ ] One issue per day with checklist; dedupe via title key
## Evidence
(verify log on SHA when workflow lands)
## Flow
```mermaid
sequenceDiagram
    autonumber
    participant WF as quality-improver
    participant Agent as Copilot agent
    WF->>WF: dispatch
    activate WF
    WF->>Agent: assess weak area
    Agent-->>WF: issue draft
    WF->>WF: create issue
    deactivate WF
```
## Named asks for Sven
- Secondary triggers listed in Context: Sven exact yes, row in `policies/POL25.yml` `sven_yes` first
- X01 live trial and first 3 audited runs (B02): Sven exact yes, spends tokens
## Cost
Tier M: estimated 30-55 AIC per run (unverified). Daily cap 200 AIC repo-wide suggested.
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/blog/2026-01-13-meet-the-workflows-quality-hygiene/
