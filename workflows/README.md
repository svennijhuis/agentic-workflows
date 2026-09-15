# Installable workflows

Markdown in this directory is what other repositories install:

```bash
gh aw add svennijhuis/agentic-workflows/<file-stem>@v1
```

Each file **must** have an `on:` trigger. Keep names kebab-case; they become the `gh aw add` identifier.

| Workflow | Status | Purpose |
| --- | --- | --- |
| [hello-org.md](hello-org.md) | Example | Smoke-test install + `workflow_dispatch` |
| [with-agentpacks.md](with-agentpacks.md) | Example | Same, plus `plugins:` from agentPacks |

Add rows here when you land real templates (issue triage, CI doctor, policy rollout, …). Remix from [githubnext/agentics](https://github.com/githubnext/agentics) rather than inventing from scratch.

Shared fragments: [shared/](shared/).
