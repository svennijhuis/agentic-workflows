---
applyTo: "docs/**"
---

# Documentation

Diataxis map: [docs/README.md](../../docs/README.md). Backlog under `docs/pbi/` is Builder-owned; do not rewrite PBI content unless tasked.

## House style

- Short plain sentences ([POL16](../../policies/POL16.yml)): no em dash (U+2014), no en dash (U+2013). Use a hyphen or rephrase.
- Plain ASCII quotes only.
- Mermaid only inside fenced mermaid code blocks; must be valid mermaid.
- Link policies instead of restating rules (`policies/POLnn.yml`).
- No secret values; names only.

## Paths

- How-to: `docs/how-to/`
- Reference: `docs/reference/`
- Explanation: `docs/explanation/`

## Cross-links

- [copilot-instructions.md](../copilot-instructions.md)
- [aw.instructions.md](aw.instructions.md)
- [AGENTS.md](../../AGENTS.md)

Run `./scripts/verify.sh` after doc edits that touch compile or policy examples.
