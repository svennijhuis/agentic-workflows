# agentic-workflows

Catalog of [GitHub Agentic Workflows](https://github.github.com/gh-aw/). Repos install from here with `gh aw add`; no copy-paste.

Skills, agents and standards live in [agentPacks](https://github.com/svennijhuis/agentPacks). MCP servers live in [mcp-services](https://github.com/svennijhuis/mcp-services). This repo only wires them into Actions.

## Install

```bash
gh extension install github/gh-aw
gh aw init
gh aw add svennijhuis/agentic-workflows/pr-review@v1.0.0
```

Commit `.md` + `.lock.yml`. Set secret `COPILOT_GITHUB_TOKEN` (fine-grained PAT, Copilot Requests: Read). More: [docs/CONSUMING.md](docs/CONSUMING.md).

## Layout

| Path | Role |
| --- | --- |
| `aw.yml` | Package manifest for `gh aw add` |
| `workflows/*.md` | Installable workflows (have `on:`) |
| `workflows/shared/` | Fragments, no `on:` (defaults, security, agentPacks, standards, prompts, mcp) |
| `docs/` | [CONSUMING](docs/CONSUMING.md), [GOVERNANCE](docs/GOVERNANCE.md), [AGENTPACKS](docs/AGENTPACKS.md) |
| `pbis/` | Backlog: [index](pbis/README.md), one strict PBI per file `NNN-slug.md` |
| `CHANGELOG.md` | Releases and tag scheme |

## Workflows

| Name | Does |
| --- | --- |
| [pr-review](workflows/pr-review.md) | Report-only PR review via agentPacks `/squad-review` + language standards |

## How it runs

`workflows/x.md` (frontmatter + prompt) compiles to `x.lock.yml`. Agent job is read-only; writes go through `safe-outputs` in a separate job. Every workflow sets low cost caps (see [GOVERNANCE](docs/GOVERNANCE.md#cost)).
