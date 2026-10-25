# 102 Squad retro as an issue (optional)

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Cross-repo | F00 |

## Context

Actions adapter skips `squad-retro`. If lessons matter, emit retro as one issue instead of a file.

## Sources

- https://github.com/svennijhuis/agentPacks/blob/main/plugins/squad/commands/squad-review.md
- https://github.com/mattpocock/skills/blob/main/skills/engineering/retro/SKILL.md

## Design

```yaml
safe-outputs:
  create-issue:
    title-prefix: "[retro] "
    max: 1
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Decision | `rg -c 'retro' docs/AGENTPACKS.md` | >= 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
