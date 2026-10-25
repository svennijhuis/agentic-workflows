# Installable workflows

Markdown here is what other repositories install:

```bash
gh aw add svennijhuis/agentic-workflows/<file-stem>@v1.0.0
```

Each file **must** have an `on:` trigger. Kebab-case stem becomes the `gh aw add` id.

Block 1: catalog workflows are **`workflow_dispatch` only** until Sven enables more. Each workflow sets its own cost caps in frontmatter ([POL02](../policies/POL02.yml)). Commit `.lock.yml` next to each `.md` ([POL17](../policies/POL17.yml)).

| Workflow | Purpose |
| --- | --- |
| [squad-review.md](squad-review.md) | Legacy PR review adapter (removed when F01 ships) |

Shared fragments: [shared/](shared/). Authoring: [.github/instructions/aw.instructions.md](../.github/instructions/aw.instructions.md). Verify: `./scripts/verify.sh`.
