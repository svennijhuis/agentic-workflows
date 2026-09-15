---
description: agentPacks squad + git + language packs for Actions review workflows.
plugins:
  - svennijhuis/agentPacks/plugins/git@marketplace
  - svennijhuis/agentPacks/plugins/squad@marketplace
  - svennijhuis/agentPacks/plugins/dotnet@marketplace
  - svennijhuis/agentPacks/plugins/typescript@marketplace
  - svennijhuis/agentPacks/plugins/rust@marketplace
---

Installs the same plugins a developer uses in the IDE. Do not copy SKILL.md from agentPacks into this catalog.

The `squad` plugin supplies `/squad-review` agents (`squad-reviewer`, `squad-simplifier`, `squad-security-reviewer`, `squad-orchestrator`) and the review contract. Language packs supply `<lang>-review` and related loop skills. Load only the language skills that match the diff.

Prefer `@marketplace` (generated tree) or a SHA on that branch.
