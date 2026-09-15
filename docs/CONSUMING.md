# Use this catalog from other repositories

Target audience: a product or platform repo that should run org-standard automation.

Replace `svennijhuis` with the company org when the catalog moves.

## 1. One-time setup in the consuming repo

```bash
gh extension install github/gh-aw
cd your-product-repo
gh aw init          # .gitattributes, dispatcher skill, optional Copilot agent
git add .github .gitattributes
git commit -m "Initialize GitHub Agentic Workflows"
```

`gh aw init` is for **authoring and compiling** in that repo. It does not install this catalog.

Enable GitHub Actions and Copilot (or the engine you set) on the repository.

## 2. Install a whole workflow (preferred)

```bash
# Interactive
gh aw add-wizard svennijhuis/agentic-workflows/squad-review

# Scripted, pinned
gh aw add svennijhuis/agentic-workflows/squad-review@v1.0.0
```

What happens:

1. Markdown is copied to `.github/workflows/squad-review.md`.
2. Frontmatter gets `source: svennijhuis/agentic-workflows/squad-review@<ref>`.
3. The compiler writes `.github/workflows/squad-review.lock.yml`.
4. Declared `imports`, `resources`, and `dispatch-workflow` dependencies are fetched.

Then:

```bash
git add .github/workflows/squad-review.md .github/workflows/squad-review.lock.yml
git commit -m "Add squad-review agentic workflow"
git push
```

Run it from the Actions tab, comment `/squad-review` on a PR, or wait for `pull_request` events.

Keep the **catalog repository** internal/private for org-only sharing. `private: true` on a workflow file blocks `gh aw add` completely — do not set it on templates you want product repos to install.

## 3. Update later

```bash
gh aw update squad-review  # one workflow
gh aw update               # all tracked sources
```

Default is a 3-way merge so local edits (labels, `target-repo`, extra tools) survive. Use `--no-merge` to replace with upstream. If `source:` uses `@v1`, updates stay on that major until `--major`.

Also keep the CLI and compiler current:

```bash
gh extensions upgrade github/gh-aw
gh aw upgrade
```

## 4. Import fragments into a repo-local workflow

Use this when the consuming repo authors its own `.github/workflows/foo.md` but wants org tools, network, or agentPacks wiring.

```yaml
---
on:
  pull_request:
engine: copilot
imports:
  - svennijhuis/agentic-workflows/workflows/shared/org-defaults.md@v1
  - svennijhuis/agentic-workflows/workflows/shared/security.md@v1
---

# Review this pull request using org defaults.
```

Remote imports are cached under `.github/aw/imports/` by commit SHA. The lock file records the SHA so runs stay reproducible.

Parameterized fragments use `import-schema` plus:

```yaml
imports:
  - uses: svennijhuis/agentic-workflows/workflows/shared/some-template.md@v1
    with:
      severity: high
```

See [Imports](https://github.github.com/gh-aw/reference/imports/).

## 5. Remix instead of install

When the catalog workflow is only a starting point (different labels, engine, or outputs), do **not** `gh aw add`. Point a coding agent at [create.md](https://raw.githubusercontent.com/github/gh-aw/main/create.md) and the source URL, then compile locally. Promote a cleaned-up version back into this catalog if other repos will need the same thing.

Public starters: [githubnext/agentics](https://github.com/githubnext/agentics). Prefer installing from **this** catalog once a workflow is org-standard.

## 6. After install, check these in the consuming repo

- Secrets/vars the workflow names (GitHub App, PAT, MCP keys).
- `permissions:` on the lock file.
- `network.allowed` and MCP URLs.
- `safe-outputs` `max:` and `target-repo`.
- That Actions is allowed to run on the default branch.

## 7. What not to do

- Do not vendor catalog Markdown by copy-paste. You lose `source:` and `gh aw update`.
- Do not put product-repo-only workflows in this catalog. Keep those under the product repo’s `.github/workflows/`.
- Do not copy [`agentPacks`](https://github.com/svennijhuis/agentPacks) skills into `.github/skills/` of every product repo. Reference them from the workflow ([AGENTPACKS.md](AGENTPACKS.md)).
