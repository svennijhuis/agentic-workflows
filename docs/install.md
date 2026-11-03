# Install in an organization

How to use this library in a GitHub org: what to switch on, which tokens and secrets exist, where to get them, and how to check it works. Workflow behavior is in [workflows/README.md](../workflows/README.md).

## What you need

| Need | Why |
| --- | --- |
| Org owner (or admin on the target repo) | Org Copilot policy, org secrets, Actions settings |
| GitHub Copilot on the org (Business or Enterprise) | Every workflow runs the `copilot` engine |
| [`gh` CLI](https://cli.github.com/), logged in with `gh auth login` | `gh aw add`, `gh aw compile`, `gh secret`, `gh label` |
| `gh-aw` extension, pinned to the version in [`aw.yml`](../aw.yml) | Installs and compiles workflows |

```bash
gh extension install github/gh-aw --pin v0.93.4
```

## 1. Org settings (once per org)

### Copilot billed to the org

The workflows set `copilot-requests: write`. Copilot then runs on the Actions `GITHUB_TOKEN` and is billed to the org. No personal token is needed for inference.

1. Open `https://github.com/<org>`, click **Settings** (top tab row of the org page).
2. Left sidebar: **Copilot** → **Policies**. Direct link: `https://github.com/organizations/<org>/settings/copilot/policies`.
3. Find **Allow use of Copilot CLI billed to the organization** and set it to **Enabled**.

No Copilot entry in the sidebar: the org has no Copilot plan. Buy or enable one first under **Settings → Billing and plans**.

`COPILOT_GITHUB_TOKEN` is ignored for inference. Do not create it.

### Actions

Org level first, then each target repo.

1. Org: `https://github.com/organizations/<org>/settings/actions`. Left sidebar: **Actions** → **General**.
   - Under **Policies**: if the org limits actions, choose **Allow select actions and reusable workflows** and add `github/gh-aw-actions/*` to the list, then **Save**.
   - Scroll to **Workflow permissions**, tick **Allow GitHub Actions to create and approve pull requests**, **Save**.
2. Repo: `https://github.com/<org>/<target-repo>/settings/actions`. Open the repo, click the **Settings** tab, left sidebar **Actions** → **General**.
   - Scroll to **Workflow permissions**, tick **Allow GitHub Actions to create and approve pull requests**, **Save**. The builder cannot open a PR without it.
   - Box greyed out: the org setting in step 1 is off.

## 2. Install into a target repo

```bash
cd <target-repo>
gh aw add svennijhuis/agentic-workflows/workflows/builder.md@<tag>
gh aw add svennijhuis/agentic-workflows/workflows/issue-triage.md@<tag>
gh aw compile
git add .github
git commit -m "add agentic workflows"
git push
```

- Use a release tag for `<tag>`, not a branch, so updates are deliberate.
- `gh aw add` also fetches the shared fragments, skill copies and every workflow named in `dispatch-workflow`: `builder` brings `reviewer`, and the other way round.
- Commit everything under `.github/workflows/`, including `shared/` and the `*.lock.yml` files. Imports are read at runtime from there.
- Commit `.github/aw/actions-lock.json` if `gh aw compile` creates or changes it.

Workflow sets (pick what you need):

| Goal | Install |
| --- | --- |
| Bug to PR | `issue-triage`, `bug-fix`, `builder`, `reviewer` |
| Plan to PRs (wayfinder) | `wf-to-spec`, `wf-spec`, `wf-plan`, `wf-delivery`, `builder`, `reviewer` |
| Extras | `retro`, `agents-md-sync`, `token-audit` |

## 3. Tokens and secrets

| Name | Needed by | Required | Where it lives |
| --- | --- | --- | --- |
| `GITHUB_TOKEN` | every workflow | yes, automatic | Provided by Actions. Nothing to create |
| `AW_CORE_ISSUES_TOKEN` | `retro` only | only if you install `retro` | Repo or org Actions secret |
| `COPILOT_GITHUB_TOKEN` | nothing | no | Not used, see above |

### `AW_CORE_ISSUES_TOKEN` (only for `retro`)

`retro` opens an issue in `svennijhuis/agentic-workflows` when the flow can do better. The Actions `GITHUB_TOKEN` of your org repo cannot write to another repo, so it needs a token.

Skip it if you do not install `retro`. If your org should not write to that repo, do not install `retro`, or change `target-repo` in your copy of [`retro.md`](../workflows/retro.md) to a repo you own.

Create the token (click path: your avatar top right → **Settings** → left sidebar bottom **Developer settings** → **Personal access tokens** → **Fine-grained tokens** → **Generate new token**; direct link <https://github.com/settings/personal-access-tokens/new>):

1. **Token name**: `aw-core-issues`.
2. **Resource owner**: pick the owner of the core repo (`svennijhuis`) from the dropdown. The account creating the token needs access to that repo.
3. **Expiration**: set one (for example 90 days) and note the date. After it expires, `retro` fails on `create-issue`.
4. **Repository access**: choose **Only select repositories**, then pick `svennijhuis/agentic-workflows`.
5. **Permissions**: click **Add permissions** (or expand **Repository permissions**), find **Issues**, set **Read and write**. Leave the rest. **Metadata: Read** is added automatically.
6. Click **Generate token**. Copy the `github_pat_...` value now: GitHub shows it once.
7. Org may require approval for fine-grained tokens: an org owner approves it at `https://github.com/organizations/<org>/settings/personal-access-tokens/pending_requests` (only when the resource owner is that org).

Store it as a secret. `gh` asks for the value, so it never lands in shell history or a file.

```bash
gh secret set AW_CORE_ISSUES_TOKEN --repo <org>/<target-repo>
```

```bash
gh secret set AW_CORE_ISSUES_TOKEN --org <org> --repos <repo1>,<repo2>
```

Or in the UI:

- Repo: `https://github.com/<org>/<target-repo>/settings/secrets/actions`. Click the repo **Settings** tab → left sidebar **Secrets and variables** → **Actions** → green **New repository secret**. **Name**: `AW_CORE_ISSUES_TOKEN`, **Secret**: paste the token, **Add secret**.
- Org (share with several repos): `https://github.com/organizations/<org>/settings/secrets/actions`. Org **Settings** → **Secrets and variables** → **Actions** → **New organization secret**. Set **Repository access** to **Selected repositories** and tick the target repos.
- Check it: the secret name shows in the list. The value is never shown again.

Rotate by creating a new token and running the same `gh secret set` again.

## 4. Labels (once per target repo)

The flow uses labels as state. Create the ones that are not there yet. By hand: open `https://github.com/<org>/<target-repo>/labels` (repo **Issues** tab → **Labels** button), click **New label**, type the name, **Create label**. Or all at once:

```bash
for l in triage bug wayfinder security needs-info duplicate agent-fix blocked \
         wayfinder:map to-spec specced to-tickets planned ready-for-agent \
         builder needs-help ready-to-merge; do
  gh label create "$l" --repo <org>/<target-repo> 2>/dev/null || true
done
```

Only the labels of the workflows you installed matter. Meaning of each: [workflows/README.md](../workflows/README.md).

## 5. Repo rules (optional, recommended)

The builder and reviewer read repo rules before they act. Add what you have, and keep only rules a reviewer can check on a diff:

Add these files in the repo root via **Add file → Create new file** on the repo's **Code** tab, or commit them locally.

- `AGENTS.md` (or let [`agents-md-sync`](../workflows/agents-md-sync.md) write it)
- `.github/copilot-instructions.md`
- `.github/instructions/*.instructions.md` with an `applyTo` glob

## 6. Check it works

1. Repo **Issues** tab → **New issue**. Describe a small bug, **Submit new issue**. In the right sidebar click **Labels**, pick `triage`. `issue-triage` should comment and set `bug`.
2. A maintainer adds `agent-fix` the same way (right sidebar **Labels**). `bug-fix` starts `builder`, which opens a PR on `builder/issue-<n>` (see the **Pull requests** tab), then `reviewer` reviews it.
3. Runs: repo **Actions** tab, pick the workflow in the left list, click a run for logs. Nothing listed: the compiled `.lock.yml` files are not on the default branch yet.
4. Start one by hand: **Actions** → pick the workflow (for example `builder`) → **Run workflow** button (right) → fill the inputs → green **Run workflow**. `token-audit` writes a daily cost report.

A maintainer always merges. Nothing here merges or approves.

## Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| Run fails at the Copilot step with a billing or policy error | Org policy *Allow use of Copilot CLI billed to the organization* is off, or the org has no Copilot plan |
| Builder finishes but no PR | *Allow GitHub Actions to create and approve pull requests* is off |
| A label set by one workflow does not start the next | Expected: events made with `GITHUB_TOKEN` start nothing. The flow hands off by `workflow_dispatch` instead |
| `retro` fails on `create-issue` | `AW_CORE_ISSUES_TOKEN` missing, expired, or lacks Issues write on the target repo |
| `gh aw compile` complains about `dispatch-workflow` | Dispatch targets are not all in `.github/workflows/`. Install both `builder` and `reviewer` |

## Update

```bash
gh aw update
gh aw compile
```

Commit the result. Read the release notes of the new tag first: caps, labels and secrets can change.
