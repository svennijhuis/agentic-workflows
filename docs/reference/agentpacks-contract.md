# agentPacks import contract (C12 v1.1)

Canonical contract lives in [agentPacks PR #80](https://github.com/svennijhuis/agentPacks/pull/80). Pins and allowlists are enforced by `gh aw compile --strict` on consumer and catalog workflows.

## Pins

- `imports:` and `plugins:` use `@vX.Y.Z` on the generated agentPacks marketplace commit, or its 40-hex SHA.
- Never a branch ref. Never `plugins:` at a `main` SHA.
- Bump pins only via L02 `scripts/bump-pin.sh` (tags only) when that script ships.

## PR #2 correction

[agentic-workflows PR #2](https://github.com/svennijhuis/agentic-workflows/pull/2) pinned `plugins:` at a `main` SHA. That loads **zero** Copilot agents. Until agentPacks ships C12 tags, `squad-review` uses `skills:` plus `commands/` import at a pinned SHA, not `plugins:` at main.

## Inputs

Per-stack bundles first; typed `import-schema` inputs later. Consumers do not edit imported agentPacks files ([G00a](../pbi/done/G00a-consumer-strategy.md)).

## Allowlist v1 (agentPacks owns)

Documented paths (agentPacks repo is source of truth):

- `shared/standards/{http-api,testing-principles,design,engineering}.md`
- `plugins/{dotnet,rust,typescript}/standards/*.md`
- `plugins/squad/commands/squad-review.md`
- `plugins: plugins/squad` (tag only when tags exist)
- Later `gh-aw/*.md`

## Caps

`max-ai-credits`, `max-daily-ai-credits`, `max-turns`, `timeout-minutes` belong in **each workflow's own frontmatter**. The compiler ignores caps in imports. Repo vars `GH_AW_DEFAULT_MAX_AI_CREDITS` and `GH_AW_DEFAULT_MAX_DAILY_AI_CREDITS` are optional fallbacks.

## Compat

agentPacks semver; breaking contract changes are major. Run X01 trial before bumping pins on main.

## Load patterns

**Plugins (tag only when available):**

```yaml
plugins:
  - svennijhuis/agentPacks/plugins/git@v1.0.0
```

**Single skill:**

```yaml
skills:
  - svennijhuis/agentPacks/plugins/squad/skills/squad@<40-hex-sha>
```

`skills:` goes in the consumer workflow frontmatter (for squad-review: [`workflows/squad-review.md`](../../workflows/squad-review.md)), never in a `workflows/shared/` fragment: gh-aw reads `skills:` only from the main workflow and silently drops it from an import (C12b, guarded by [POL31](../../policies/POL31.yml)). The fragment [`workflows/shared/agentpacks.md`](../../workflows/shared/agentpacks.md) keeps only the wiring note.

Copy this: an org copies `workflows/squad-review.md`, `workflows/squad-review.lock.yml` and `workflows/shared/`; the pinned skill comes with the md.

Private plugin repos need `github-token` or `github-app` on the object form ([gh-aw frontmatter](https://github.github.com/gh-aw/reference/frontmatter/)).

## MCP from mcp-services

HTTP MCP to deployed [mcp-services](https://github.com/svennijhuis/mcp-services) instances. Snippets under `workflows/shared/mcp/`. Do not vendor server binaries here.

## Decision rule

1. Human in an editor: install agentPacks from generated marketplace (agentPacks README).
2. Unattended Actions: install from this catalog; import `workflows/shared/agentpacks.md` or pinned allowlist paths.
3. New behaviour in both places: add to agentPacks, then reference from a catalog fragment.

## Flow

```mermaid
sequenceDiagram
  participant AP as agentPacks
  participant AW as AW workflow
  participant V as make verify
  AP->>AP: tag vX.Y.Z on generated commit
  AW->>AP: import @vX.Y.Z
  V->>V: gh aw compile --strict
```

## See also

- PBI [C12](../pbi/done/C12-agentpacks-import-contract.md)
- [consume.md](../how-to/consume.md)
