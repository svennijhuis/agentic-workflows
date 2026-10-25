# ADR 0001: Repository layout for installable workflows

- Status: accepted (PR 0 documentation)
- Date: 2026-10-25
- Deciders: Sven (PO), Strategy plan v3.1

## Context

`svennijhuis/agentic-workflows` is a personal, org-ready catalog of GitHub Agentic Workflows. Consumers install with `gh aw add svennijhuis/agentic-workflows/<name>@<version>`. We need one layout for installable workflows, shared imports, policies, and this repo's own CI compilations.

Three reference layouts were compared:

1. **gh-aw Recommended Enterprise Pattern** ([sharing workflows](https://github.github.com/gh-aw/guides/sharing-workflows/), [aw.yml package manifest](https://github.github.com/gh-aw/reference/aw-yml-package-manifest/)): central catalog, `aw.yml` `includes:`, flat install paths, `shared/` fragments, version tags, consumer `source:` frontmatter, `.lock.yml` reproducibility.
2. **githubnext/agentics** ([workflows tree](https://github.com/githubnext/agentics/tree/main/workflows)): root `workflows/*.md` plus `workflows/shared/` for cross-workflow imports; supporting `docs/`, tests, CODEOWNERS, SECURITY, SUPPORT, Makefile. Optimized for a public workflow library, not necessarily aw.yml packaging.
3. **github/gh-aw own repo** ([`.github/workflows`](https://github.com/github/gh-aw/tree/main/.github/workflows)): hundreds of markdown workflows under `.github/workflows/` plus `.github/workflows/shared/` for the product's dogfood and factory. Poor fit as the install surface for a small consumer catalog.

This repo already ships `aw.yml`, `workflows/squad-review.md`, and `workflows/shared/` (see C02 in the PBI plan).

## Options

| Option | Summary | Pros | Cons |
|--------|---------|------|------|
| A | Enterprise pattern only: `workflows/` + root `shared/` + `aw.yml` (plan C02) | Matches gh-aw install docs; clear consumer paths; room for `policies/`, `scripts/verify.sh` | Differs from agentics nested `workflows/shared/` |
| B | agentics clone: `workflows/` with nested `workflows/shared/` only | Familiar to agentics contributors | Duplicates "shared" naming; plan puts `shared/` at repo root for policies and MCP |
| C | gh-aw style: all catalog under `.github/workflows/` | Same as upstream factory | Confuses catalog vs this repo's compiled CI; awkward `gh aw add` paths |

## Decision

Adopt **option A (plan C02)**: root `workflows/` (flat installable markdown), root `shared/` (defaults, security, reporting, MCP auth, prompts), `aw.yml` manifest, `policies/` + `scripts/verify.sh`, and **only** this repository's own automation under `.github/workflows/` (compiled + lock files), matching gh-aw enterprise guidance while keeping agentics-style flat workflow names at the repo root.

Org readiness: owner name remains a single variable (`svennijhuis` today). Org-only switches (central billing, rulesets, org secrets, teams) are documented in G05 and do not change layout.

## Consequences

- Install commands stay `gh aw add svennijhuis/agentic-workflows/<workflow>@vX.Y.Z` with paths under `workflows/`.
- Shared imports use `shared/` and `workflows/shared/` only where a workflow-specific fragment belongs beside squad patterns (both allowed; prefer root `shared/` for catalog-wide defaults per C05).
- `squad-review.md` remains until F01 merges; removal PBIs must list each deleted path.
- PR 0 PBIs under `docs/pbi/` track implementation waves; Builder lane owns gate, workflows, and monitoring code.

## Sources

- https://github.github.com/gh-aw/guides/sharing-workflows/
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.com/githubnext/agentics/tree/main/workflows
- https://github.com/github/gh-aw/tree/main/.github/workflows
- Strategy `agentic-workflows-pbi-plan.md` (C02, v3.1 item 2)
- Research `gh-aw-org-packet.md` section 1 (proposed tree)
