# monitoring: overview

**Purpose:** Azure exception watcher and read-only MCP (dispatch first).

## PBIs

- [M01: M01-exception-watcher-dispatch](M01-exception-watcher-dispatch.md)
- [M02: M02-azure-oidc-reader](M02-azure-oidc-reader.md)
- [M03: M03-hourly-cron-watcher](M03-hourly-cron-watcher.md)
- [M04: M04-azure-mcp-read-only](M04-azure-mcp-read-only.md)

## Dependency sketch

```mermaid
flowchart TD
  M01[M01] --> M02[M02]
  M02[M02] --> M03[M03]
  M03[M03] --> M04[M04]
  M04[M04]
```
