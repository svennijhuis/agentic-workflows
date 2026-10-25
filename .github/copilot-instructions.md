# Copilot instructions (catalog)

Repository conventions for `svennijhuis/agentic-workflows`. For rules, open the linked `policies/POLnn.yml` files; do not paraphrase them here.

## Catalog conventions

- Install path: `gh aw add svennijhuis/agentic-workflows/<name>@vX.Y.Z` (tag only, [POL01](../policies/POL01.yml)).
- Shared fragments live in `workflows/shared/` (compiler path rule in [docs/reference/layout.md](../docs/reference/layout.md)).
- Each workflow sets cost caps in its own frontmatter ([POL02](../policies/POL02.yml)).
- Commit `.lock.yml` next to each catalog workflow; keep fresh after compile ([POL17](../policies/POL17.yml)).
- Staged or report-only before writes ([POL03](../policies/POL03.yml)).
- `copilot-requests: none` where required ([POL21](../policies/POL21.yml)).
- Triggers: `workflow_dispatch` only until Sven enables more.
- Before any PR: `./scripts/verify.sh` must print `0 failures` ([verify skill](skills/verify-aw/SKILL.md)).

## Bar H checklist (workflow PBIs)

Every workflow PBI must meet Bar H. Details live in the links, not in this file.

- [Shared defaults import](../docs/pbi/done/C03-shared-defaults.md)
- [Pinned gh-aw plus import SHA or tag](../policies/POL01.yml)
- [Caps](../policies/POL02.yml) (`max-ai-credits`, `max-daily-ai-credits`, `max-turns`, `timeout-minutes`)
- [Pre-check then noop when nothing to do](../docs/pbi/README.md#bar-h-every-workflow-pbi) (see workflow PBI DoD)
- [Staged or report-only first](../policies/POL03.yml)
- [Dedupe](../docs/pbi/safe-outputs/O03-dedupe-expiry-footers-noise.md)
- [`min-integrity: approved`](../policies/POL05.yml)
- [Minimal network allowlist](../policies/POL06.yml)
- [Tool allowlist](../policies/POL07.yml)
- [Threat detection on](../policies/POL13.yml)
- [`on.roles` plus skip-bots](../policies/POL10.yml)
- [Fixed issue/PR format](../workflows/shared/reporting.md) ([POL16](../policies/POL16.yml))
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
