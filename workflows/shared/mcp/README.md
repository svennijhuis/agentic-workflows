# MCP fragments

Add one Markdown file per MCP server (or per mcp-services deployment) **without** `on:`.

Own the **connection**, not the server code. Binaries and Docker images stay in [mcp-services](https://github.com/svennijhuis/mcp-services).

Suggested files later:

| File | Points at |
| --- | --- |
| `roslyn.md` | `mcp-roslyn` HTTP URL |
| `index.md` | `mcp-index` HTTP URL |
| `learnings.md` | `mcp-learnings` HTTP URL |

Shape:

```yaml
---
description: Org roslyn MCP (HTTP).
mcp-servers:
  roslyn:
    url: "https://REPLACE/mcp"
    allowed: ["*"]
network:
  allowed:
    - REPLACE
---
```

Consumers import `svennijhuis/agentic-workflows/workflows/shared/mcp/roslyn.md@v1` after URLs are real. Until then, leave this directory as documentation only.

IDE stdio config does not belong here; that lives in product repos or agentPacks `mcp.json`.
