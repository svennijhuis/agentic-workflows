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
| [skills/](skills/) | Local skill copies (mattpocock/skills, cursor/plugins), imported by builder, reviewer, retro, wf-spec, wf-plan. `diagnosing-bugs` (mattpocock/skills) drives the builder's bug path. Source, commit and license in [Skill sources](#skill-sources) |
| [has-work.md](has-work.md) | Pre-agent step: `noop` without starting the engine when no open issue carries the labels the workflow needs |

Configure consumers with `import-schema` `with:` only; unknown keys fail compile.

Caps are **not** importable; set them in each workflow frontmatter. No `skills:` in shared fragments: gh-aw drops it from imports. Skills come in as imported markdown from [skills/](skills/).

## Skill sources

Each file in [skills/](skills/) is a local copy: upstream `SKILL.md` body verbatim, frontmatter dropped, headings one level down under `# Skill: <name>`. To update: copy the new body into the file, bump the SHA here.

| Skill | Source | Commit | License | Notes |
| --- | --- | --- | --- | --- |
| [code-review](skills/code-review/SKILL.md) | [mattpocock/skills/skills/engineering/code-review](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/code-review) | `4ae2317` | MIT License, Copyright (c) 2026 Matt Pocock |  |
| [deslop](skills/deslop/SKILL.md) | [cursor/plugins/cursor-team-kit/skills/deslop](https://github.com/cursor/plugins/tree/ae5650febf4320793844c12c4adaa937f417f8da/cursor-team-kit/skills/deslop) | `ae5650f` | no license file in source repo |  |
| [diagnosing-bugs](skills/diagnosing-bugs/SKILL.md) | [mattpocock/skills/skills/engineering/diagnosing-bugs](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/diagnosing-bugs) | `4ae2317` | MIT License, Copyright (c) 2026 Matt Pocock |  |
| [implement](skills/implement/SKILL.md) | [mattpocock/skills/skills/engineering/implement](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/implement) | `4ae2317` | MIT License, Copyright (c) 2026 Matt Pocock |  |
| [pr](skills/pr/SKILL.md) | [mattpocock/skills/skills/engineering/pr](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/pr) | `4ae2317` | MIT License, Copyright (c) 2026 Matt Pocock. Summary visuals credit Dex Horthy (Humanlayer, show-me skill) | CREDITS.md appended as sections. |
| [retro](skills/retro/SKILL.md) | [mattpocock/skills/skills/engineering/retro](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/retro) | `4ae2317` | MIT License, Copyright (c) 2026 Matt Pocock |  |
| [tdd](skills/tdd/SKILL.md) | [mattpocock/skills/skills/engineering/tdd](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/tdd) | `4ae2317` | MIT License, Copyright (c) 2026 Matt Pocock | tests.md, mocking.md appended as sections. |
| [to-spec](skills/to-spec/SKILL.md) | [mattpocock/skills/skills/engineering/to-spec](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/to-spec) | `4ae2317` | MIT License, Copyright (c) 2026 Matt Pocock |  |
| [to-tickets](skills/to-tickets/SKILL.md) | [mattpocock/skills/skills/engineering/to-tickets](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/to-tickets) | `4ae2317` | MIT License, Copyright (c) 2026 Matt Pocock |  |
| [writing-for-agents](skills/writing-for-agents/SKILL.md) | [mattpocock/skills/skills/productivity/writing-for-agents](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/productivity/writing-for-agents) | `4ae2317` | MIT License, Copyright (c) 2026 Matt Pocock | SKILL-MECHANICS.md appended as sections. |
