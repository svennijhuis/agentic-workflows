# P01: CentralRepoOps hub and aggregated tracking
- Status: todo
- Area: multi-repo
- Wave: W5
- Block: 5
- Lane: Builder
- Depends on: C02, C04, O05, G01, X01
- proof: gh aw compile --dir workflows --strict && ./scripts/verify.sh
- door: one-way
- one-way gate: Sven's exact yes required (named ask in its block). Rollback: disconnect consumer aw.yml hub wiring
## Goal
Run a central catalog repo pattern that hosts installable workflows and optionally aggregates cross-repo issue signals into one hub view, without org-only billing.
## Context

**How ours beats the example (Bar H):** shared defaults and pinned imports, low AIC caps, `workflow_dispatch` and staged/report-only before writes, dedupe and min-integrity, trial repo plus first-3-run audit, versus upstream gallery samples that often use higher defaults.
gh-aw CentralRepoOps and gallery issue-tracking show a hub repo coordinating many targets. Personal account uses `svennijhuis` as owner variable; org secrets and teams stay documented in G05 only. Issue destination is open (Q6).
**Trigger:** `workflow_dispatch` first; schedule only after explicit yes

**Safe outputs:** create-issue or add-comment on hub or target per Q6; max 1 issue per run; report-only phase

## Steps
1. Document allowed `target-repo` and `allowed-repos` for hub workflows in `shared/security.md`.
2. Add `workflows/central-hub-status.md` (report-only first) that lists configured repos and open aggregated labels.
3. Wire `GH_AW_GITHUB_TOKEN` or future GitHub App (Q3) for cross-repo read.
4. Choose per-repo issues vs central tracker after Q6; implement read path first.
5. Pin installs: consumers use `gh aw add svennijhuis/agentic-workflows/<wf>@vX.Y.Z`.
## Definition of Done

- [ ] Hub workflow runs central-run or dispatches to targets per Q1 decision
- [ ] Aggregated tracking doc matches chosen issue model (Q6)
- [ ] `imports:` shared/defaults.md (engine copilot, caps, admission, concurrency)
- [ ] Pinned gh-aw compiler version and every remote import uses tag or SHA (no @main)
- [ ] `max-ai-credits: 50`, `max-daily-ai-credits: 200`, `max-turns: 15`, `timeout-minutes: 10` (tune after measure)
- [ ] Deterministic `steps:` pre-check; `noop` when nothing to do (0 AIC path)
- [ ] `workflow_dispatch` plus staged/report-only rollout before production writes
- [ ] Dedupe: `deduplicate-by-title`, `group-by-day`, `close-older-issues`, `expires`
- [ ] `min-integrity: approved`, threat detection on, minimal `network` allowlist
- [ ] Tool, bash, and MCP allowlists; `on.roles` and skip-bots configured
- [ ] Issue/PR format matches `shared/reporting.md`
- [ ] Trial run on X01 test repo; `gh aw audit` on first 3 runs; measured AIC recorded in Evidence
- [ ] `scripts/verify.sh` pass on workflow SHA while Actions billing blocked (Q0)
## Evidence
(commands, `scripts/verify.sh` log on SHA, `gh aw` run links, audit output)
## Flow
```mermaid
sequenceDiagram
  autonumber
  actor Sven
  participant H as hub (central repo)
  participant T1 as target repo A
  participant T2 as target repo B
  participant I as issues
  Sven->>H: workflow_dispatch report-only
  H->>T1: read issues/labels (token)
  H->>T2: read issues/labels (token)
  H->>I: draft summary issue or comment (staged)
  Note over H,I: dedupe by title; no writes until prod gate
```
## Named asks for Sven
Q1 (central-run vs installed), Q3 (PAT vs App), Q6 (issue target)
## Cost
Tier M, ~30 AIC per hub summary run (unverified)
## Sources
- https://github.github.com/gh-aw/patterns/central-repo-ops/
- https://github.github.com/gh-aw/gallery/multi-repo/issue-tracking/
- https://github.github.com/gh-aw/patterns/multi-repo-ops/
