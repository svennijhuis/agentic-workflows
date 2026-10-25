# 105 Triage state labels (Matt triage)

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Cross-repo | none |

## Context

Labels: `needs-triage`, `needs-info`, `ready`, `wontfix`. Used by F00 issue triage and 071.

## Sources

- https://github.com/mattpocock/skills/blob/main/skills/engineering/triage/SKILL.md

## Design

`docs/GOVERNANCE.md#labels` table + `gh label create` script.

## Code example

```bash
for l in needs-triage needs-info ready wontfix; do gh label create $l --repo OWNER/REPO --force; done
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Labels documented | `rg -c 'needs-info' docs/GOVERNANCE.md` | >= 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
