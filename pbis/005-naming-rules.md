# 005 Naming rules and renames

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Done | Platform | [001](001-central-catalog-layout.md) |

## Context

Gallery names are job named kebab-case (`ci-doctor`, `repo-status`, `pr-fix`). agentPacks rule: a workflow or command name never equals a skill name.

## Sources

- https://github.github.com/gh-aw/gallery/
- https://github.github.com/gh-aw/gallery/automated-pr-review/
- https://github.com/githubnext/agentics/blob/main/workflows/

## Design

| Old | New | Why |
| --- | --- | --- |
| `workflows/squad-review.md` | `workflows/pr-review.md` | Job named; not the agentPacks command name |
| `/squad-review` | `/pr-review` | Follows workflow name |
| `shared/squad.md` | `shared/agentpacks.md` | `squad` is an agentPacks skill |
| `shared/org-defaults.md` | `shared/defaults.md` | Personal account |

## Code example

```yaml
on:
  slash_command:
    strategy: centralized
    name: pr-review
    events: [pull_request_comment]
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Old names gone | `rg -n 'squad-review.md\b\|org-defaults\|shared/squad.md' --glob '!*.lock.yml' --glob '!CHANGELOG.md' --glob '!pbis/*' .` | only the agentPacks command import path |
| 2 | Slash name | `rg -n 'name: pr-review' workflows/pr-review.md` | 1 line |
| 3 | No workflow equals a skill | `for n in $(ls workflows/*.md \| xargs -n1 basename \| sed 's/.md$//'); do gh api 'repos/svennijhuis/agentPacks/git/trees/34e1dec3535baa1d77cb441ea8c98498dc9b3684?recursive=1' --jq '.tree[].path' \| rg -x "plugins/.*/skills/$n/SKILL.md"; done` | no output |

## Evidence

`git diff --stat main..HEAD` shows renames `workflows/{squad-review.md => pr-review.md}`, `shared/squad.md` and `shared/org-defaults.md` replaced.

## Non-goals

No rename of agentPacks commands.

## Risks

Consumers that installed `squad-review` before must re-add; none exist yet.

## Post-merge

See PR #2 post-merge list: tag v1.0.0 + v1, set COPILOT_GITHUB_TOKEN, decide visibility.
