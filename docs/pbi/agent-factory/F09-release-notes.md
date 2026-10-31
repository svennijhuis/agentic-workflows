# F09: AI release notes
- Status: todo
- Area: agent-factory
- Wave: W6
- Block: 6
- Lane: Builder
- Depends on: C03, C04, C06, O01, O02, O03, L01
- proof: gh aw compile --dir workflows --strict workflows/f09.md; gh aw audit <run-id> (Block exit runs)
- door: one-way
- one-way gate: Sven's exact yes required (named ask in its block). Rollback: disable workflow via workflow_dispatch off or remove schedule trigger
- triage: build (Block 3 workflow)
- feedback: gh aw compile --dir workflows --strict, offline `scripts/verify.sh`
- harness: gh-aw, engine copilot via shared/defaults.md (when built)
- review-input: diff + this PBI + DoD (+ linked spec) + PR description, never builder session logs (PA6)
- kind: skill
- Source: PA8 (pre-link PBI from PR #4, origin in its Sources) https://github.com/svennijhuis/agentic-workflows/pull/4 https://github.github.com/gh-aw/gallery/ai-release-notes/
- Module boundary: `workflows/release-notes.md` + its lock + `workflows/shared/` is the copy unit; agentPacks imports stay behind the POL01 pin
## Goal
On release, draft release notes issue or PR body for human edit.
## Context
Upstream reference: `ai-release-notes` (https://github.github.com/gh-aw/gallery/ai-release-notes/).
**What it does:** On release, draft release notes issue or PR body for human edit.
**Value for Sven repos:** See workflow-ratings.md row; prioritize NOW set for daily maintenance and security.
**How ours beats the example (Bar H):** Human merges notes; dedupe per tag
**Trigger:** `workflow_dispatch`; `release` after staged
**Safe outputs and limits:** `create-issue` or PR comment report-only first
**Issue/PR format:** Title prefix `[F09]`, body uses `shared/reporting.md` audit footer with workflow id, run URL, and AIC when known.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal PAT). No `copilot-requests: write` (org billing only).

## Steps
1. Add `workflows/release-notes.md` from upstream pattern; import `shared/defaults.md` and `shared/security.md`.
2. Set staged/report-only outputs; wire `workflow_dispatch` as the only live trigger initially.
3. Add deterministic pre-check step returning `noop` when there is nothing to do.
4. Run `scripts/verify.sh` on PR SHA; compile with pinned gh-aw version.
5. Offline proof only: `scripts/verify.sh` (compile --strict --actionlint, lock drift, `--no-emit` fixture). X01 live trial and AIC audit are a named ask (Sven exact yes), not in this DoD.
6. After Sven explicit yes, enable secondary triggers (schedule, `workflow_run`, slash) one at a time.

## Definition of Done
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] `workflows/release-notes.md` imports `shared/defaults.md` (engine copilot, caps, admission)
- [ ] Pinned `gh aw` compiler version and all imports use tag or SHA (no `@main`, no `@marketplace`)
- [ ] `max-ai-credits: 50`, `max-daily-ai-credits: 200`, `max-turns` and `timeout-minutes` set per C03
- [ ] Deterministic `steps:` pre-check; writes `noop` when nothing to do (0 AIC)
- [ ] First rollout is `workflow_dispatch` plus staged/report-only; no schedule or spend until Sven approves
- [ ] Dedupe via title, `group-by-day`, `close-older-issues`, and expiry per O03
- [ ] `min-integrity: approved` and threat detection enabled (POL05, POL13)
- [ ] Network allowlist and tool/MCP/bash allowlists (POL06, POL07); no wildcard network
- [ ] `on.roles` and skip-bots configured (POL10)
- [ ] Issue/PR bodies follow `shared/reporting.md` footer format (POL16)
- [ ] Offline proof: `scripts/verify.sh` log on exact SHA, 0 failures (no X01 trial, no token spend)
- [ ] `workflow_dispatch` only, plus a "copy this" note: the md, lock and `shared/` files an org copies, standalone, no secrets
- [ ] `gh aw audit` on first 3 runs; measured AIC recorded in this PBI Evidence section (B02)
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant Rel as Release event
  participant WF as release-notes
  participant Agent as Copilot
  participant GH as GitHub
  Rel->>WF: dispatch / release
  activate WF
  WF->>Agent: Summarize commits
  Agent-->>WF: Notes draft
  WF->>GH: issue or comment (report-only)
  deactivate WF
```
## Named asks for Sven
none
## Cost
M tier, ~25-45 AIC per release (unverified)
## Sources
- https://github.github.com/gh-aw/gallery/ai-release-notes/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/workflows/
- docs/pbi/workflow-ratings.md
