# F49: Performance improver
- Status: todo
- Area: agent-factory
- Wave: PR 0 (implementation W6)
- Block: 6
- Lane: Builder
- Depends on: C01, C02, C03, C04, C05, C06, O01, O02, O03, R01, X01, L01
- proof: gh aw compile --dir workflows --strict workflows/f49.md; gh aw audit <run-id> (Block exit runs)
- door: one-way
- one-way gate: Sven's exact yes required (named ask in its block). Rollback: disable workflow via workflow_dispatch off or remove schedule trigger
## Goal
Ship `perf-improver` as an installable gh-aw workflow for svennijhuis repos that profiles a target area and proposes a perf pr with benchmark notes.
## Context
Wave W6 later workflow. PR 0 documents intent only. Ratings: Opens PRs with before and after measurements for hot paths. Cost tier L (unverified). Provider: GitHub Copilot (`engine: copilot`) on personal account svennijhuis.
## Steps
1. Study upstream `githubnext/agentics` workflow `perf-improver` and Agent Factory equivalents.
2. Author `workflows/perf-improver.md` with `engine: copilot` and shared imports.
3. Compile with pinned gh-aw; run `scripts/verify.sh` on the workflow commit SHA.
4. Trial on X01: staged or report-only run for `workflow_dispatch only until L-tier cost verified.`.
5. Record AIC for first 3 runs in Evidence; enable write outputs only after Sven yes.
## Definition of Done
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] `workflows/perf-improver.md` imports `shared/defaults.md` and uses `engine: copilot` with pinned gh-aw version and import SHA or tag (POL01)
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
    participant WF as perf-improver
    participant Agent as Copilot agent
    WF->>WF: dispatch
    activate WF
    WF->>Agent: benchmark + patch
    Agent-->>WF: PR payload
    WF->>WF: staged PR
    deactivate WF
```
## Named asks for Sven
Q4
## Cost
Tier L: estimated 65-140 AIC per run (unverified). Daily cap 200 AIC repo-wide suggested.
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/blog/2026-01-13-meet-the-workflows-continuous-improvement/

## Workflow detail (Bar H)
**What it does:** Profiles a target area and proposes a perf PR with benchmark notes.

**Value:** Opens PRs with before and after measurements for hot paths.

**Better than example:** Measurement required in PR template; caps stop runaway loops.

**Trigger:** workflow_dispatch only until L-tier cost verified.

**Safe outputs:** Draft PR; report-only diff first.

**Issue or PR format:** Title prefix `[F49]`, footer from `shared/reporting.md`, dedupe key `perf-improver:{date}`.
