# 104 PR body rules for agent PRs (Matt pr)

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Cross-repo | [103](103-principles-fragment.md) |

## Context

Agent PR bodies: why, what, how verified, risk. Short.

## Sources

- https://github.com/mattpocock/skills/blob/main/skills/engineering/pr/SKILL.md

## Design

Fragment `workflows/shared/prompts/pr-body.md` with 4 headings.

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Fragment | `test -f workflows/shared/prompts/pr-body.md && echo ok` | ok |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
