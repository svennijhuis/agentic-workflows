---
description: agentPacks wiring note. The skills key lives in the consumer workflow (C12b), never in this fragment.
---

gh-aw reads `skills:` only from the main workflow and silently drops it from an imported fragment (C12b, POL31). The squad skill is pinned in `workflows/squad-review.md` frontmatter. `plugins:` is not used: a plugins pin at a main SHA loads zero agents (C12 correction). Use `@vX.Y.Z` or a 40-hex SHA on plugins and imports, never a branch ref. Do not paste skills or agents into `prompts/`.
