# 012 COPILOT_GITHUB_TOKEN runbook and rotation

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | Auth | [004](004-personal-copilot-auth.md) |

## Context

PAT expiry silently stops all runs. Document create, set, check, rotate. Names only.

## Sources

- https://github.github.com/gh-aw/reference/auth/
- https://github.github.com/gh-aw/troubleshooting/common-issues/

## Design

`docs/CONSUMING.md#setup`:
1. Fine-grained PAT, owner user, Account permissions Copilot Requests: Read, expiry 90d.
2. `gh aw secrets set COPILOT_GITHUB_TOKEN` (prompt).
3. `gh aw secrets bootstrap --engine copilot --non-interactive`.
4. Calendar reminder 7 days before expiry.

## Code example

```bash
gh aw secrets bootstrap --engine copilot --non-interactive --repo OWNER/REPO
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Runbook present | `rg -c 'Copilot Requests: Read' docs/CONSUMING.md` | >= 1 |
| 2 | Bootstrap clean | `gh aw secrets bootstrap --engine copilot --non-interactive` | no missing secrets |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Bot never creates or stores the PAT.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
