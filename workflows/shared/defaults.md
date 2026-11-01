---
description: Catalog defaults imported by every workflow. Engine copilot (pinned version), read-only GitHub tools. No caps here.
engine:
  id: copilot
  version: "1.0.101"
tools:
  github:
    toolsets: [repos, issues, pull_requests]
---

Catalog defaults (C03). Engine: copilot, version pinned in `.github/aw.json` and here (C06). Read-only GitHub tools; writes only through the importing workflow's safe-outputs.

Caps are not importable (the compiler ignores them in imports). Each workflow sets `max-ai-credits` (at most 50), `max-daily-ai-credits` (at most 200), `max-turns` and `timeout-minutes` in its own frontmatter.

Fetch your own context with the GitHub tools and the imports above. Do not expect repo content pasted into this prompt (gist A7).
