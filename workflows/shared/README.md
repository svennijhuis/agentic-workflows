# Shared fragments

Files here are **not** installed as standalone Actions. They have no `on:` field. Catalog workflows and consuming repos import them:

```yaml
imports:
  - shared/org-defaults.md                                          # local, from a file in workflows/
  - svennijhuis/agentic-workflows/workflows/shared/org-defaults.md@v1  # remote, from another repo
```

| Fragment | Use |
| --- | --- |
| [org-defaults.md](org-defaults.md) | Baseline GitHub toolsets |
| [security.md](security.md) | Network / safety notes for org workflows |
| [squad.md](squad.md) | `skills:` + `plugins:` from agentPacks (no copied SKILL.md) |
| [mcp/](mcp/) | MCP server snippets (point at mcp-services; do not vendor binaries) |
| [prompts/](prompts/) | Prompt snippets unique to **Actions** (not copies of plugin SKILL.md) |

Relative imports resolve from `workflows/`, so this folder must stay at `workflows/shared/`.
