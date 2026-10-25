# 013 GitHub App for cross-repo writes

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Auth | [011](011-repo-visibility.md) |

## Context

Cross-repo safe outputs, dispatch, assign-to-agent need a PAT or App. App is short-lived and scoped.

## Sources

- https://github.github.com/gh-aw/reference/auth/
- https://github.github.com/gh-aw/reference/cross-repository/

## Design

```yaml
safe-outputs:
  github-app:
    client-id: ${{ vars.APP_ID }}
    private-key: ${{ secrets.APP_PRIVATE_KEY }}
    owner: svennijhuis
    repositories: [agentPacks, agentic-workflows]
```

## Code example

Used by 086, 095, 098.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | App referenced by name only | `rg -n 'APP_PRIVATE_KEY' workflows \| rg -v 'secrets.APP_PRIVATE_KEY'` | no output |
| 2 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Not for COPILOT_GITHUB_TOKEN (PAT only).

## Risks

Key handling is Sven's; never in repo.

## Post-merge

None beyond merge.
