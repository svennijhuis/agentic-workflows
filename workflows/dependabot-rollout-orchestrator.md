---
description: Dependabot rollout orchestrator (gallery CentralRepoOps). Picks target repos and dispatches the worker per repo. Manual only.
on:
  workflow_dispatch:
    inputs:
      repos:
        description: Comma separated owner/repo list (svennijhuis repos only)
        required: true
        type: string
permissions:
  contents: read
tools:
  github:
    github-token: ${{ secrets.GH_AW_READ_ORG_TOKEN }}
    toolsets: [repos]
safe-outputs:
  dispatch-workflow:
    workflows: [dependabot-rollout]
    max: 5
---

# Dependabot Rollout Orchestrator

Source: [gallery Dependabot Rollout](https://github.github.com/gh-aw/gallery/multi-repo/dependabot-rollout/).

**Target repos**: `${{ github.event.inputs.repos }}`. Only repos owned by `svennijhuis`. Skip any other owner.

## Task

1. **Filter**: check each repo for `.github/dependabot.yml`. Keep only repos without it.
2. **Categorize**: simple (one manifest, under 50 deps), complex (many manifests or ecosystems), conflicting (Renovate config or custom update scripts), security (open alerts).
3. **Prioritize**: simple, then security, then complex, then conflicting.
4. **Dispatch**: dispatch the `dependabot-rollout` worker with `target_repo` for each selected repo (max 5).
5. **Summarize**: candidates, categories, selected repos with a short reason.
