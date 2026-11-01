# F73: Issue grouping
- Status: todo
- Area: agent-factory
- Wave: W5
- Block: 5
- Lane: Builder
- Depends on: C03, C04, R02, X01, F72
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/issue-grouping.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: one-way
- feedback: `make compile` (`gh aw compile --strict`)
## Goal
Triage workflow clusters open issues with the same symptom into one tracking issue (gist candidate 2, point 16).
## Context
Block 5 scale item. Report-only grouping comments and optional tracking issue creation with staged mode first.
**What it does:** Triage workflow clusters open issues with the same symptom into one tracking issue (gist candidate 2, point 16)
**Value:** 
**How ours beats the example (Bar H):** Bar H defaults, staged outputs, dispatch-only rollout
**Trigger:** `workflow_dispatch` only (POL25). Weekly schedule is a named ask (R01), row in `policies/POL25.yml` `sven_yes` first.
**Safe outputs and limits:** `create-issue` max 1, `create-issue-comment` max 3; `create-issue` max 1, `create-issue-comment` max 3, `staged: true`.
**Issue/PR format:** Title prefix `[F73]`, footer from `shared/reporting.md`
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal fine-grained PAT).

## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`); no write permission.
- Writes only through `safe-outputs` (`create-issue` max 1, `create-issue-comment` max 3), `staged: true` until Sven's yes.
- `timeout-minutes:` 20
- Trigger: `workflow_dispatch` only (POL25). Weekly schedule is a named ask in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Study upstream `githubnext/agentics` workflow `issue-grouping` and Agent Factory equivalents.
2. Add `workflows/issue-grouping.md`; import `shared/defaults.md` and `shared/security.md`; set the frontmatter security above.
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile` and commit `workflows/issue-grouping.lock.yml`.
5. Run `make verify`; no workflow run, no token spend.

## Definition of Done
- [ ] `workflows/issue-grouping.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Dedupe by symptom fingerprint in title or body hash
## Evidence
(verify log on SHA when workflow lands)
## Flow
```mermaid
sequenceDiagram
  participant WF as issue-grouping
  participant GH as GitHub issues
  WF->>GH: list open issues
  WF->>WF: cluster by symptom
  WF->>GH: tracking issue or grouped comment
```
## Named asks for Sven
- Schedule yes if fuzzy cron used (R01), row in `policies/POL25.yml` `sven_yes` first
- X01 live trial and first 3 audited runs (B02): Sven exact yes, spends tokens
## Cost
M tier, ~30-55 AIC per run (unverified)
## Sources
- gist-handover-agentic-workflows.md candidate 2
- Plan v3.2 F73 Block 5
