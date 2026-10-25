# Consuming

## Setup (once per repo)

```bash
gh extension install github/gh-aw
gh aw init
gh aw secrets set COPILOT_GITHUB_TOKEN   # paste PAT when asked, never in a file
```

PAT: fine-grained, owner = your user, Account permissions > Copilot Requests: Read. `gho_` tokens are rejected. Workflows here set `copilot-requests: none` (that mode needs org centralized billing).

## Install

```bash
gh aw add svennijhuis/agentic-workflows/pr-review@v1.0.0
git add .github/workflows/pr-review.md .github/workflows/pr-review.lock.yml
```

Run: open a PR, comment `/pr-review`, or Actions tab.

## Pin

| Ref | Use |
| --- | --- |
| `@v1.2.0` | Prod (immutable) |
| `@v1` | Follow major on `gh aw update` |
| SHA | Freeze |
| `@main` | Catalog dev only |

## Update

```bash
gh aw update pr-review   # 3-way merge keeps local edits; --no-merge replaces
gh aw upgrade
```

## Trim

`pr-review` imports .NET, TypeScript and Rust standards. Delete the `shared/standards/<lang>.md` lines for stacks the repo does not use. Fewer tokens per run.

## Fragments only

```yaml
imports:
  - svennijhuis/agentic-workflows/workflows/shared/defaults.md@v1.0.0
  - svennijhuis/agentic-workflows/workflows/shared/security.md@v1.0.0
  - svennijhuis/agentic-workflows/workflows/shared/standards/dotnet.md@v1.0.0
```

Cost caps do not import. Set `max-ai-credits`, `max-daily-ai-credits`, `max-turns`, `timeout-minutes` in your own frontmatter.

## Check after install

Secrets named, `permissions:`, `network.allowed`, `safe-outputs` `max:`.

## Don't

- Copy-paste catalog Markdown (loses `source:` and updates).
- Copy agentPacks skills into the repo. Import by path@ref.
- Put repo-only workflows in this catalog.
