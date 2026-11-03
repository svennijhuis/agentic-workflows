---
description: 'Skill deslop, local copy of cursor/plugins/cursor-team-kit/skills/deslop@ae5650f.'
---

<!-- Source: cursor/plugins/cursor-team-kit/skills/deslop@ae5650febf4320793844c12c4adaa937f417f8da (no license file in source repo). Body copied verbatim from SKILL.md, frontmatter dropped. To update: copy the new SKILL.md body here and bump the SHA. -->

# Skill: deslop

_Remove AI-generated code slop and clean up code style_

## Remove AI code slop

Check the diff against main and remove AI-generated slop introduced in the branch.

### Focus Areas

- Extra comments that are unnecessary or inconsistent with local style
- Defensive checks or try/catch blocks that are abnormal for trusted code paths
- Casts to `any` used only to bypass type issues
- Deeply nested code that should be simplified with early returns
- Other patterns inconsistent with the file and surrounding codebase

### Guardrails

- Keep behavior unchanged unless fixing a clear bug.
- Prefer minimal, focused edits over broad rewrites.
- Keep the final summary concise (1-3 sentences).
