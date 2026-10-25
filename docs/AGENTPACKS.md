# agentPacks in workflows

Reference, never copy. Pin a SHA or tag, never a branch (`marketplace` is generated and can lag `main`).

## What pr-review imports, and why

| Import | Why |
| --- | --- |
| `skills: plugins/squad/skills/squad` | Review contract; `disable-model-invocation`, so it must be installed |
| `plugins: plugins/squad` | Agents: `squad-reviewer`, `squad-simplifier`, `squad-security-reviewer`, `squad-orchestrator` |
| `imports: plugins/squad/commands/squad-review.md` | The review steps. Edit in agentPacks |
| `shared/standards/*.md` | Language standards as text (`<lang>-review` set from `standards.source.json`) |

Dropped: `git` plugin (guards local git, nothing to review) and `dotnet` / `typescript` / `rust` plugins (only needed for their standards, now imported directly; less to install).

The adapter body only overrides I/O: pin this PR, post via safe-outputs, write no files, no retro, no fix rounds.

## Change review behaviour

Edit agentPacks, merge, tag. Bump the SHA/tag in `workflows/shared/agentpacks.md`, `workflows/shared/standards/*.md` and `workflows/pr-review.md`. Recompile.

## Forms

```yaml
plugins:
  - svennijhuis/agentPacks/plugins/squad@<sha>
skills:
  - svennijhuis/agentPacks/plugins/squad/skills/squad@<sha>
imports:
  - svennijhuis/agentPacks/plugins/dotnet/standards/csharp.md@<sha>
```

Private agentPacks: object form with `github-token: ${{ secrets.AGENTPACKS_READ_TOKEN }}` or `github-app:`. `plugins:` is experimental (compile warns).

## MCP

Point at a running mcp-services HTTP endpoint from `workflows/shared/mcp/`. Do not vendor servers.

## Rule

Human in an editor: agentPacks plugins. Unattended Action: this catalog. New behaviour for both: add it to agentPacks, then import it here.
