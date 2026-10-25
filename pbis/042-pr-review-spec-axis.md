# 042 pr-review: spec axis from linked issue

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | pr-review | F00 |

## Context

Matt code-review: Standards axis + Spec axis. Squad review without a plan has no acceptance criteria. Use the linked issue (closing keyword) as the spec.

## Sources

- https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review/SKILL.md
- https://github.com/svennijhuis/agentPacks/blob/main/plugins/squad/commands/squad-review.md

## Design

Prompt add:
```markdown
If the PR body links an issue (Fixes #N), read it and pass its acceptance criteria to squad-reviewer as the spec.
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Prompt line | `rg -c 'acceptance criteria' workflows/pr-review.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
