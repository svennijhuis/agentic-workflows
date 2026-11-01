# Changelog

All notable catalog changes are listed here. Consumer upgrades should read notes before `gh aw update`.

## Unreleased

- Block 1 layout and the `make verify` gate (`gh aw compile --strict` plus POL25 and POL31), like githubnext/agentics.
- Pins: gh-aw **v0.93.4**, Copilot engine **1.0.101** (`.github/aw.json`).
- Shared fragments under `workflows/shared/` (`defaults.md`, `security.md`, `reporting.md`, `agentpacks.md`).
- Repo policies: only POL25 (agentic workflows are `workflow_dispatch` only) and POL31 (no `skills:` in a shared fragment), with fixtures.
- `squad-review` catalog workflow: `workflow_dispatch` only; committed lock file.
