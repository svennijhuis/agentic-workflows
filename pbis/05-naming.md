# 05 Naming

Goal: short kebab-case, job named, never equal to an agentPacks skill name.

| Old | New | Why |
| --- | --- | --- |
| `workflows/squad-review.md` | `workflows/pr-review.md` | Job named like gallery `pr-review`; not the agentPacks command name |
| slash `/squad-review` | `/pr-review` | Follows workflow name; no clash with IDE `/squad-review` |
| `shared/squad.md` | `shared/agentpacks.md` | `squad` is an agentPacks skill name |
| `shared/org-defaults.md` | `shared/defaults.md` | Personal account, no org |
| new | `shared/standards/{common,dotnet,typescript,rust}.md` | Stack names, not skill names (`dotnet-review` etc.) |

Kept: `security.md`, `prompts/`, `mcp/`, `aw.yml`.

Status: done.
