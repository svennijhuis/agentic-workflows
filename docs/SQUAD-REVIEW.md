# Squad review on GitHub Actions

[`workflows/squad-review.md`](../workflows/squad-review.md) is the catalog template that runs **the same `/squad-review` loop** from [agentPacks](https://github.com/svennijhuis/agentPacks) inside GitHub Actions.

## Install in a product repo

```bash
gh extension install github/gh-aw
gh aw init
gh aw add svennijhuis/agentic-workflows/squad-review@v1
git add .github/workflows/squad-review.md .github/workflows/squad-review.lock.yml
git commit -m "Add squad-review agentic workflow"
git push
```

Then either:

- Open a pull request (runs on `opened` / `synchronize` / `ready_for_review`), or
- Comment `/squad-review` on a pull request (centralized slash command), or
- Run **squad-review** from the Actions tab (`workflow_dispatch`).

Enable Actions and Copilot (or `copilot-requests: write`) on that repository.

## What gets loaded

`plugins:` (see [`workflows/shared/squad.md`](../workflows/shared/squad.md)):

| Plugin | Why |
| --- | --- |
| `squad` | Review agents + review contract |
| `git` | Block destructive git in the sandbox |
| `dotnet` / `typescript` / `rust` | Language review skills; the agent must load only the stacks in the diff |

Nothing is copied out of agentPacks. Compile pins each plugin ref to a commit SHA.

## IDE vs Actions

`/squad-review` in Cursor is interactive (save-markdown ask, local `docs/reviews/`). The Actions workflow is **report-only on the PR**: inline review comments + one `COMMENT` summary. It does not write files, assign a Squad `pass`/`fix` verdict, or start a fix round.

Full `/squad` (grill, plan, implement, ≤2 fix rounds) stays in the IDE. Do not run that unattended against every PR.

## After install, look at

1. Frontmatter `plugins:` / `imports:` — this is how packs are wired.
2. The compiled `.lock.yml` checkout steps for each plugin (SHA-pinned).
3. A real PR: comments should look like a squad-review merged list, not a generic linter dump.
