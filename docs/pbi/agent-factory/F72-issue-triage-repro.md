# F72: Issue triage with repro
- Status: todo
- Area: agent-factory
- Wave: W3
- Block: 3
- Lane: Builder
- Depends on: C03, C04, R02, X01, F00
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/issue-triage-repro.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: one-way
- feedback: `make compile` (`gh aw compile --strict`)
## Goal
On `issues: opened`, read the issue, attempt repro against main with repo-native commands, label and post one report-only comment with repro result. No code changes (gist candidate 1).
## Context
Connects outer loop (issues) to inner loop without Sven as proxy. Token spend requires Sven exact yes before live trigger; start with `workflow_dispatch` staged.
**What it does:** On `issues: opened`, read the issue, attempt repro against main with repo-native commands, label and post one report-only comment with repro result
**Value:** 
**How ours beats the example (Bar H):** Bar H defaults, staged outputs, dispatch-only rollout
**Trigger:** `workflow_dispatch` only (POL25). `issues: opened` is a named ask, row in `policies/POL25.yml` `sven_yes` first.
**Safe outputs and limits:** `create-issue-comment` max 1, label updates via safe-output max 3; `create-issue-comment` max 1, label updates via safe-output max 3, `staged: true`.
**Issue/PR format:** Title prefix `[F72]`, footer from `shared/reporting.md`
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal fine-grained PAT).

## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`); no write permission.
- Writes only through `safe-outputs` (`create-issue-comment` max 1, label updates via safe-output max 3), `staged: true` until Sven's yes.
- `timeout-minutes:` 20
- Trigger: `workflow_dispatch` only (POL25). `issues: opened` is a named ask in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Study upstream `githubnext/agentics` workflow `issue-triage-repro` and Agent Factory equivalents.
2. Add `workflows/issue-triage-repro.md`; import `shared/defaults.md` and `shared/security.md`; set the frontmatter security above.
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile` and commit `workflows/issue-triage-repro.lock.yml`.
5. Run `make verify`; no workflow run, no token spend.

## Definition of Done
- [ ] `workflows/issue-triage-repro.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Pre-check noop when issue template missing repro fields and policy says skip
- [ ] One report-only comment with repro result; no code changes
- [ ] [X07](../testing/X07-workflow-benchmark.md) benchmark: 5 or more fixed cases with known answers in `docs/benchmarks/issue-triage-repro.md`, docs only; live score is a named ask
## Evidence
(verify log on SHA when workflow lands)
## Flow
```mermaid
sequenceDiagram
  participant GH as issues opened
  participant WF as issue-triage-repro
  participant Agent as Copilot
  GH->>WF: trigger after Sven yes
  WF->>WF: pre-check
  WF->>Agent: repro attempt
  Agent-->>WF: result
  WF->>GH: one comment + labels
```
## Named asks for Sven
- Exact yes before `issues: opened` goes live, row in `policies/POL25.yml` `sven_yes` first
- X01 live trial and first 3 audited runs (B02): Sven exact yes, spends tokens
- X07 live benchmark score: Sven exact yes per run, spends tokens
## Cost
M tier, ~25-40 AIC per issue (unverified)
## Sources
- gist-handover-agentic-workflows.md candidate 1
- Plan v3.2 F72 Block 3
