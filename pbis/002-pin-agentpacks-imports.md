# 002 Pin agentPacks, import only what helps

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Done | pr-review | [001](001-central-catalog-layout.md) |

## Context

`@marketplace` was a branch ref (last update 2026-09-14, lags main). agentPacks has no tags yet, so pin main SHA. Keep only imports that change review output: squad skill (contract), squad plugin (agents), `/squad-review` command, review standards. Drop `git`, `dotnet`, `typescript`, `rust` plugins.

## Sources

- https://github.github.com/gh-aw/reference/imports/
- https://github.github.com/gh-aw/reference/frontmatter/
- https://github.github.com/gh-aw/guides/sharing-workflows/
- https://github.com/svennijhuis/agentPacks/blob/main/plugins/squad/commands/squad-review.md

## Design

Observed compiler behaviour (gh-aw v0.93.4):
- `plugins:` merges from an imported fragment (lock manifest lists `plugins/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684`).
- `skills:` is dropped silently when it sits in an imported fragment (fix tracked in 111, not applied in this round).
- Remote `owner/repo/path@sha` inside a local fragment resolves; lock caches under `.github/aw/imports/<owner>/<repo>/<sha>/`.

```yaml
# workflows/shared/agentpacks.md (today)
skills:
  - svennijhuis/agentPacks/plugins/squad/skills/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684   # dropped by compiler, see 111
plugins:
  - svennijhuis/agentPacks/plugins/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684
# workflows/pr-review.md
imports:
  - svennijhuis/agentPacks/plugins/squad/commands/squad-review.md@34e1dec3535baa1d77cb441ea8c98498dc9b3684
```

## Code example

Before / after:
```diff
- svennijhuis/agentPacks/plugins/squad/commands/squad-review.md@marketplace
+ svennijhuis/agentPacks/plugins/squad/commands/squad-review.md@34e1dec3535baa1d77cb441ea8c98498dc9b3684
- svennijhuis/agentPacks/plugins/git@marketplace
- svennijhuis/agentPacks/plugins/dotnet@marketplace
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows --glob '*.md'` | no output |
| 2 | Plugin pinned | `rg -o 'plugins/squad@[0-9a-f]{40}' workflows/pr-review.lock.yml \| sort -u` | plugins/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684 |
| 3 | 14 remote imports cached | `rg -o 'runtime-import \.github/aw/imports/svennijhuis/agentPacks/[^}]*' workflows/pr-review.lock.yml \| sort -u \| wc -l` | 14 |

## Evidence

Lock manifest lists `plugins/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684`; 14 agentPacks runtime-imports (1 command + 13 standards). Known gap found while writing the backlog: `skills:` in the fragment is dropped, see 111.

## Non-goals

No tag on agentPacks yet (L02 bumps the pin). No vendored skill text.

## Risks

Runtime step warns when a plugin dir has no `.md` after install; agents live in `plugins/squad/agents/*.md` on main, verify in first trial (F00, 101). `skills:` drop means the `squad` skill is not installed today (111).

## Post-merge

See PR #2 post-merge list: tag v1.0.0 + v1, set COPILOT_GITHUB_TOKEN, decide visibility.
