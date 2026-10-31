# squad-review (legacy)

[`workflows/squad-review.md`](../../workflows/squad-review.md) is a thin Actions adapter until [F01](../pbi/agent-factory/F01-pr-review.md) replaces it. Review behaviour lives in [agentPacks](https://github.com/svennijhuis/agentPacks); this catalog pins imports only.

## Block 1 behaviour

- Trigger: `workflow_dispatch` only (no auto PR triggers until Sven enables them).
- Staged / report-only posture per [POL03](../../policies/POL03.yml).
- Caps in workflow frontmatter ([POL02](../../policies/POL02.yml)).
- Committed `squad-review.lock.yml` in the catalog ([POL17](../../policies/POL17.yml)).
- `copilot-requests: none` ([POL21](../../policies/POL21.yml)).
- agentPacks via `skills:` in `squad-review.md` frontmatter and a `commands/` import at a pinned SHA; not `plugins:` at a main SHA ([agentpacks contract](agentpacks-contract.md)). `skills:` lives in this consumer workflow, not in `workflows/shared/` (gh-aw drops it from imports; C12b, [POL31](../../policies/POL31.yml)).

Shared wiring: [`workflows/shared/agentpacks.md`](../../workflows/shared/agentpacks.md), [`defaults.md`](../../workflows/shared/defaults.md), [`security.md`](../../workflows/shared/security.md).

## Copy this

An org copies `workflows/squad-review.md`, `workflows/squad-review.lock.yml` and `workflows/shared/`. The pinned squad skill comes with the md (its `skills:` key); nothing in `workflows/shared/` installs a skill.

## Install in a consumer repo

```bash
gh extension install github/gh-aw
gh aw init
gh aw add svennijhuis/agentic-workflows/squad-review@v1.0.0
git add .github/workflows/squad-review.md .github/workflows/squad-review.lock.yml
```

Run from the Actions tab (`workflow_dispatch`). Set `COPILOT_GITHUB_TOKEN` per [auth.md](auth.md).

## Change review behaviour

Edit agentPacks, release a C12 tag, bump pin in this catalog, recompile, run `./scripts/verify.sh`. Do not fork the command text here.

## Removal

See [layout.md](layout.md) post-F01 path list.
