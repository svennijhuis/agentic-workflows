---
description: Catalog defaults imported by every workflow. Engine copilot (pinned version). No tools and no caps here.
engine:
  id: copilot
  version: "1.0.101"
---

Catalog defaults (C03). Engine: copilot, version pinned here (C06). Every workflow declares its own GitHub tools as `mode: gh-proxy` with an explicit toolset list; writes only through the importing workflow's safe-outputs.

Caps are not importable (the compiler ignores them in imports). Each workflow sets `max-ai-credits`, `max-daily-ai-credits`, `max-turns` and `timeout-minutes` in its own frontmatter. 1 AI Credit (AIC) is $0.01. Start values and how to tune them: [README](../README.md#cost-caps).

Fetch your own context with the GitHub tools and the imports above. Do not expect repo content pasted into this prompt (gist A7).
