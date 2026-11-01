# F65: Test quality sentinel
- Status: todo
- Area: agent-factory
- Wave: PR 0 (implementation W6)
- Block: 6
- Lane: Builder
- Depends on: C01, C02, C03, C04, C05, C06, R01, X01, L01, F18
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/test-quality-sentinel.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: one-way
- feedback: `make compile` (`gh aw compile --strict`)
## Goal
Ship `test-quality-sentinel` as an installable gh-aw workflow for svennijhuis repos that agent factory pick: scores test changes and suggests improvements.
## Context
Wave W6 later workflow. PR 0 documents intent only.
**What it does:** Agent Factory pick: scores test changes and suggests improvements.
**Value:** Flags weak tests and missing cases on PRs.
**How ours beats the example (Bar H):** Pairs with F18 test-improver without auto committing tests.
**Trigger:** `workflow_dispatch` only (POL25). `pull_request` paths `**/test/**` is a named ask, row in `policies/POL25.yml` `sven_yes` first.
**Safe outputs and limits:** Review comment; optional issue for major gaps.; `submit-pull-request-review` max 1, `create-issue` max 1, `staged: true`.
**Issue/PR format:** Title prefix `[F65]`, footer from `shared/reporting.md`, dedupe key `test-quality-sentinel:{date}`.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal fine-grained PAT).

## Frontmatter security
- `permissions:` read only (`contents: read`, `pull-requests: read`, `issues: read`); no write permission.
- Writes only through `safe-outputs` (`submit-pull-request-review` max 1, `create-issue` max 1), `staged: true` until Sven's yes.
- `timeout-minutes:` 15
- Trigger: `workflow_dispatch` only (POL25). `pull_request` paths filter is a named ask in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Study upstream `githubnext/agentics` workflow `test-quality-sentinel` and Agent Factory equivalents.
2. Add `workflows/test-quality-sentinel.md`; import `shared/defaults.md` and `shared/security.md`; set the frontmatter security above.
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile` and commit `workflows/test-quality-sentinel.lock.yml`.
5. Run `make verify`; no workflow run, no token spend.

## Definition of Done
- [ ] `workflows/test-quality-sentinel.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Pairs with F18 test-improver without auto-committing tests
## Evidence
(verify log on SHA when workflow lands)
## Flow
```mermaid
sequenceDiagram
    autonumber
    participant GH as GitHub
    participant WF as test-quality-sentinel
    participant Agent as Copilot agent
    GH->>WF: PR with tests
    activate WF
    WF->>Agent: analyze test delta
    Agent-->>WF: quality report
    WF->>GH: review comment
    deactivate WF
```
## Named asks for Sven
- Secondary triggers listed in Context: Sven exact yes, row in `policies/POL25.yml` `sven_yes` first
- X01 live trial and first 3 audited runs (B02): Sven exact yes, spends tokens
## Cost
Tier M: estimated 30-50 AIC per run (unverified). Daily cap 200 AIC repo-wide suggested.
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/blog/2026-01-13-meet-the-workflows-testing-validation/
- agentic-workflows-workflow-ratings.md (agent-factory-status PICK row)
