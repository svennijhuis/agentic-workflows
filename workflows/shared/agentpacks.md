---
description: Load org Agent Plugins from svennijhuis/agentPacks. Do not copy plugin files into this catalog.
plugins:
  - svennijhuis/agentPacks/plugins/git@marketplace
---

This fragment only pulls the `git` guard pack, which is safe for unattended Actions.

Add language packs on the **importing** workflow when the target repo’s stack is known:

```yaml
plugins:
  - svennijhuis/agentPacks/plugins/dotnet@marketplace
  - svennijhuis/agentPacks/plugins/typescript@marketplace
  - svennijhuis/agentPacks/plugins/rust@marketplace
```

Prefer the `marketplace` branch (generated tree) or a SHA on that branch. See docs/AGENTPACKS.md.

For private clones, override with object form and `github-token` / `github-app` on the importer so checkout can read agentPacks.
