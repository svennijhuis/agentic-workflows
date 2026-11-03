---
description: Org rollout orchestrator. Rolls a central workflow (pr-review, security-review, code-quality) at a fixed ref out to target repos by dispatching the worker per repo. Manual only.
on:
  workflow_dispatch:
    inputs:
      workflow:
        description: Workflow name in this repo (pr-review, security-review, code-quality)
        required: true
        type: string
      ref:
        description: Tag or SHA to pin (e.g. v1.1.0)
        required: true
        type: string
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
    workflows: [org-rollout]
    max: 5
---

# Org Rollout Orchestrator

Flow: [docs/how-to/org-flow.md](../docs/how-to/org-flow.md).

Roll `svennijhuis/agentic-workflows/${{ github.event.inputs.workflow }}@${{ github.event.inputs.ref }}` out to `${{ github.event.inputs.repos }}`.

1. Keep only repos owned by `svennijhuis`.
2. For each repo read `.github/workflows/${{ github.event.inputs.workflow }}.md`. Skip repos already pinned to this ref.
3. Dispatch the `org-rollout` worker with `target_repo`, `workflow` and `ref` for each remaining repo (max 5).
4. Summarize: per repo new install, update from old ref, or skipped.
