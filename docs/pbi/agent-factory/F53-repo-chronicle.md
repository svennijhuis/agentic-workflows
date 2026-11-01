# F53: Repo chronicle (daily narrative)
- Status: todo
- Area: agent-factory
- Wave: PR 0 (implementation W6)
- Block: 6
- Lane: Builder
- Depends on: C01, C02, C03, C04, C05, C06, R01, X01, L01
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/repo-chronicle.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: one-way
- feedback: `make compile` (`gh aw compile --strict`)
## Goal
Ship `repo-chronicle` as an installable gh-aw workflow for svennijhuis repos that posts a discussion or issue summarizing commits, prs, and issues for the day.
## Context
Wave W6 later workflow. PR 0 documents intent only.
**What it does:** Posts a discussion or issue summarizing commits, PRs, and issues for the day.
**Value:** Narrative digest of daily activity; lower priority than F03 repo-status.
**How ours beats the example (Bar H):** Dedupe with F03, no PII.
**Trigger:** `workflow_dispatch` only (POL25). Daily cron is a named ask after measured cost.
**Safe outputs and limits:** Deduped daily chronicle issue.; `create-issue` max 1 or `create-discussion` max 1, `staged: true`.
**Issue/PR format:** Title prefix `[F53]`, footer from `shared/reporting.md`, dedupe key `repo-chronicle:{date}`.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal fine-grained PAT).

## Frontmatter security
- `permissions:` read only (`contents: read`, `issues: read`, `discussions: read`); no write permission.
- Writes only through `safe-outputs` (`create-issue` max 1 or `create-discussion` max 1), `staged: true` until Sven's yes.
- `timeout-minutes:` 15
- Trigger: `workflow_dispatch` only (POL25). Daily schedule is a named ask in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Study upstream `githubnext/agentics` workflow `repo-chronicle` and Agent Factory equivalents.
2. Add `workflows/repo-chronicle.md`; import `shared/defaults.md` and `shared/security.md`; set the frontmatter security above.
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile` and commit `workflows/repo-chronicle.lock.yml`.
5. Run `make verify`; no workflow run, no token spend.

## Definition of Done
- [ ] `workflows/repo-chronicle.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Deterministic pre-check; noop when no activity in window
- [ ] Dedupe with F03 repo-status via title key; no PII in narrative
## Evidence
(verify log on SHA when workflow lands)
## Flow
```mermaid
sequenceDiagram
    autonumber
    participant WF as repo-chronicle
    participant GH as GitHub
    participant Agent as Copilot agent
    WF->>GH: fetch day activity
    activate WF
    WF->>Agent: summarize narrative
    Agent-->>WF: chronicle md
    WF->>GH: issue or discussion
    deactivate WF
```
## Named asks for Sven
- Secondary triggers listed in Context: Sven exact yes, row in `policies/POL25.yml` `sven_yes` first
- X01 live trial and first 3 audited runs (B02): Sven exact yes, spends tokens
## Cost
Tier S: estimated 12-28 AIC per run (unverified). Daily cap 200 AIC repo-wide suggested.
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/blog/2026-01-13-meet-the-workflows-metrics-analytics/
