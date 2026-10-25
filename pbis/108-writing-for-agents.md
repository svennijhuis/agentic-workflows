# 108 Prompt style guide for catalog workflows

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Cross-repo | [001](001-central-catalog-layout.md) |

## Context

Prompts: imperative, short, numbered steps, explicit stop conditions, no essays, no em dash. Gist: context not control (agent fetches its own context), precise words, short script output.

## Sources

- https://github.com/mattpocock/skills/blob/main/skills/productivity/writing-for-agents/SKILL.md
- https://github.github.com/gh-aw/reference/markdown/
- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (points 13, 25, 32)

## Design

`CONTRIBUTING.md#prompt-style` with 6 rules + one before/after.

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Section | `rg -c 'prompt-style\|Prompt style' CONTRIBUTING.md` | 1 |
| 2 | No em dash | `rg -c '\x{2014}' workflows docs pbis` | no output |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
