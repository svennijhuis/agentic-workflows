---
description: 'Skill implement, local copy of mattpocock/skills/skills/engineering/implement@4ae2317.'
---

<!-- Source: mattpocock/skills/skills/engineering/implement@4ae2317ddb22b046e26455e4f9c9b3aaaf62212d (MIT License, Copyright (c) 2026 Matt Pocock). Body copied verbatim from SKILL.md, frontmatter dropped. To update: copy the new SKILL.md body here and bump the SHA. -->

# Skill: implement

_Implement a piece of work based on a spec or set of tickets._

Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, call the Skill tool with "code-review" to review the work.

Commit your work to the current branch.
