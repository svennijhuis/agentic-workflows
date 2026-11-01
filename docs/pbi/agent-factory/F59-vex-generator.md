# F59: VEX generator (Dependabot dismissals)
- Status: todo
- Area: agent-factory
- Wave: PR 0 (implementation W6)
- Block: 6
- Lane: Builder
- Depends on: C01, C02, C03, C04, C05, C06, R01, X01, L01
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/vex-generator.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: one-way
- feedback: `make compile` (`gh aw compile --strict`)
## Goal
Ship `vex-generator` as an installable gh-aw workflow for svennijhuis repos that generates vex json and attaches to security discussion or pr.
## Context
Wave W6 later workflow. PR 0 documents intent only.
**What it does:** Generates VEX JSON and attaches to security discussion or PR.
**Value:** OpenVEX statements when Dependabot alerts are dismissed with reason.
**How ours beats the example (Bar H):** No secret paths; validate VEX schema before PR.
**Trigger:** `workflow_dispatch` only (POL25). Dependabot alert webhook is a named ask, row in `policies/POL25.yml` `sven_yes` first.
**Safe outputs and limits:** PR adding VEX file under allowed path.; `create-pull-request` max 1, `staged: true`.
**Issue/PR format:** Title prefix `[F59]`, footer from `shared/reporting.md`, dedupe key `vex-generator:{date}`.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal fine-grained PAT).

## Frontmatter security
- `permissions:` read only (`contents: read`, `pull-requests: read`, `security-events: read`); no write permission.
- Writes only through `safe-outputs` (`create-pull-request` max 1), `staged: true` until Sven's yes.
- `timeout-minutes:` 15
- Trigger: `workflow_dispatch` only (POL25). Dependabot alert webhook is a named ask in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Study upstream `githubnext/agentics` workflow `vex-generator` and Agent Factory equivalents.
2. Add `workflows/vex-generator.md`; import `shared/defaults.md` and `shared/security.md`; set the frontmatter security above.
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile` and commit `workflows/vex-generator.lock.yml`.
5. Run `make verify`; no workflow run, no token spend.

## Definition of Done
- [ ] `workflows/vex-generator.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Validate VEX schema before PR; no secret paths in output
## Evidence
(verify log on SHA when workflow lands)
## Flow
```mermaid
sequenceDiagram
    autonumber
    participant GH as GitHub
    participant WF as vex-generator
    participant Agent as Copilot agent
    GH->>WF: alert dismissed event
    activate WF
    WF->>Agent: draft VEX
    Agent-->>WF: vex json
    WF->>GH: PR with file
    deactivate WF
```
## Named asks for Sven
- Secondary triggers listed in Context: Sven exact yes, row in `policies/POL25.yml` `sven_yes` first
- X01 live trial and first 3 audited runs (B02): Sven exact yes, spends tokens
## Cost
Tier S: estimated 10-22 AIC per run (unverified). Daily cap 200 AIC repo-wide suggested.
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/blog/2026-01-13-meet-the-workflows-security-compliance/
