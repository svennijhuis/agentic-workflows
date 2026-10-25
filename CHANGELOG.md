# Changelog

Tags: exact `vX.Y.Z` per release (immutable), plus moving major `v1` pointed at the latest `v1.*`. Consumers pin `@vX.Y.Z` (or SHA); `@v1` follows the major on `gh aw update`.

## Unreleased (target v1.0.0)

- Layout: `workflows/`, `workflows/shared/`, `docs/CONSUMING.md`, `docs/GOVERNANCE.md`, `pbis/`.
- Rename `squad-review` to `pr-review` (slash command `/pr-review`).
- Rename `shared/org-defaults.md` to `shared/defaults.md`, `shared/squad.md` to `shared/agentpacks.md`.
- agentPacks pinned to SHA `34e1dec` (was branch `@marketplace`). Only squad skill, squad plugin, review command and review standards imported.
- New `shared/standards/{common,dotnet,typescript,rust}.md`: agentPacks review standards by path@SHA.
- Cost caps on `pr-review`: 50 AIC/run, 200 AIC/day, 15 turns, 10 min.
- Copilot auth: `copilot-requests: none`, uses secret `COPILOT_GITHUB_TOKEN`.

Post-merge: `git tag v1.0.0 && git tag v1 && git push origin v1.0.0 v1`. Later majors: `git tag -f v1 <sha> && git push -f origin v1` only moves the major tag, never a branch.
