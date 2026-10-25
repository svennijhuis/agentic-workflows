# Contributing to the catalog

## Add an installable workflow

1. Create `workflows/<name>.md` with frontmatter (`on`, `engine`) and prompt body. Do not set `private: true` on catalog templates.
2. Set cost caps in **this file's** frontmatter: `max-ai-credits`, `max-daily-ai-credits`, `max-turns`, `timeout-minutes` ([POL02](policies/POL02.yml)).
3. Use `workflow_dispatch` only until Sven's yes enables other triggers.
4. Use staged or report-only posture first ([POL03](policies/POL03.yml)).
5. Import from `workflows/shared/` with pinned refs ([POL01](policies/POL01.yml)).
6. List the file in [`aw.yml`](aw.yml) `includes:`.
7. `gh aw compile --dir workflows --strict --actionlint`, then **commit** `workflows/<name>.lock.yml` ([POL17](policies/POL17.yml)).
8. Link from [`workflows/README.md`](workflows/README.md) and root README when consumers should install it.
9. Run `./scripts/verify.sh` (must print `0 failures`).

Kebab-case names match `gh aw add svennijhuis/agentic-workflows/<name>`.

## Add a shared fragment

1. Create `workflows/shared/<name>.md` without `on:`.
2. Add `import-schema` when consumers need typed `with:` inputs ([C05](docs/pbi/done/C05-imports-import-schema.md)).
3. Document importers in `workflows/shared/README.md`.

## Reuse, do not copy

- agentPacks: [docs/reference/agentpacks-contract.md](docs/reference/agentpacks-contract.md)
- MCP: `workflows/shared/mcp/` pointing at mcp-services
- Public starters: remix from [githubnext/agentics](https://github.com/githubnext/agentics), then land org-specific versions here

## Review bar

Link [policies/POL01.yml](policies/POL01.yml) through [POL23](policies/POL23.yml). Bar H checklist: [docs/pbi/README.md#bar-h-every-workflow-pbi](docs/pbi/README.md#bar-h-every-workflow-pbi).

## Q0: verify log as CI

GitHub Actions billing is blocked. Attach the full `./scripts/verify.sh` output for the **exact PR commit SHA** as a PR comment. Do not skip verify because CI is missing.

## Git

Never force push. Normal `git push` only when the human gate allows.

## Release

Tag when consumers should pin (`vX.Y.Z`). Record pins and notes in [CHANGELOG.md](CHANGELOG.md). See [docs/reference/pins.md](docs/reference/pins.md).
