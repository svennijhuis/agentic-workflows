---
applyTo: "docs/**"
---

# Documentation

Diataxis map: [docs/README.md](../../docs/README.md). Backlog under `docs/pbi/` is Builder-owned; do not rewrite PBI content unless tasked.

## House style

- Short plain sentences: no em dash (U+2014), no en dash (U+2013). Use a hyphen or rephrase.
- Plain ASCII quotes only.
- Mermaid only inside fenced mermaid code blocks; must be valid mermaid.
- Link [POL25](../../policies/POL25.yml) and [POL31](../../policies/POL31.yml) for repo-only rules; point to workflow frontmatter and `gh aw compile --strict` for the rest.
- No secret values; names only.

## Paths

- How-to: `docs/how-to/`
- Reference: `docs/reference/`
- Explanation: `docs/explanation/`

## Cross-links

- [copilot-instructions.md](../copilot-instructions.md)
- [aw.instructions.md](aw.instructions.md)
- [AGENTS.md](../../AGENTS.md)

Run `make verify` after doc edits that touch compile examples or POL fixtures.
