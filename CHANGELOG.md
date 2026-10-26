# Changelog

All notable catalog changes are listed here. Consumer upgrades should read notes before `gh aw update`.

## Unreleased

- Block 1 layout, guardrails, and `scripts/verify.sh` gate.
- Pins: gh-aw **v0.93.5**, Copilot engine **1.0.101** (`.github/aw.json`).
- Compiler bump v0.93.4 to v0.93.5. Copilot engine stays 1.0.101. Recompiled locks pick up the patched `gh-aw-node` image.
- Shared fragments under `workflows/shared/` (`defaults.md`, `security.md`, `reporting.md`, `agentpacks.md`).
- Policies POL01 through POL23 with fixtures.
- `squad-review` catalog workflow: `workflow_dispatch` only; committed lock file.
