---
description: Import agentPacks squad (skill + plugin agents) and language packs. Do not copy SKILL.md or agent files into this catalog.
skills:
  - svennijhuis/agentPacks/plugins/squad/skills/squad@marketplace
plugins:
  - svennijhuis/agentPacks/plugins/git@marketplace
  - svennijhuis/agentPacks/plugins/squad@marketplace
  - svennijhuis/agentPacks/plugins/dotnet@marketplace
  - svennijhuis/agentPacks/plugins/typescript@marketplace
  - svennijhuis/agentPacks/plugins/rust@marketplace
---

`skills:` installs the `squad` skill into the activation job (it is `disable-model-invocation`, so it will not self-load). `plugins:` installs the same marketplace packs a developer uses in the IDE, which is how **agents** (`squad-reviewer`, `squad-simplifier`, `squad-security-reviewer`, `squad-orchestrator`) arrive — gh-aw agent-file imports only accept `.github/agents/`, which agentPacks does not use.

Do not also paste those skills or agents into `workflows/shared/prompts/` or inline `## agent:` blocks.
