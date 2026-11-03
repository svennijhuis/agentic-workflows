---
description: Code quality monitoring from a side repo (gallery example). Checks out one target repo, runs linters, opens prioritized issues there. Manual only.
on:
  workflow_dispatch:
    inputs:
      target_repo:
        description: Target repository (owner/repo, svennijhuis only)
        required: true
        type: string
permissions:
  contents: read
checkout:
  repository: ${{ github.event.inputs.target_repo }}
  github-token: ${{ secrets.GH_AW_MAIN_REPO_TOKEN }}
  path: repo
  current: true
tools:
  github:
    github-token: ${{ secrets.GH_AW_MAIN_REPO_TOKEN }}
    toolsets: [repos, pull_requests]
  bash:
    - "npx:*"
    - "eslint:*"
    - "pip:*"
    - "find:*"
    - "wc:*"
safe-outputs:
  github-token: ${{ secrets.GH_AW_MAIN_REPO_TOKEN }}
  create-issue:
    target-repo: ${{ github.event.inputs.target_repo }}
    title-prefix: "[quality] "
    labels: [code-quality, automation]
    max: 10
---

# Code Quality Review

Source: [gallery Code Quality Monitoring](https://github.github.com/gh-aw/gallery/multi-repo/code-quality-monitoring/).

Stop if the owner of `${{ github.event.inputs.target_repo }}` is not `svennijhuis`.

The target repo is checked out at `${{ github.workspace }}/repo`. Start with `cd ${{ github.workspace }}/repo`.

## What to analyze

1. **JS/TS** (if `package.json`): `npx eslint . --format json --max-warnings 0 2>/dev/null | head -200`. Flag files with more than 5 errors, empty `catch` blocks, unused imports.
2. **Complexity**: list the 20 largest source files. Flag files over 500 lines.
3. **Python** (if `requirements.txt` or `pyproject.toml`): `pip install flake8 --quiet && flake8 . --count --statistics | tail -20`. Flag modules with more than 10 errors.
4. **Repo signals**: open Dependabot alerts and the last 10 merged PRs for recurring patterns.

## What to create

One issue per finding category, not per file. Name files with links, why it matters, a first step, and a severity (High security or crash, Medium maintainability, Low style). Skip categories with fewer than 3 instances.

## What to skip

Style without a linter rule, files with `// quality-exempt`, and test files (`*.test.*`, `*.spec.*`, `__tests__/`).
