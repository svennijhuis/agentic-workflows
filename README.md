# Agentic workflows catalog

Org source of truth for [GitHub Agentic Workflows](https://github.github.com/gh-aw/). Other repositories **install** templates from here; they do not copy-paste Markdown by hand.

This repo is the CI/Actions catalog. Interactive IDE behaviour lives in [`agentPacks`](https://github.com/svennijhuis/agentPacks). MCP servers live in [`mcp-services`](https://github.com/svennijhuis/mcp-services). See [How it works](docs/HOW-IT-WORKS.md) and [Using agentPacks](docs/AGENTPACKS.md).

Replace `svennijhuis` with the company org slug when this catalog moves.

## Install into another repository

Prerequisites in the **consuming** repo:

```bash
gh extension install github/gh-aw
gh aw init
```

Then add a catalog workflow (pin a tag in production):

```bash
gh aw add svennijhuis/agentic-workflows/hello-org@v1
gh aw add svennijhuis/agentic-workflows/with-agentpacks@v1
gh aw add svennijhuis/agentic-workflows/squad-review@v1
```

That copies the Markdown into `.github/workflows/`, compiles a `.lock.yml`, and records `source:` so later `gh aw update` can merge upstream changes.

Commit both the `.md` and the generated `.lock.yml`. Enable GitHub Actions in the consuming repo.

Full consumer guide: [docs/CONSUMING.md](docs/CONSUMING.md).

## Import shared fragments without installing a whole workflow

In a local workflow’s frontmatter:

```yaml
imports:
  - svennijhuis/agentic-workflows/workflows/shared/org-defaults.md@v1
  - svennijhuis/agentic-workflows/workflows/shared/security.md@v1
  - svennijhuis/agentic-workflows/workflows/shared/agentpacks.md@v1
```

## Layout

| Path | Role |
| --- | --- |
| [`aw.yml`](aw.yml) | Package manifest `gh aw add` reads |
| [`workflows/*.md`](workflows/) | Installable templates (have `on:`) |
| [`workflows/shared/`](workflows/shared/) | Importable fragments (no `on:`) |
| [`.github/workflows/`](.github/workflows/) | Control-plane jobs that run **in this repo only** |
| [`docs/`](docs/) | How consumption, packing, and governance work |
| [`governance/`](governance/) | Example org `GH_AW_DEFAULT_*` variables |
| [`.github/workflows/validate-catalog.yml`](.github/workflows/validate-catalog.yml) | CI: `gh aw compile --dir workflows --no-emit` |

## Versioning

| Ref | When to use |
| --- | --- |
| `@v1.2.0` | Production pin |
| `@v1` | Follow the current major |
| `@main` | Catalog development only |
| SHA | Audit / incident freeze |

Keep this repository **private or internal** so only org members can install. Use `private: true` only on workflows that must **not** be `gh aw add`-able (control-plane jobs in `.github/workflows/`). Catalog templates under `workflows/` stay installable.

## Related repos

| Repo | Use it for |
| --- | --- |
| [svennijhuis/agentPacks](https://github.com/svennijhuis/agentPacks) | Cursor / Copilot CLI / Claude / Codex plugins (`squad`, `git`, language packs) |
| [svennijhuis/mcp-services](https://github.com/svennijhuis/mcp-services) | MCP servers (filesystem, roslyn, index, …) |
| [githubnext/agentics](https://github.com/githubnext/agentics) | Public starter workflows to remix into this catalog |

## Docs

- [How it works](docs/HOW-IT-WORKS.md)
- [Use this catalog from other repos](docs/CONSUMING.md)
- [Reuse agentPacks and mcp-services](docs/AGENTPACKS.md)
- [Squad review on Actions](docs/SQUAD-REVIEW.md)
- [Governance and org defaults](docs/GOVERNANCE.md)
- [Control plane (later)](docs/CONTROL-PLANE.md)
- [Contributing](CONTRIBUTING.md)

Official references: [Using at Scale](https://github.github.com/gh-aw/guides/using-at-scale/), [Sharing Workflows](https://github.github.com/gh-aw/practices/sharing-workflows/).
