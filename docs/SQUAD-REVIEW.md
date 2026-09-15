# Squad review on GitHub Actions

[`workflows/squad-review.md`](../workflows/squad-review.md) is a thin Actions adapter. The review loop, skill, and agents stay in [agentPacks](https://github.com/svennijhuis/agentPacks). This catalog does not copy them.

## What is imported (one source)

| Frontmatter | From agentPacks | Why |
| --- | --- | --- |
| `skills:` | `plugins/squad/skills/squad@marketplace` | Installs the `squad` skill in the activation job (`disable-model-invocation`, so it will not self-load) |
| `plugins:` | `squad`, `git`, `dotnet`, `typescript`, `rust` @marketplace | Copilot/Claude/Codex **agents** (`squad-reviewer`, …) live in the plugin. gh-aw `imports:` of agent files only accepts `.github/agents/`, which this pack does not use |
| `imports:` | `plugins/squad/commands/squad-review.md@marketplace` | The `/squad-review` command text. Edit it in agentPacks, not here |

The workflow Markdown in this repo only overrides I/O: pin this PR, post via safe-outputs, do not write `docs/reviews/`.

## Install in a product repo

```bash
gh extension install github/gh-aw
gh aw init
gh aw add svennijhuis/agentic-workflows/squad-review@v1
git add .github/workflows/squad-review.md .github/workflows/squad-review.lock.yml
git commit -m "Add squad-review agentic workflow"
git push
```

Then open a PR, comment `/squad-review`, or run it from Actions. Enable Copilot / `copilot-requests: write`.

## Change the review behaviour

Edit agentPacks (`skills/squad`, `agents/`, `commands/squad-review.md`), publish `marketplace`, then `gh aw compile` / `gh aw update` in the consuming repo. Do not duplicate the contract in this catalog.
