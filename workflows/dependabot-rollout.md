---
description: Dependabot rollout worker. Checks out one target repo and opens a customized dependabot.yml PR, or an issue on conflict. Dispatched by the orchestrator.
on:
  workflow_dispatch:
    inputs:
      target_repo:
        description: Target repository (owner/repo)
        required: true
        type: string
run-name: Dependabot rollout for ${{ github.event.inputs.target_repo }}
concurrency:
  group: gh-aw-${{ github.workflow }}-${{ github.event.inputs.target_repo }}
checkout:
  repository: ${{ github.event.inputs.target_repo }}
  github-token: ${{ secrets.ORG_REPO_CHECKOUT_TOKEN }}
  current: true
permissions:
  contents: read
  issues: read
  pull-requests: read
tools:
  github:
    github-token: ${{ secrets.GH_AW_READ_ORG_TOKEN }}
    toolsets: [repos]
safe-outputs:
  github-token: ${{ secrets.GH_AW_CROSS_REPO_PAT }}
  create-pull-request:
    target-repo: ${{ github.event.inputs.target_repo }}
    title-prefix: "[dependabot] "
    max: 1
  create-issue:
    target-repo: ${{ github.event.inputs.target_repo }}
    title-prefix: "[dependabot-config] "
    max: 1
---

# Customized Dependabot Configuration

Source: [gallery Dependabot Rollout](https://github.github.com/gh-aw/gallery/multi-repo/dependabot-rollout/).

**Target repository**: `${{ github.event.inputs.target_repo }}`. Stop if the owner is not `svennijhuis`.

## Step 1: Analyze

- `.github/dependabot.yml` exists: stop, open an issue saying so.
- Renovate config or custom update scripts: open an issue with a migration proposal and the proposed config.
- Detect ecosystems: npm (`package.json`, count deps, monorepo), Python, Go, NuGet, GitHub Actions (`.github/workflows/*.yml`).
- Check open security alerts. Critical alerts mean security updates come first.

## Step 2: Build the config

- Simple repo: daily for the main ecosystem, weekly for `github-actions`.
- Complex repo or alerts: weekly, with groups for production and dev dependencies.
- Monorepo: one entry per package directory.

## Step 3: Deliver

- Normal case: PR adding `.github/dependabot.yml`, titled "Add customized Dependabot configuration". Body explains dependency count, interval choice and grouping.
- No supported package manager: issue "No supported package managers detected".
