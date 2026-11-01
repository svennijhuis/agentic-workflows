# Agentic workflows catalog

Org source of truth for [GitHub Agentic Workflows](https://github.github.com/gh-aw/). Consumer repos install templates with `gh aw add`; they do not copy-paste Markdown.

Same gate shape as [githubnext/agentics](https://github.com/githubnext/agentics): strict compile, then two repo policy checks.

## What it is

Markdown workflows under `workflows/` compile to `.lock.yml` in consumer repos. Security (permissions, network, caps, triggers) is declared in each workflow's frontmatter. Shared fragments live in `workflows/shared/`.

## Layout

| Path | Role |
| --- | --- |
| [`aw.yml`](aw.yml) | Package manifest for `gh aw add` |
| [`workflows/`](workflows/) | Installable templates (`on:` required) |
| [`workflows/shared/`](workflows/shared/) | Importable fragments (no `on:`) |
| [`policies/`](policies/) | POL25 and POL31 |
| [`Makefile`](Makefile) | `make compile`, `make verify` |
| [`.github/workflows/verify.yml`](.github/workflows/verify.yml) | Manual CI: `make verify` plus gitleaks |
| [`.github/aw.json`](.github/aw.json) | gh-aw and engine pins |

Details: [docs/reference/layout.md](docs/reference/layout.md).

## Gate (contributors)

```bash
make install   # once: pinned gh-aw v0.93.4
make compile   # gh aw compile --strict
make verify    # compile, then POL25 and POL31 on repo and fixtures
```

Last line must be `0 failures`. Q0: Actions billing blocked; attach this log on the PR commit SHA. [docs/how-to/verify-workflow.md](docs/how-to/verify-workflow.md).

## Consume

```bash
gh extension install github/gh-aw
gh aw init    # in the consumer repo
gh aw add svennijhuis/agentic-workflows/squad-review@v1.0.0
```

Full guide: [docs/how-to/consume.md](docs/how-to/consume.md). Pin tags or SHAs in production, never a branch ref.

## Docs

- [AGENTS.md](AGENTS.md)
- [docs/README.md](docs/README.md)
- [how-it-works](docs/explanation/how-it-works.md)

Official: [Using at Scale](https://github.github.com/gh-aw/guides/using-at-scale/), [Sharing Workflows](https://github.github.com/gh-aw/practices/sharing-workflows/).
