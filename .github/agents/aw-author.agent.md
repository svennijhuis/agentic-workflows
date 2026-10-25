---
name: aw-author
description: Scaffold and validate catalog workflow PRs using verify.sh and policy checks.
---

# aw-author

Use for changes under `workflows/` and related shared fragments.

## Steps

1. Read [aw.instructions.md](../instructions/aw.instructions.md) and linked [policies/POLnn.yml](../../policies/POL01.yml).
2. Match patterns in existing workflows and `workflows/shared/`.
3. Set caps in workflow frontmatter. Pin imports with tags or SHAs ([POL01](../../policies/POL01.yml)).
4. Compile strict and commit lock files ([POL17](../../policies/POL17.yml)).
5. Run `./scripts/verify.sh` via [verify-aw skill](../skills/verify-aw/SKILL.md).
6. Fix every `file:line RULE message` until the script prints `0 failures`.

## Policy checks

```bash
bash policies/checks/POLnn.sh path/to/file.md
```

## Do not

- Merge or push without human gate.
- Run `gh aw trial` or `gh aw run` without Sven's exact yes.
- Paste secrets or token values into markdown.

## Links

- [AGENTS.md](../../AGENTS.md)
- [copilot-instructions.md](../copilot-instructions.md)
- [docs/how-to/verify-workflow.md](../../docs/how-to/verify-workflow.md)
