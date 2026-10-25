# P05: User Project board and monitoring
- Status: todo
- Area: multi-repo
- Wave: W5
- Block: 5
- Lane: Builder
- Depends on: C04, M01, B07
- proof: gh aw compile --dir workflows --strict && ./scripts/verify.sh
- door: one-way
- one-way gate: Sven's exact yes required (named ask in its block). Rollback: disable workflow via workflow_dispatch off or remove schedule trigger
## Goal
Sync workflow health and exceptions into a user-owned GitHub Project v2 board for portfolio visibility.
## Context

**How ours beats the example (Bar H):** shared defaults and pinned imports, low AIC caps, `workflow_dispatch` and staged/report-only before writes, dedupe and min-integrity, trial repo plus first-3-run audit, versus upstream gallery samples that often use higher defaults.
Experimental monitoring-with-projects pattern. Requires Projects-capable token (fine-grained PAT field, not in repo files).
**Trigger:** `workflow_dispatch`

**Safe outputs:** project item updates via safe outputs or deterministic API steps

## Steps
1. Document project field mapping (Status, Repo, Last run).
2. Dispatch workflow reads `gh aw logs` / issues and updates Project items (report-only first).
3. Link to M01 exception issues when present.
## Definition of Done

- [ ] Project ID supplied via `gh aw env` masked var, not committed
- [ ] Updates are idempotent per run id
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
  participant D as dispatch
  participant W as project-sync wf
  participant API as GitHub Projects API
  participant P as Project board
  D->>W: workflow_dispatch
  W->>API: list open monitoring issues
  W->>P: add/update items (staged)
  Note over W,P: read-heavy; agent optional for summaries
```
## Named asks for Sven
Q3 (Projects scope on PAT)
## Cost
Tier M, ~35 AIC if agent summarizes (unverified)
## Sources
- https://github.github.com/gh-aw/experimental/monitoring-with-projects/
- https://github.github.com/gh-aw/patterns/project-ops/
