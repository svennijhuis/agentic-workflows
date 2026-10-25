# 106 Diagnosis prompt for ci-doctor (Matt diagnosing-bugs)

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Cross-repo | [045](045-ci-doctor.md) |

## Context

Structured loop: reproduce, minimise, hypothesise, instrument, fix, regression test.

## Sources

- https://github.com/mattpocock/skills/blob/main/skills/engineering/diagnosing-bugs/SKILL.md

## Design

`workflows/shared/prompts/diagnose.md` imported by ci-doctor.

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Imported | `rg -c 'prompts/diagnose.md' workflows/ci-doctor.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
