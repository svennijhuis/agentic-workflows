# Contributing

## New workflow

1. `workflows/<name>.md`: kebab-case, job named (`pr-review`, `ci-doctor`). Never equal to an agentPacks skill name.
2. Import `shared/defaults.md` + `shared/security.md`. Add only agentPacks imports that change the output.
3. Cost caps in frontmatter: `max-ai-credits: 50`, `max-daily-ai-credits: 200`, `max-turns: 15`, `timeout-minutes: 10`.
4. Copilot: `copilot-requests: none` + secret `COPILOT_GITHUB_TOKEN`.
5. Add to `aw.yml`, `workflows/README.md`, root README table, `CHANGELOG.md`.
6. `gh aw compile --dir workflows`, commit `.md` + `.lock.yml` (review evidence; consumers recompile on `gh aw add`).

## New fragment

`workflows/shared/<name>.md` without `on:`. Mergeable fields only (tools, network, mcp-servers, plugins, skills, imports, safe-outputs, steps). See [Imports](https://github.github.com/gh-aw/reference/imports/).

## Review bar

Least-privilege triggers and permissions. `safe-outputs` have `max:`. No secrets or tokens in any file; name the secret only. Refs pinned. `private: true` only for control-plane jobs.

## Release

See [CHANGELOG](CHANGELOG.md).
