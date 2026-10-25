# 107 TDD prompt for test-improver (Matt tdd)

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Cross-repo | [055](055-test-improver.md) |

## Context

Red, green, refactor; one test per run.

## Sources

- https://github.com/mattpocock/skills/blob/main/skills/engineering/tdd/SKILL.md

## Design

`workflows/shared/prompts/tdd.md`.

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Imported | `rg -c 'prompts/tdd.md' workflows/test-improver.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
