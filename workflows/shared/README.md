# Shared fragments

Not installed alone. No `on:` field. Catalog workflows and consumers import them:

```yaml
imports:
  - shared/defaults.md
  - svennijhuis/agentic-workflows/workflows/shared/defaults.md@v1.0.0
```

gh-aw v0.93.4 requires shared files under `workflows/shared/` (imports outside `workflows/` fail compile).

## Fragments

| File | Use |
| --- | --- |
| [defaults.md](defaults.md) | Pinned engine, imported by every workflow. No tools: each workflow sets `github: mode: gh-proxy` with its own toolsets |
| [security.md](security.md) | Network and safety baseline |
| [reporting.md](reporting.md) | Fixed issue/PR report shape |
| [skills/](skills/) | Local skill copies (mattpocock/skills, cursor/plugins), imported by builder, reviewer, retro, wf-spec, wf-plan. Source and SHA on top of each file |
| [has-work.md](has-work.md) | Pre-agent step: `noop` without starting the engine when no open issue carries the labels the workflow needs |

Configure consumers with `import-schema` `with:` only; unknown keys fail compile.

Caps are **not** importable; set them in each workflow frontmatter. No `skills:` in shared fragments: gh-aw drops it from imports. Skills come in as imported markdown from [skills/](skills/).
