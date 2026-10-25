# 014 Repo-level GH_AW_DEFAULT_* variables

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Cost | [003](003-cost-caps.md) |

## Context

Second guard behind frontmatter caps: repo Actions variables for defaults. Precedence: frontmatter > repo var > org > enterprise.

## Sources

- https://github.github.com/gh-aw/reference/cost-management/
- https://github.github.com/gh-aw/reference/compiler-enterprise-environment-controls/

## Design

```yaml
# defaults.yml (not committed with values that matter; keys only)
default_max_ai_credits: "50"
default_max_daily_ai_credits: "200"
default_max_turns: "15"
default_timeout_minutes: "10"
```
```bash
gh aw env update defaults.yml --scope repo --repo svennijhuis/<repo> --dry-run
```

## Code example

Export first: `gh aw env get defaults.yml --scope repo --repo OWNER/REPO`.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Vars set | `gh variable list --repo OWNER/REPO \| rg -c GH_AW_DEFAULT_` | 4 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Partial file deletes vars: always export first.

## Post-merge

None beyond merge.
