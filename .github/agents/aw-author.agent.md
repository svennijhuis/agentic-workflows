---
name: aw-author
description: Scaffold and validate catalog workflow PRs using make verify and gh aw compile --strict.
---

# aw-author

Use for changes under `workflows/` and related shared fragments.

## Steps

1. Read [aw.instructions.md](../instructions/aw.instructions.md) and [POL25](../../policies/POL25.yml), [POL31](../../policies/POL31.yml).
2. Match patterns in existing workflows and `workflows/shared/`.
3. Set caps, permissions, and network in workflow frontmatter. Pin imports with tags or SHAs.
4. Run `make compile` and commit lock files.
5. Run `make verify` via [verify-aw skill](../skills/verify-aw/SKILL.md).
6. Fix every `file:line RULE message` until the script prints `0 failures`.

## Policy checks

```bash
bash policies/checks/POL25.sh path/to/tree
bash policies/checks/POL31.sh path/to/tree
```

## Do not

- Merge or push without human gate.
- Run `gh aw trial` or `gh aw run` without Sven's exact yes.
- Paste secrets or token values into markdown.

## Links

- [AGENTS.md](../../AGENTS.md)
- [copilot-instructions.md](../copilot-instructions.md)
- [docs/how-to/verify-workflow.md](../../docs/how-to/verify-workflow.md)
