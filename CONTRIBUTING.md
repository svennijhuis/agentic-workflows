# Contributing to the catalog

## Add an installable workflow

1. Create `workflows/<name>.md` with frontmatter (`on`, `engine`) and a prompt body. Do **not** set `private: true` on catalog templates — that blocks `gh aw add` entirely. Org-only sharing comes from this repo being private/internal.
2. Import fragments from `workflows/shared/` instead of repeating tools/network/plugins.
3. List the file in [`aw.yml`](aw.yml) `includes:`.
4. Link it from [`workflows/README.md`](workflows/README.md) and the root README if it is meant for consumers.
5. Validate with `gh aw compile --dir workflows --no-emit` (CI runs the same command). Do not commit `.lock.yml` for catalog templates; consumers compile after `gh aw add`.

Name files in kebab-case. `gh aw add owner/repo/<name>` looks up `<name>` under `workflows/`.

## Add a shared fragment

1. Create `workflows/shared/<name>.md` **without** `on:`.
2. Only put mergeable fields (tools, network, mcp-servers, plugins, safe-outputs, steps, …). See [Imports](https://github.github.com/gh-aw/reference/imports/).
3. Document who should import it.

## Reuse, do not copy

- Agent plugins and skills → [`docs/AGENTPACKS.md`](docs/AGENTPACKS.md)
- MCP servers → `workflows/shared/mcp/` pointing at mcp-services
- Public starters → remix from [githubnext/agentics](https://github.com/githubnext/agentics), then land the org-specific version here

## Review bar

- Triggers and permissions are least privilege.
- `safe-outputs` have `max:` set.
- Cross-repo fields name `allowed-repos` / tokens.
- No secrets in Markdown. No hardcoded product repo names unless parameterized.
- `private: true` only for non-installable control-plane workflows.

## Release

Tag the catalog when consumers should pin (`git tag v0.1.0 && git push origin v0.1.0`). Moving major refs (`v1`) are optional.
