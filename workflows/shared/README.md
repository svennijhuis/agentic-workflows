# Shared fragments

No `on:`. Imported, never run alone. Must stay at `workflows/shared/` (relative imports resolve from `workflows/`).

```yaml
imports:
  - shared/defaults.md                                                  # local
  - svennijhuis/agentic-workflows/workflows/shared/defaults.md@v1.0.0   # remote
```

| Fragment | Use |
| --- | --- |
| [defaults.md](defaults.md) | Baseline GitHub toolsets |
| [security.md](security.md) | Closed network baseline |
| [agentpacks.md](agentpacks.md) | agentPacks squad skill + plugin (pinned) |
| [standards/](standards/) | agentPacks review standards per stack: `common`, `dotnet`, `typescript`, `rust` |
| [mcp/](mcp/) | MCP connection snippets (mcp-services) |
| [prompts/](prompts/) | Actions-only prompt snippets |
