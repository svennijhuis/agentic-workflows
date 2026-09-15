---
description: Smoke-test catalog template. Safe to install; does not write to other repos.
intent: Prove gh aw add from the org catalog works in a consuming repository.
on:
  workflow_dispatch:
engine: copilot
imports:
  - shared/org-defaults.md
  - shared/security.md
permissions:
  contents: read
  issues: read
  copilot-requests: write
---

# Hello from the org catalog

You are running as a GitHub Agentic Workflow installed from the org catalog.

1. State the repository (`${{ github.repository }}`) and event (`workflow_dispatch`).
2. Summarize what this catalog is for: other repos install templates with `gh aw add`; they do not copy Markdown by hand.
3. Do not create issues, comments, or pull requests.
4. Do not change files.

This workflow exists so teams can verify CLI install, compilation, and Actions enablement before attaching real automation.
