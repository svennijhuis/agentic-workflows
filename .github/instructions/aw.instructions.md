---
applyTo: "workflows/**"
---

# Workflow authoring

Applies to `workflows/**`. Repo checks: [POL25](../../policies/POL25.yml), [POL31](../../policies/POL31.yml). Compile and frontmatter: `gh aw compile --strict`.

## Before you open a PR

```bash
make verify
```

Skill: [verify-aw](../skills/verify-aw/SKILL.md). Doc: [docs/how-to/verify-workflow.md](../../docs/how-to/verify-workflow.md).

## Conventions

- List new installable workflows in [aw.yml](../../aw.yml) `includes:`.
- Import shared pieces from `workflows/shared/` (local) or pinned remote refs ([C05](../../docs/pbi/done/C05-imports-import-schema.md)).
- Configure consumers only via `import-schema` `with:` keys; unknown keys fail compile.
- Set caps in **this** workflow frontmatter; imports cannot carry caps.
- `workflow_dispatch` only until Sven's yes for other triggers ([POL25](../../policies/POL25.yml)).
- Staged first (frontmatter `safe-outputs`).
- After frontmatter edits: `make compile`, commit `.md` and `.lock.yml`.
- No `skills:` in `workflows/shared/` fragments ([POL31](../../policies/POL31.yml)); pin skills on the main workflow only.
- agentPacks: [docs/reference/agentpacks-contract.md](../../docs/reference/agentpacks-contract.md).
- Bar H: workflow fetches its own context with tools and imports; the prompt never pastes repo content (gist A7).

## Helpers

- Custom agent: [aw-author.agent.md](../agents/aw-author.agent.md)
- [copilot-instructions.md](../copilot-instructions.md)
- [AGENTS.md](../../AGENTS.md)
