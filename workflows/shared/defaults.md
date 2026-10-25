---
description: Baseline GitHub tools for catalog workflows.
tools:
  github:
    toolsets: [repos, issues]
---

Read-only GitHub tools unless the importing workflow adds write safe-outputs.

Cost caps are not importable (compiler ignores them here). Each workflow sets them in its own frontmatter: `max-ai-credits: 50`, `max-daily-ai-credits: 200`, `max-turns: 15`, `timeout-minutes: 10`.
