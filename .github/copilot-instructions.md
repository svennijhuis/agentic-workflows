# Copilot instructions (catalog)

Repository conventions for `svennijhuis/agentic-workflows`. Repo-only rules: [POL25](../policies/POL25.yml), [POL31](../policies/POL31.yml). Everything else: workflow frontmatter plus `gh aw compile --strict`.

## Catalog conventions

- Install path: `gh aw add svennijhuis/agentic-workflows/<name>@vX.Y.Z` (tag or SHA, never a branch).
- Shared fragments live in `workflows/shared/` (compiler path rule in [docs/reference/layout.md](../docs/reference/layout.md)).
- Each workflow sets cost caps, permissions, network, and triggers in its own frontmatter.
- Commit `.lock.yml` next to each catalog workflow; refresh with `make compile`.
- Staged or report-only before writes (frontmatter `safe-outputs`).
- `copilot-requests: none` on catalog workflows until org billing switch.
- Triggers: `workflow_dispatch` only until Sven enables more ([POL25](../policies/POL25.yml)).
- Before any PR: `make verify` must print `0 failures` ([verify skill](skills/verify-aw/SKILL.md)).

## Bar H checklist (workflow PBIs)

Every workflow PBI must meet Bar H. Details live in the links, not in this file.

- [Shared defaults import](../docs/pbi/done/C03-shared-defaults.md)
- Pinned gh-aw plus import SHA or tag
- Caps in workflow frontmatter (`max-ai-credits`, `max-daily-ai-credits`, `max-turns`, `timeout-minutes`)
- Pre-check then noop when nothing to do ([docs/pbi/README.md#bar-h-every-workflow-pbi](../docs/pbi/README.md#bar-h-every-workflow-pbi))
- Staged or report-only first
- Dedupe safe-outputs footers (Bar H)
- Minimal permissions and network in frontmatter (`gh aw compile --strict` enforces the rest)
- [Fixed issue/PR format](../workflows/shared/reporting.md)
- [Trial-repo run on X01](../docs/pbi/testing/X01-test-repo-trialops.md)
- [Audit of first 3 runs](../docs/pbi/README.md#bar-h-every-workflow-pbi)
- [Measured cost per run in PBI Evidence](../docs/pbi/observability/B03a-value-vs-cost.md)
- Workflow fetches its own context with tools and imports; the prompt never pastes repo content (gist A7)
- [Benchmark at or above baseline](../docs/pbi/testing/X07-workflow-benchmark.md)

## Cross-links

- [AGENTS.md](../AGENTS.md)
- [aw.instructions.md](instructions/aw.instructions.md)
- [aw-author agent](agents/aw-author.agent.md)

Never merge. Never force push. No secrets in files.
