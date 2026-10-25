# 004 Personal Copilot auth

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Done | Auth | none |

## Context

`copilot-requests: write` needs org centralized billing and fails on a personal account. Use fine-grained PAT secret `COPILOT_GITHUB_TOKEN` (owner = user, Account permission Copilot Requests: Read). `gho_` tokens are rejected at activation.

## Sources

- https://github.github.com/gh-aw/reference/auth/
- https://github.github.com/gh-aw/reference/billing/
- https://github.github.com/gh-aw/reference/engines/copilot/

## Design

```yaml
permissions:
  contents: read
  issues: read
  pull-requests: read
  copilot-requests: none   # silences the compiler tip, PAT path
```

## Code example

```bash
gh aw secrets set COPILOT_GITHUB_TOKEN   # prompts, never in a file
gh aw secrets bootstrap --engine copilot --non-interactive
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | No write mode | `rg -n 'copilot-requests: write' workflows --glob '*.md'` | no output |
| 2 | None mode set | `rg -c '^  copilot-requests: none$' workflows/pr-review.md` | 1 |
| 3 | Lock validates secret | `rg -c 'Validate COPILOT_GITHUB_TOKEN secret' workflows/pr-review.lock.yml` | 1 |
| 4 | No token values | `rg -n 'gh[pousr]_[A-Za-z0-9]{20,}\|github_pat_' .` | no output |

## Evidence

Lock contains step `Validate COPILOT_GITHUB_TOKEN secret`; manifest secrets list includes `COPILOT_GITHUB_TOKEN`.

## Non-goals

No GitHub App for inference (not supported for this secret).

## Risks

PAT expiry silently breaks runs; see 012 for rotation runbook.

## Post-merge

See PR #2 post-merge list: tag v1.0.0 + v1, set COPILOT_GITHUB_TOKEN, decide visibility.
