---
description: Org safety baseline. Tighten allowed domains per workflow.
network:
  allowed: []
---

Keep outbound network closed unless the workflow needs a named MCP or API host. Add hosts on the importing workflow; they union with this list.

Do not put secrets in this file. Prefer GitHub Apps over PATs for any cross-repo access declared by the importer.
