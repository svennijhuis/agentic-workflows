---
description: Example catalog workflow that loads org Agent Plugins at runtime.
intent: Show how Actions agents reuse svennijhuis/agentPacks instead of copying skills.
on:
  workflow_dispatch:
engine: copilot
imports:
  - shared/org-defaults.md
  - shared/security.md
  - shared/agentpacks.md
permissions:
  contents: read
  issues: read
  copilot-requests: write
---

# Catalog workflow with agentPacks

Same smoke-test rules as hello-org: inspect the repo, explain that plugins were loaded from `svennijhuis/agentPacks`, and make no writes.

If a language pack is present, you may mention which stack you detected. Do not run destructive git commands. Do not open issues or pull requests.

`plugins:` is experimental in gh-aw. If compile fails resolving `marketplace`, pin a commit SHA from https://github.com/svennijhuis/agentPacks/commits/marketplace instead.
