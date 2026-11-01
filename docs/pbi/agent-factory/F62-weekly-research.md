# F62: Weekly research digest
- Status: todo
- Area: agent-factory
- Wave: PR 0 (implementation W6)
- Block: 6
- Lane: Builder
- Depends on: C01, C02, C03, C04, C05, C06, R01, X01, L01, Y06
- proof: `make verify` exits 0 (`gh aw compile --strict --dir workflows` clean for `workflows/weekly-research.md`, lock unchanged after compile, POL25 and POL31 clean); no run, no token spend
- door: one-way
- feedback: `make compile` (`gh aw compile --strict`)
## Goal
Ship `weekly-research` as an installable gh-aw workflow for svennijhuis repos that summarizes external sources on configured topics into a discussion.
## Context
Wave W6 later workflow. PR 0 documents intent only.
**What it does:** Summarizes external sources on configured topics into a discussion.
**Value:** Research discussion; overlaps external news bots.
**How ours beats the example (Bar H):** Tavily key via masked env only; no tokens in markdown.
**Trigger:** `workflow_dispatch` only (POL25). Weekly schedule is a named ask after Tavily key (Y06) and cost check.
**Safe outputs and limits:** Discussion with cited links; web search allowlisted.; `create-discussion` max 1, `staged: true`.
**Issue/PR format:** Title prefix `[F62]`, footer from `shared/reporting.md`, dedupe key `weekly-research:{date}`.
Engine: `copilot` with `COPILOT_GITHUB_TOKEN` (personal fine-grained PAT).

## Frontmatter security
- `permissions:` read only (`contents: read`, `discussions: read`); no write permission.
- Writes only through `safe-outputs` (`create-discussion` max 1), `staged: true` until Sven's yes.
- `timeout-minutes:` 20
- Trigger: `workflow_dispatch` only (POL25). Weekly schedule is a named ask in `policies/POL25.yml` `sven_yes` first.
## Steps
1. Study upstream `githubnext/agentics` workflow `weekly-research` and Agent Factory equivalents.
2. Add `workflows/weekly-research.md`; import `shared/defaults.md` and `shared/security.md`; set the frontmatter security above.
3. Add deterministic pre-check returning `noop` when nothing to do.
4. Run `make compile` and commit `workflows/weekly-research.lock.yml`.
5. Run `make verify`; no workflow run, no token spend.

## Definition of Done
- [ ] `workflows/weekly-research.md` and its `.lock.yml` committed; `gh aw compile --strict` clean (0 errors, 0 warnings), lock unchanged after `make compile`
- [ ] Frontmatter: read-only `permissions`, writes only via `safe-outputs` (`staged: true`, a `max` per output), `timeout-minutes` set
- [ ] Trigger `workflow_dispatch` only (POL25); no `skills:` in a shared fragment (POL31)
- [ ] `make verify` exits 0; no run, no token spend
- [ ] Fetches own context with tools and imports (Bar H, gist A7); prompt never pastes repo content
- [ ] Tavily key via masked env only (Y06); no tokens in markdown
## Evidence
(verify log on SHA when workflow lands)
## Flow
```mermaid
sequenceDiagram
    autonumber
    participant WF as weekly-research
    participant Web as Tavily (allowlisted)
    participant Agent as Copilot agent
    WF->>Web: search topics
    activate WF
    Web-->>WF: snippets
    WF->>Agent: synthesize digest
    Agent-->>WF: markdown
    WF->>WF: open discussion
    deactivate WF
```
## Named asks for Sven
- Y06 (Tavily API key)
- Weekly schedule: Sven exact yes, row in `policies/POL25.yml` `sven_yes` first
- X01 live trial and first 3 audited runs (B02): Sven exact yes, spends tokens
## Cost
Tier S: estimated 15-30 AIC per run (unverified). Daily cap 200 AIC repo-wide suggested.
## Sources
- https://github.github.com/gh-aw/agent-factory-status/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/blog/2026-01-13-meet-the-workflows-advanced-analytics/
