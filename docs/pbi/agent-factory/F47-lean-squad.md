# F47: Lean squad (plan, build, review)
- Status: todo
- Area: agent-factory
- Wave: PR 0 (implementation W6)
- Block: 6
- Lane: Builder
- Depends on: C01, C02, C03, C04, C05, C06, R01, X01, L01
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/lean-squad.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- feedback: `make compile` (`gh aw compile --strict`)
- door: one-way
- one-way gate: Sven's exact yes required (named ask in its block). Rollback: disable workflow via workflow_dispatch off or remove schedule trigger
## Goal
Ship `lean-squad` as an installable gh-aw workflow for svennijhuis repos that runs plan, implement, and review sub-agents sequentially on one issue scope.
## Context
Wave W6 later workflow. PR 0 documents intent only. Ratings: High: multi-role squad similar to Builder room; use sparingly. Cost tier XL (unverified). Provider: GitHub Copilot (`engine: copilot`) on personal account svennijhuis.

**What it does:** Runs plan, implement, and review sub-agents sequentially on one issue scope.

**Value:** High: multi-role squad similar to Builder room; use sparingly.

**Better than example:** Per-phase caps, abort on budget, copilot-only engine, no marketplace imports.

**Trigger:** workflow_dispatch with issue number input only; no schedule.

**Safe outputs:** Plan comment, draft PR, review comment; sub-agent caps enforced.

**Issue or PR format:** Title prefix `[F47]`, footer from `shared/reporting.md`, dedupe key `lean-squad:{date}`.
## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`, `pull-requests: read`); no write permission in `permissions:`.
- Writes only through `safe-outputs` (`submit-pull-request-review` max 1), `staged: true` until Sven's yes.
- `timeout-minutes:` 15
- Trigger: `workflow_dispatch` only (POL25). Schedule, `issues`, slash, or other triggers are named asks for Sven, recorded in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Add `workflows/lean-squad.md`; import `shared/defaults.md` and `shared/security.md`.
2. Set frontmatter security: read-only `permissions`, `safe-outputs` with a `max` per output and `staged: true`, `timeout-minutes`, `workflow_dispatch` only (POL25).
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile`; commit `workflows/lean-squad.lock.yml`.
5. Run `make verify`.
## Definition of Done
- [ ] `workflows/lean-squad.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Workflow imports `shared/defaults.md` and `shared/security.md`
- [ ] Deterministic pre-check; writes `noop` when nothing to do (0 AIC)
- [ ] First rollout is `workflow_dispatch` with `staged: true` on all write outputs until Sven approves live writes
- [ ] Dedupe via title, `group-by-day`, `close-older-issues`, and expiry
- [ ] Issue and PR bodies follow `shared/reporting.md` footer format
- [ ] Dedupe key `lean-squad:{date}` configured on outputs
## Evidence
(commands, verify log on SHA)
## Flow
```mermaid
sequenceDiagram
    autonumber
    actor Sven as Sven
    participant WF as lean-squad
    participant Plan as plan agent
    participant Build as build agent
    participant Review as review agent
    Sven->>WF: dispatch + issue id
    activate WF
    WF->>Plan: scope plan
    Plan-->>WF: plan doc
    WF->>Build: implement slice
    Build-->>WF: draft PR
    WF->>Review: review PR
    Review-->>WF: findings
    WF-->>Sven: summary comment
    deactivate WF
```
## Named asks for Sven
- X01 live trial and first 3 measured AIC runs: Sven exact yes (spends tokens); not in offline proof DoD
Q4 (XL budget approval per run)
## Cost
Tier XL: estimated 150-250 AIC per run (unverified). Daily cap 200 AIC repo-wide suggested.
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/blog/2026-01-13-meet-the-workflows-multi-phase/
