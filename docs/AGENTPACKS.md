# Reuse agentPacks and other agent repos

The org already has agent behaviour in other repositories. This catalog **references** them. It does not duplicate skills, hooks, or MCP server code.

## What each repo owns

| Repo | Owns | Consumed by |
| --- | --- | --- |
| [svennijhuis/agentPacks](https://github.com/svennijhuis/agentPacks) | Agent Plugins: `squad`, `pack-check`, `git`, `dotnet`, `rust`, `typescript` | Cursor, Copilot CLI, Claude Code, Codex **and** gh-aw via `plugins:` |
| [svennijhuis/mcp-services](https://github.com/svennijhuis/mcp-services) | MCP server binaries (filesystem, database, roslyn, index, learnings) | IDE MCP config **and** gh-aw `mcp-servers:` |
| **this repo** | Scheduled/event-driven GitHub Actions agents | Product repos via `gh aw add` / `imports:` |

Interactive `/squad` on a laptop is not the same as a Monday `schedule:` job in Actions. Same standards can apply if the Actions workflow loads the same plugins.

## Load agentPacks from a workflow (`plugins:`)

gh-aw checks out each plugin and installs it the way the engine expects (`copilot plugin install`, Claude `--plugin-dir`, Codex marketplace add). Support is experimental; compile emits a warning.

Path form is `owner/repo/path/to/plugin@ref`. **Ref is required** and is rewritten to a commit SHA at compile time.

AgentPacks authors plugins under `plugins/<name>/` on `main`. IDE clients should install the **generated** tree from the `marketplace` branch ([agentPacks README](https://github.com/svennijhuis/agentPacks)). Prefer pinning `@marketplace` (or a marketplace SHA) in production workflows.

Catalog fragment: [`workflows/shared/agentpacks.md`](../workflows/shared/agentpacks.md) (git only). Review stack: [`workflows/shared/squad.md`](../workflows/shared/squad.md). Example workflows: [`workflows/with-agentpacks.md`](../workflows/with-agentpacks.md) (smoke) and [`workflows/squad-review.md`](../workflows/squad-review.md) (real PR review).

In a consuming repo you can also declare plugins locally:

```yaml
engine: copilot
plugins:
  - svennijhuis/agentPacks/plugins/git@marketplace
  - svennijhuis/agentPacks/plugins/dotnet@marketplace
```

For a **private** plugin repo, the default `GITHUB_TOKEN` cannot clone it. Use the object form:

```yaml
plugins:
  - plugin: svennijhuis/agentPacks/plugins/git@marketplace
    github-token: ${{ secrets.AGENTPACKS_READ_TOKEN }}
  # or github-app: { client-id, private-key }
```

See [Frontmatter — Agent Plugins](https://github.github.com/gh-aw/reference/frontmatter/).

Which packs to load:

| Plugin | Typical Actions use |
| --- | --- |
| `git` | Guard destructive git in the agent sandbox |
| `dotnet` / `rust` / `typescript` | Language build/test/review skills when the target repo uses that stack |
| `pack-check` | Stack detection; more useful in IDEs than in a workflow that already knows the repo |
| `squad` | `/squad-review` on PRs via [`workflows/squad-review.md`](../workflows/squad-review.md). Full `/squad` plan/implement stays in the IDE |

Do **not** add a second copy of these skills under `workflows/shared/prompts/`.

## Load a single skill (`skills:`)

When you need one skill, not a whole plugin:

```yaml
skills:
  - svennijhuis/agentPacks/plugins/dotnet/skills/<skill-name>@marketplace
```

Compiler pins the ref to a SHA. Private skill repos need `github-token` or `github-app` on the object form. Docs: [Frontmatter Skills](https://github.github.com/gh-aw/reference/frontmatter/).

## APM (optional, many primitives at once)

[Agent Package Manager](https://github.github.com/gh-aw/reference/dependencies/) can pack skills/plugins from many repos into an Actions artifact. Vendor `shared/apm.md` from `microsoft/apm`, then:

```yaml
imports:
  - uses: shared/apm.md
    with:
      packages:
        - svennijhuis/agentPacks/plugins/git#marketplace
        - github/awesome-copilot/skills/review-and-refactor
```

Use APM when a workflow needs a **tree** of packages with a lock file. Use `plugins:` / `skills:` when you only need one or two org packs.

## MCP from mcp-services

[`mcp-services`](https://github.com/svennijhuis/mcp-services) speaks stdio (local IDE) and Streamable HTTP (`--http` / Docker on ports 5100–5104).

In an Actions workflow, prefer HTTP to a deployed instance and declare it in a shared fragment under `workflows/shared/mcp/` (see that folder’s README). Example shape:

```yaml
mcp-servers:
  roslyn:
    url: "https://mcp.example.internal/roslyn/mcp"
    allowed: ["*"]
network:
  allowed:
    - mcp.example.internal
```

Do not vendor the C# servers into this catalog. Point at the running service. Secrets stay in the consuming repo or org.

## Copilot custom agents (`.github/agents/`)

Specialized prompt files can live in a dedicated agents repo and be imported:

```yaml
imports:
  - svennijhuis/agentPacks/.github/agents/code-reviewer.md@v1
```

Only **one** agent file per workflow. AgentPacks today is plugin-based, not a `.github/agents/` library. Add such files there or in this catalog’s future `agents/` package only if Copilot web agents need them independently of plugins.

## Decision rule

1. Human in an editor → install agentPacks from the `marketplace` branch (existing README).
2. Unattended GitHub Action → install a workflow from **this** catalog; import `shared/agentpacks.md` or `shared/mcp/*` instead of copying plugin files.
3. New behaviour needed in **both** places → add it to agentPacks (or mcp-services), then reference it from a catalog fragment.
