# F47: Lean squad (plan, build, review)
- Status: todo
- Area: agent-factory
- Wave: PR 0 (implementation W6)
- Block: 6
- Lane: Builder
- Depends on: C01, C02, C03, C04, C05, C06, O01, O02, O03, R01, X01, L01
- proof: gh aw compile --dir workflows --strict workflows/f47.md; gh aw audit <run-id> (Block exit runs)
- door: one-way
- one-way gate: Sven's exact yes required (named ask in its block). Rollback: disable workflow via workflow_dispatch off or remove schedule trigger
## Goal
Ship `lean-squad` as an installable gh-aw workflow for svennijhuis repos that runs plan, implement, and review sub-agents sequentially on one issue scope.
## Context
Wave W6 later workflow. PR 0 documents intent only. Ratings: High: multi-role squad similar to Builder room; use sparingly. Cost tier XL (unverified). Provider: GitHub Copilot (`engine: copilot`) on personal account svennijhuis.
## Steps
1. Study upstream `githubnext/agentics` workflow `lean-squad` and Agent Factory equivalents.
2. Author `workflows/lean-squad.md` with `engine: copilot` and shared imports.
3. Compile with pinned gh-aw; run `scripts/verify.sh` on the workflow commit SHA.
4. Trial on X01: staged or report-only run for `workflow_dispatch with issue number input only`.
5. Record AIC for first 3 runs in Evidence; enable write outputs only after Sven yes.
6. Do not enable schedule or cron until explicit Sven approval and measured cost.
## Definition of Done
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] `workflows/lean-squad.md` imports `shared/defaults.md` and uses `engine: copilot` with pinned gh-aw version and import SHA or tag (POL01)
- [ ] Cost caps: max-ai-credits 50, max-daily-ai-credits 200, max-turns and timeout-minutes set (POL02, POL15)
- [ ] Pre-check step then noop path; staged or report-only mode before any write outputs (POL03, O02)
- [ ] Dedupe on output title, group-by-day, close-older, expires configured (O03)
- [ ] `min-integrity: approved` on agent run (POL05)
- [ ] Minimal network allowlist, no wildcards (POL06)
- [ ] Tool, MCP, and bash allowlists documented (POL07)
- [ ] Every output uses safe-output max limits (POL08)
- [ ] Rate limits, concurrency, cooldown from shared defaults (POL09)
- [ ] `on.roles` and skip-bots for triggers (POL10)
- [ ] Least permissions, read-only agent where possible (POL11)
- [ ] Explicit allowed-repos or target-repo in workflow (POL12)
- [ ] Threat detection enabled, never off (POL13)
- [ ] No merge-pull-request or unsafe pull_request_target (POL14)
- [ ] Issue and PR bodies follow `shared/reporting.md` format (POL16)
- [ ] Trial run on X01 test repo with staged or report-only first
- [ ] First 3 production runs audited; measured AIC per run recorded in this PBI (B02)
- [ ] `scripts/verify.sh` passes on workflow SHA (Q0 local verify until Actions billing fixed)
## Evidence
- `scripts/verify.sh` log on workflow SHA (Q0)
- X01 trial run URL and mode (staged or report-only)
- First 3 run links with measured AIC recorded below
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
Q4 (XL budget approval per run)
## Cost
Tier XL: estimated 150-250 AIC per run (unverified). Daily cap 200 AIC repo-wide suggested.
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/blog/2026-01-13-meet-the-workflows-multi-phase/

## Workflow detail (Bar H)
**What it does:** Runs plan, implement, and review sub-agents sequentially on one issue scope.

**Value:** High: multi-role squad similar to Builder room; use sparingly.

**Better than example:** Per-phase caps, abort on budget, copilot-only engine, no marketplace imports.

**Trigger:** workflow_dispatch with issue number input only; no schedule.

**Safe outputs:** Plan comment, draft PR, review comment; sub-agent caps enforced.

**Issue or PR format:** Title prefix `[F47]`, footer from `shared/reporting.md`, dedupe key `lean-squad:{date}`.
