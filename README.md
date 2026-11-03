# Agentic workflows

Library of [GitHub Agentic Workflows](https://github.github.com/gh-aw/) by svennijhuis. Other repos install them with `gh aw add`, then compile in their own repo.

| Path | Role |
| --- | --- |
| [`aw.yml`](aw.yml) | Package manifest for `gh aw add` |
| [`workflows/`](workflows/) | Installable workflows, flows and diagrams in [workflows/README.md](workflows/README.md) |
| [`workflows/shared/`](workflows/shared/) | Importable fragments, including local skill copies in [`shared/skills/`](workflows/shared/skills/) |

## Validate

The compiler checks `dispatch-workflow` targets in `.github/workflows/`, so validate in a scratch repo with that layout:

```bash
gh extension install github/gh-aw --pin v0.93.4
T=$(mktemp -d) && mkdir -p "$T/.github/workflows" "$T/.github/aw" && cp -R workflows/. "$T/.github/workflows/" && cp .github/aw/actions-lock.json "$T/.github/aw/" && (cd "$T" && git init -q && gh aw compile --no-emit)
```

## Install

In a target repo:

```bash
gh aw add svennijhuis/agentic-workflows/workflows/<name>.md@<tag>
gh aw compile
```
