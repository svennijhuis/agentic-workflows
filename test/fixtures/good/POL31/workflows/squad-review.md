---
description: Consumer workflow fixture. skills lives here, in the main workflow.
on:
  workflow_dispatch:
skills:
  - svennijhuis/agentPacks/plugins/squad/skills/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684
imports:
  - shared/agentpacks.md
---

Good POL31 fixture: the main workflow pins the skill, the shared fragment does not.
