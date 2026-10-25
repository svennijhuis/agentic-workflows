# 028 Shared MCP fragment: mcp-roslyn over HTTP

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Platform | [011](011-repo-visibility.md) |

## Context

pr-review on .NET repos could use Roslyn symbols. Needs a deployed HTTP endpoint (mcp-services) first.

## Sources

- https://github.github.com/gh-aw/guides/mcps/
- https://github.github.com/gh-aw/reference/mcp-gateway/
- https://github.com/svennijhuis/mcp-services

## Design

```yaml
# workflows/shared/mcp/roslyn.md
mcp-servers:
  roslyn:
    url: "https://<host>/roslyn/mcp"
    allowed: ["*"]
network:
  allowed: ["<host>"]
```

## Code example

Import in pr-review for dotnet consumers.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No stdio binaries in the catalog.

## Risks

Needs a public or tunnelled endpoint; auth TBD.

## Post-merge

None beyond merge.
