# F55: Sub-issue closer
- Status: todo
- Area: agent-factory
- Wave: PR 0 (implementation W6)
- Block: 6
- Lane: Builder
- Depends on: C01, C02, C03, C04, C05, C06, R01, X01, L01, F43
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/sub-issue-closer.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: one-way
- feedback: `make compile` (`gh aw compile --strict`)
## Goal
Ship `sub-issue-closer` as an installable gh-aw workflow for svennijhuis repos that when sub-issues close, evaluates parent and closes with summary if complete.
## Context
Wave W6 later workflow. PR 0 documents intent only.
**What it does:** When sub-issues close, evaluates parent and closes with summary if complete.
**Value:** Closes parent PBIs when all children are done.
**How ours beats the example (Bar H):** Explicit parent-child verification; audit comment.
**Trigger:** `workflow_dispatch` only (POL25). `issues` closed event is a named ask, row in `policies/POL25.yml` `sven_yes` first.
**Safe outputs and limits:** Parent close or comment; never force close without all children done.; `create-issue-comment` max 2, parent close via safe-output max 1, `staged: true`.
**Issue/PR format:** Title prefix `[F55]`, footer from `shared/reporting.md`, dedupe key `sub-issue-closer:{date}`.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal fine-grained PAT).

## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`); no write permission.
- Writes only through `safe-outputs` (`create-issue-comment` max 2, parent close via safe-output max 1), `staged: true` until Sven's yes.
- `timeout-minutes:` 10
- Trigger: `workflow_dispatch` only (POL25). `issues` closed event is a named ask in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Study upstream `githubnext/agentics` workflow `sub-issue-closer` and Agent Factory equivalents.
2. Add `workflows/sub-issue-closer.md`; import `shared/defaults.md` and `shared/security.md`; set the frontmatter security above.
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile` and commit `workflows/sub-issue-closer.lock.yml`.
5. Run `make verify`; no workflow run, no token spend.

## Definition of Done
- [ ] `workflows/sub-issue-closer.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Never force-close parent until all children closed; audit comment on close
## Evidence
(verify log on SHA when workflow lands)
## Flow
```mermaid
sequenceDiagram
    autonumber
    participant GH as GitHub
    participant WF as sub-issue-closer
    WF->>GH: child issue closed
    activate WF
    WF->>GH: list siblings
    WF->>GH: close parent or wait
    deactivate WF
```
## Named asks for Sven
- Q6 (parent-child issue policy)
- `issues` closed event: Sven exact yes, row in `policies/POL25.yml` `sven_yes` first
- X01 live trial and first 3 audited runs (B02): Sven exact yes, spends tokens
## Cost
Tier S: estimated 8-18 AIC per run (unverified). Daily cap 200 AIC repo-wide suggested.
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/blog/2026-01-13-meet-the-workflows-issue-management/
