---
applyTo: "workflows/**"
---

# Workflow authoring

Applies to `workflows/**`. Rules: [policies/POL01.yml](../../policies/POL01.yml) through [policies/POL23.yml](../../policies/POL23.yml).

## Before you open a PR

```bash
./scripts/verify.sh
```

Skill: [verify-aw](../skills/verify-aw/SKILL.md). Doc: [docs/how-to/verify-workflow.md](../../docs/how-to/verify-workflow.md).

## Conventions

- List new installable workflows in [aw.yml](../../aw.yml) `includes:`.
- Import shared pieces from `workflows/shared/` (local) or pinned remote refs ([C05](../../docs/pbi/done/C05-imports-import-schema.md)).
- Configure consumers only via `import-schema` `with:` keys; unknown keys fail compile.
- Set caps in **this** workflow frontmatter ([POL02](../../policies/POL02.yml)); imports cannot carry caps.
- `workflow_dispatch` only until Sven's yes for other triggers.
- Staged first ([POL03](../../policies/POL03.yml)).
- After frontmatter edits: `gh aw compile --dir workflows --strict --actionlint`, commit `.md` and `.lock.yml` ([POL17](../../policies/POL17.yml)).
- agentPacks: [docs/reference/agentpacks-contract.md](../../docs/reference/agentpacks-contract.md).
- Bar H: workflow fetches its own context with tools and imports; the prompt never pastes repo content (gist A7).

## Helpers

- Custom agent: [aw-author.agent.md](../agents/aw-author.agent.md)
- [copilot-instructions.md](../copilot-instructions.md)
- [AGENTS.md](../../AGENTS.md)
