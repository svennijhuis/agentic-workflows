# F69: Skills reviewer (Impeccable and Matt Pocock)
- Status: todo
- Area: agent-factory
- Wave: PR 0 (implementation W6)
- Block: 6
- Lane: Builder
- Depends on: C01, C02, C03, C04, C05, C06, R01, X01, L01, C11
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/skills-reviewer.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: one-way
- feedback: `make compile` (`gh aw compile --strict`)
## Goal
Ship `skills-reviewer` as an installable gh-aw workflow for svennijhuis repos that agent factory pick: lint skills against team conventions.
## Context
Wave W6 later workflow. PR 0 documents intent only.
**What it does:** Agent Factory pick: lint skills against team conventions.
**Value:** Reviews Cursor skills and instructions for quality and safety.
**How ours beats the example (Bar H):** 
**Trigger:** `workflow_dispatch` only (POL25). `pull_request` paths `**/skills/**` is a named ask, row in `policies/POL25.yml` `sven_yes` first.
**Safe outputs and limits:** PR review comments; checklist issue for egregious issues.; `submit-pull-request-review` max 1, `create-issue` max 1, `staged: true`.
**Issue/PR format:** Title prefix `[F69]`, footer from `shared/reporting.md`, dedupe key `skills-reviewer:{date}`.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal fine-grained PAT).

## Frontmatter security
- `permissions:` read only (`contents: read`, `pull-requests: read`); no write permission.
- Writes only through `safe-outputs` (`submit-pull-request-review` max 1, `create-issue` max 1), `staged: true` until Sven's yes.
- `timeout-minutes:` 15
- Trigger: `workflow_dispatch` only (POL25). `pull_request` paths filter is a named ask in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Study upstream `githubnext/agentics` workflow `skills-reviewer` and Agent Factory equivalents.
2. Add `workflows/skills-reviewer.md`; import `shared/defaults.md` and `shared/security.md`; set the frontmatter security above.
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile` and commit `workflows/skills-reviewer.lock.yml`.
5. Run `make verify`; no workflow run, no token spend.

## Definition of Done
- [ ] `workflows/skills-reviewer.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Lint skills against C11 authoring rules; no secret values in skill text
## Evidence
(verify log on SHA when workflow lands)
## Flow
```mermaid
sequenceDiagram
    autonumber
    participant GH as GitHub
    participant WF as skills-reviewer
    participant Agent as Copilot agent
    GH->>WF: skills PR
    activate WF
    WF->>Agent: review SKILL.md set
    Agent-->>WF: findings
    WF->>GH: review comments
    deactivate WF
```
## Named asks for Sven
- Secondary triggers listed in Context: Sven exact yes, row in `policies/POL25.yml` `sven_yes` first
- X01 live trial and first 3 audited runs (B02): Sven exact yes, spends tokens
## Cost
Tier M: estimated 25-50 AIC per run (unverified). Daily cap 200 AIC repo-wide suggested.
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/agent-factory-status/
- agentic-workflows-workflow-ratings.md (agent-factory-status PICK row)
