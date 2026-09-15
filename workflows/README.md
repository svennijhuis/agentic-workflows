# Installable workflows

Markdown in this directory is what other repositories install:

```bash
gh aw add svennijhuis/agentic-workflows/<file-stem>@v1
```

Each file **must** have an `on:` trigger. Keep names kebab-case; they become the `gh aw add` identifier.

| Workflow | Purpose |
| --- | --- |
| [squad-review.md](squad-review.md) | PR review using agentPacks `/squad-review` |

Shared fragments: [shared/](shared/).
