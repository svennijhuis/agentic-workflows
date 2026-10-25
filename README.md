# Agentic workflows catalog

Org source of truth for [GitHub Agentic Workflows](https://github.github.com/gh-aw/). Consumer repos install templates with `gh aw add`; they do not copy-paste Markdown.

IDE plugins: [`agentPacks`](https://github.com/svennijhuis/agentPacks). MCP: [`mcp-services`](https://github.com/svennijhuis/mcp-services). Overview: [docs/explanation/how-it-works.md](docs/explanation/how-it-works.md).

Replace `svennijhuis` with the target org owner only at org switch ([docs/pbi/done/ARC06-org-switch.md](docs/pbi/done/ARC06-org-switch.md)).

## Install into another repository

Prerequisites in the **consumer** repo:

```bash
gh extension install github/gh-aw
gh aw init
```

Add a catalog workflow (pin a tag in production):

```bash
gh aw add svennijhuis/agentic-workflows/squad-review@v1.0.0
```

Commit `.md` and `.lock.yml`. Full guide: [docs/how-to/consume.md](docs/how-to/consume.md).

## Import shared fragments

```yaml
imports:
  - svennijhuis/agentic-workflows/workflows/shared/defaults.md@v1.0.0
  - svennijhuis/agentic-workflows/workflows/shared/security.md@v1.0.0
  - svennijhuis/agentic-workflows/workflows/shared/agentpacks.md@v1.0.0
```

## Layout

| Path | Role |
| --- | --- |
| [`aw.yml`](aw.yml) | Package manifest for `gh aw add` |
| [`workflows/*.md`](workflows/) | Installable templates (`on:` required) |
| [`workflows/shared/`](workflows/shared/) | Importable fragments (no `on:`) |
| [`policies/`](policies/) | POL rules and check scripts |
| [`scripts/verify.sh`](scripts/verify.sh) | Local gate (see below) |
| [`.github/workflows/`](.github/workflows/) | Control-plane jobs in **this** repo only |
| [`docs/`](docs/) | Diataxis docs |
| [`governance/`](governance/) | Rollout ladder, proposed rulesets |
| [`.github/aw.json`](.github/aw.json) | gh-aw and engine pins |

Details: [docs/reference/layout.md](docs/reference/layout.md).

## Verify (contributors)

```bash
./scripts/verify.sh
```

Must end with `0 failures`. Q0: Actions billing blocked; attach this log on the PR commit SHA. [docs/how-to/verify-workflow.md](docs/how-to/verify-workflow.md).

## Versioning

| Ref | When to use |
| --- | --- |
| `@v1.0.0` (exact tag) | Production pin |
| `@v1` | Moving major after Block 2 tag policy |
| SHA | Audit / incident freeze |
| `@main` | Never in production; [POL01](policies/POL01.yml) rejects it |

Keep the catalog **private or internal**. Catalog templates under `workflows/` stay installable (`private: true` blocks `gh aw add`).

## Docs

- [docs/README.md](docs/README.md) (index)
- [AGENTS.md](AGENTS.md)
- [Consume](docs/how-to/consume.md)
- [agentPacks contract](docs/reference/agentpacks-contract.md)
- [squad-review](docs/reference/squad-review.md)
- [Governance](docs/explanation/governance.md)
- [Contributing](CONTRIBUTING.md)
- PBI backlog: [docs/pbi/README.md](docs/pbi/README.md)

Official: [Using at Scale](https://github.github.com/gh-aw/guides/using-at-scale/), [Sharing Workflows](https://github.github.com/gh-aw/practices/sharing-workflows/).
