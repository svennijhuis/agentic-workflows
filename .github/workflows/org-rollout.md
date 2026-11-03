---
description: Org rollout worker. Opens one PR in the target repo that adds or bumps a central workflow pin. Dispatched by the orchestrator.
on:
  workflow_dispatch:
    inputs:
      target_repo:
        description: Target repository (owner/repo)
        required: true
        type: string
      workflow:
        description: Workflow name
        required: true
        type: string
      ref:
        description: Tag or SHA to pin
        required: true
        type: string
run-name: Rollout ${{ github.event.inputs.workflow }}@${{ github.event.inputs.ref }} to ${{ github.event.inputs.target_repo }}
concurrency:
  group: gh-aw-${{ github.workflow }}-${{ github.event.inputs.target_repo }}
checkout:
  repository: ${{ github.event.inputs.target_repo }}
  github-token: ${{ secrets.ORG_REPO_CHECKOUT_TOKEN }}
  current: true
permissions:
  contents: read
steps:
  - name: Install gh-aw
    run: gh extension install github/gh-aw --pin v0.93.4
    env:
      GH_TOKEN: ${{ github.token }}
tools:
  bash: ["gh aw compile *", "git status", "git diff *", "cat *", "ls *"]
  edit:
  github:
    github-token: ${{ secrets.GH_AW_READ_ORG_TOKEN }}
    toolsets: [repos]
safe-outputs:
  github-token: ${{ secrets.GH_AW_CROSS_REPO_PAT }}
  create-pull-request:
    target-repo: ${{ github.event.inputs.target_repo }}
    title-prefix: "[agentic-workflows] "
    max: 1
    protected-files:
      policy: request-review
      exclude: [".github/workflows/"]
---

# Org Rollout Worker

Flow: [docs/how-to/org-flow.md](../../docs/how-to/org-flow.md).

Stop if the owner of `${{ github.event.inputs.target_repo }}` is not `svennijhuis`.

1. Fetch `workflows/${{ github.event.inputs.workflow }}.md` from `svennijhuis/agentic-workflows` at `${{ github.event.inputs.ref }}`.
2. Write it to `.github/workflows/${{ github.event.inputs.workflow }}.md` in the target repo with `source: svennijhuis/agentic-workflows/workflows/${{ github.event.inputs.workflow }}.md@${{ github.event.inputs.ref }}` in the frontmatter, so `gh aw update` keeps working.
3. Run `gh aw compile ${{ github.event.inputs.workflow }}` in the target repo, so `.github/workflows/${{ github.event.inputs.workflow }}.lock.yml` is generated. Stop and report the error if compile fails; open no PR then.
4. Open one PR titled "${{ github.event.inputs.workflow }} @ ${{ github.event.inputs.ref }}" with both the `.md` and the `.lock.yml`. Body: old ref (or new install), new ref, link to the changelog, and the rollback line from docs/how-to/org-flow.md. The maintainer only reviews and merges.
