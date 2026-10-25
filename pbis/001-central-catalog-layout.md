# 001 Central catalog layout

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Done | Platform | none |

## Context

One catalog repo, installable workflows in `workflows/`, fragments in `workflows/shared/` (no `on:`), manifest `aw.yml`. Relative imports resolve from the importing workflow dir, so fragments must stay at `workflows/shared/`.

## Sources

- https://github.github.com/gh-aw/guides/sharing-workflows/
- https://github.github.com/gh-aw/reference/imports/
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/guides/using-at-scale/

## Design

```text
aw.yml  README.md  CHANGELOG.md  CONTRIBUTING.md
docs/ CONSUMING.md GOVERNANCE.md AGENTPACKS.md
pbis/ README.md NNN-*.md
workflows/
  pr-review.md  pr-review.lock.yml
  shared/ defaults.md security.md agentpacks.md
          standards/{common,dotnet,typescript,rust}.md
          prompts/README.md  mcp/README.md
```
```yaml
# aw.yml
manifest-version: "1"
name: Agentic Workflows
description: Catalog of installable GitHub Agentic Workflows and shared fragments.
includes:
  - workflows/pr-review.md
```

## Code example

```bash
gh aw add svennijhuis/agentic-workflows/pr-review@v1.0.0
gh aw update pr-review
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Manifest validates during compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded, 1 warning |
| 2 | Old docs folded, none left | `ls docs` | AGENTPACKS.md  CONSUMING.md  GOVERNANCE.md |
| 3 | No governance/ folder | `test -d governance; echo $?` | 1 |
| 4 | Fragments have no on: | `rg -l '^on:' workflows/shared` | no output |

## Evidence

`gh aw compile --dir workflows --strict` gives `✓ workflows/pr-review.md (159.4 KB)` and `Compiled 1 workflow: 1 succeeded, 1 warning` (warning = experimental `plugins`).

## Non-goals

No control plane yet (see 086). No `.github/workflows/` agentic jobs in this repo.

## Risks

`aw.yml` is not in the official spec pages read; `gh aw compile` validates it, which is the check we rely on.

## Post-merge

See PR #2 post-merge list: tag v1.0.0 + v1, set COPILOT_GITHUB_TOKEN, decide visibility.
