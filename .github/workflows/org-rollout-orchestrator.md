---
description: Org rollout orchestrator. Rolls a central workflow (pr-review, security-review) at a fixed ref out to target repos by dispatching the worker per repo. Manual only.
on:
  workflow_dispatch:
    inputs:
      workflow:
        description: Workflow name in this repo (pr-review, security-review)
        required: true
        type: string
      ref:
        description: Tag or SHA to pin (e.g. v1.1.0)
        required: true
        type: string
      repos:
        description: Comma separated owner/repo list (svennijhuis only). Empty = find all svennijhuis repos that have the workflow
        required: false
        default: ""
        type: string
      only_existing:
        description: Only update repos that already have the workflow (no new installs)
        required: false
        type: boolean
        default: true
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

Flow: [docs/how-to/org-flow.md](../../docs/how-to/org-flow.md).

Roll `svennijhuis/agentic-workflows/${{ github.event.inputs.workflow }}@${{ github.event.inputs.ref }}` out to the target repos.

1. Targets: `repos` is `${{ github.event.inputs.repos }}`. When it is empty, list all repos of the `svennijhuis` user (skip archived and forks) and keep those that have `.github/workflows/${{ github.event.inputs.workflow }}.md`. Keep only repos owned by `svennijhuis` in both cases. Never this control repo.
2. For each repo read `.github/workflows/${{ github.event.inputs.workflow }}.md`. Skip repos already pinned to this ref. `only_existing` is `${{ github.event.inputs.only_existing }}`: when `true`, also skip repos without that file, so only repos that already have the workflow get an update PR. When `false`, repos without it get a new install PR.
3. Dispatch the `org-rollout` worker with `target_repo`, `workflow` and `ref` for each remaining repo (max 5).
4. Summarize: per repo new install, update from old ref, or skipped.
