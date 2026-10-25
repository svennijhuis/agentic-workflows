# Shared fragments

Not installed alone. No `on:` field. Catalog workflows and consumers import them:

```yaml
imports:
  - shared/defaults.md
  - svennijhuis/agentic-workflows/workflows/shared/defaults.md@v1.0.0
```

gh-aw v0.93.4 requires shared files under `workflows/shared/` (imports outside `workflows/` fail compile).

## Fragments

| File | Use |
| --- | --- |
| [defaults.md](defaults.md) | Baseline engine, admission, shared tool defaults |
| [security.md](security.md) | Network and safety baseline |
| [reporting.md](reporting.md) | Fixed issue/PR report shape ([POL16](../../policies/POL16.yml)) |
| [agentpacks.md](agentpacks.md) | Pinned agentPacks skills/commands (not copied SKILL.md) |
| [mcp/](mcp/) | MCP snippets (point at mcp-services; see [mcp/README.md](mcp/README.md)) |
| [prompts/](prompts/) | Actions-only prompt snippets ([prompts/README.md](prompts/README.md)) |

Configure consumers with `import-schema` `with:` only; unknown keys fail compile ([C05](../../docs/pbi/done/C05-imports-import-schema.md)).

Caps are **not** importable; set them in each workflow frontmatter ([POL02](../../policies/POL02.yml)).
