# F09: AI release notes
- Status: todo
- Area: agent-factory
- Wave: W6
- Block: 6
- Lane: Builder
- Depends on: C03, C04, C06, L01
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/release-notes.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: two-way
- triage: build (Block 6 workflow)
- feedback: `make compile` (`gh aw compile --strict`)
- harness: gh-aw, engine copilot via shared/defaults.md (when built)
- review-input: diff + this PBI + DoD (+ linked spec) + PR description, never builder session logs (PA6)
- kind: skill
- Source: PA8 (pre-link PBI from PR #4, origin in its Sources) https://github.com/svennijhuis/agentic-workflows/pull/4 https://github.github.com/gh-aw/gallery/ai-release-notes/
- Module boundary: `workflows/release-notes.md`, its lock and `workflows/shared/` are the copy unit; no agentPacks import in this PBI
## Goal
On release, draft release notes issue or PR body for human edit.
## Context
Upstream reference: `ai-release-notes` (https://github.github.com/gh-aw/gallery/ai-release-notes/).
**What it does:** On release, draft release notes issue or PR body for human edit.
**Value for Sven repos:** See workflow-ratings.md row; prioritize NOW set for daily maintenance and security.
**How ours beats the example (Bar H):** Human merges notes; dedupe per tag
**Trigger:** `workflow_dispatch` only (POL25). A `release` trigger is a named ask for a later Sven yes, recorded in `policies/POL25.yml` `sven_yes` before it exists.
**Safe outputs and limits:** `create-issue` or PR comment report-only first
**Issue/PR format:** Title prefix `[F09]`, body uses `shared/reporting.md` audit footer with workflow id, run URL, and AIC when known.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal PAT). No `copilot-requests: write` (org billing only).

## Frontmatter security
- `permissions:` read only (`contents: read`, `pull-requests: read`, `issues: read`); no write permission.
- Writes only through `safe-outputs`: `create-issue` or `create-pull-request` (`max: 1`), `staged: true` until Sven's yes.
- `timeout-minutes:` 15.
- Trigger: `workflow_dispatch` only (POL25). Release event triggers are named asks for Sven, recorded in `policies/POL25.yml` `sven_yes` first.

## Steps
1. Add `workflows/release-notes.md`; import `shared/defaults.md` and `shared/security.md`.
2. Set frontmatter security (read-only `permissions`, `safe-outputs` with `staged: true` and a `max` per output, `timeout-minutes`, `workflow_dispatch` only).
3. Add deterministic pre-check step; writes `noop` when there is nothing to do.
4. Run `make compile` and commit the `.lock.yml`.
5. Run `make verify`.
6. Write the "copy this" note at `docs/reference/release-notes.md`: the md, its lock, and `workflows/shared/` files an org copies, standalone, no secrets.

## Definition of Done
- [ ] `workflows/release-notes.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] `workflows/release-notes.md` imports `shared/defaults.md` (engine copilot, caps, admission)
- [ ] Deterministic `steps:` pre-check; writes `noop` when nothing to do (0 AIC)
- [ ] `workflow_dispatch` only, plus the "copy this" note at `docs/reference/release-notes.md` (step 7): the md, lock and `shared/` files an org copies, standalone, no secrets
- [ ] [X07](../testing/X07-workflow-benchmark.md) benchmark cases: 5 or more fixed cases with known answers written in `docs/benchmarks/<workflow>.md`, docs only, no run; the X07 score is a named ask
## Evidence
(commands, verify log on SHA)
## Flow
```mermaid
sequenceDiagram
  participant Sven
  participant WF as release-notes
  participant Agent as Copilot
  participant GH as GitHub
  Sven->>WF: workflow_dispatch (tag input)
  activate WF
  WF->>Agent: Summarize commits
  Agent-->>WF: Notes draft
  WF->>GH: issue or comment (report-only)
  deactivate WF
```
## Named asks for Sven
- X01 live trial plus `gh aw audit` on the first 3 runs with measured AIC in Evidence (B02, Bar H live part): Sven exact yes, it spends tokens
- A `release` trigger: Sven exact yes per trigger, row in `policies/POL25.yml` `sven_yes` first
- X07 benchmark score at or above baseline (Bar H): each score is a live [X07](../testing/X07-workflow-benchmark.md) run on the X01 repo (`door: one-way`), Sven exact yes per run, it spends tokens
## Cost
M tier, ~25-45 AIC per release (unverified)
## Sources
- https://github.github.com/gh-aw/gallery/ai-release-notes/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/workflows/
- docs/pbi/workflow-ratings.md
