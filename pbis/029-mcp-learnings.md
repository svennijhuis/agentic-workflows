# 029 Shared MCP fragment: mcp-learnings

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Platform | [028](028-mcp-roslyn.md) |

## Context

Reviews can read prior learnings. Same shape as 028.

## Sources

- https://github.github.com/gh-aw/guides/mcps/
- https://github.com/svennijhuis/mcp-services

## Design

```yaml
# workflows/shared/mcp/learnings.md
mcp-servers:
  learnings:
    url: "https://<host>/learnings/mcp"
    allowed: [search]
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
