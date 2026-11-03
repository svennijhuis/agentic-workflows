# Install in an organization

How to use this library in a GitHub org: what to switch on, which tokens and secrets exist, where to get them, and how to check it works. Workflow behavior is in [workflows/README.md](../workflows/README.md).

## What you need

| Need | Why |
| --- | --- |
| Org owner (or admin on the target repo) | Org Copilot policy (option A), org secrets, Actions settings |
| GitHub Copilot on the org (Business or Enterprise), or a personal Copilot license | Every workflow runs the `copilot` engine. See [Copilot auth](#copilot-auth-pick-one-option) |
| [`gh` CLI](https://cli.github.com/), logged in with `gh auth login` | `gh aw add`, `gh aw compile`, `gh secret`, `gh label` |
| `gh-aw` extension, pinned to the version in [`aw.yml`](../aw.yml) | Installs and compiles workflows |

```bash
gh extension install github/gh-aw --pin v0.93.4
```

## 1. Org settings (once per org)

### Copilot auth: pick one option

Every workflow runs the `copilot` engine and needs a way to pay for inference. There are two options. Pick one per target repo.

| | Option A: org billing (default) | Option B: personal token |
| --- | --- | --- |
| Who pays | The org's Copilot plan | The Copilot license of the account that owns the token |
| What you set up | Org Copilot policy (org owner) | `COPILOT_GITHUB_TOKEN` repo secret (repo admin) |
| Workflow change | None: the workflows ship with `copilot-requests: write` | Remove `copilot-requests: write` from your copies, then compile |
| Use when | The org has Copilot Business or Enterprise and an org owner can switch the policy on | Option A is not possible: no org owner available, policy stays off, or the run fails at the Copilot step |

#### Option A: Copilot billed to the org (default)

The workflows set `copilot-requests: write`. Copilot then runs on the Actions `GITHUB_TOKEN` and is billed to the org. No personal token is needed for inference. This needs an org owner once.

1. Open `https://github.com/<org>`, click **Settings** (top tab row of the org page).
2. Left sidebar: **Copilot** → **Policies**. Direct link: `https://github.com/organizations/<org>/settings/copilot/policies`.
3. Set **Copilot CLI** to **Enabled**.
4. Find **Allow use of Copilot CLI billed to the organization** and set it to **Enabled**.

No Copilot entry in the sidebar: the org has no Copilot plan. Buy or enable one first under **Settings → Billing and plans**.

With `copilot-requests: write` set, `COPILOT_GITHUB_TOKEN` is ignored for inference. Do not create it for option A.

Check it: the first run gets past the Copilot step. When the Actions token has no Copilot access through the org, the run fails at that step (often `403 Forbidden`). Then fix the policy, or switch to option B.

#### Option B: personal token (`COPILOT_GITHUB_TOKEN`)

Copilot runs on a fine-grained personal access token of one account and is billed to that account's Copilot license. Use it when org billing is not available. The account needs an active Copilot license.

1. Create the token: your avatar top right → **Settings** → left sidebar bottom **Developer settings** → **Personal access tokens** → **Fine-grained tokens** → **Generate new token**. Direct link: <https://github.com/settings/personal-access-tokens/new>.
   - **Token name**: for example `copilot-aw-<target-repo>`.
   - **Resource owner**: your own user account, not the org.
   - **Expiration**: set one and note the date. After it expires every workflow fails at the Copilot step.
   - **Permissions** → **Account permissions** → **Copilot Requests**: **Read**. Leave the rest.
   - **Generate token** and copy the `github_pat_...` value. GitHub shows it once. A classic or OAuth token (`ghp_`, `gho_`) does not work.
2. Store it as a secret in the target repo. `gh` asks for the value:

   ```bash
   gh secret set COPILOT_GITHUB_TOKEN --repo <org>/<target-repo>
   ```

3. In your copy of every installed workflow under `.github/workflows/`, delete the line `copilot-requests: write` under `permissions:`. Leave the other permissions as they are. While that line is there, the token is ignored.
4. `gh aw compile` and commit the `.md` and `.lock.yml` files.

`gh aw update` brings `copilot-requests: write` back from the library. Delete it again after each update, before you compile.

Rotate by creating a new token and running the same `gh secret set` again. Usage is billed to the token owner, so use an account that is meant for it, not a colleague's.

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
gh aw add svennijhuis/agentic-workflows/workflows/issue-builder.md@<tag>
gh aw add svennijhuis/agentic-workflows/workflows/issue-triage.md@<tag>
gh aw compile            # first time: --approve for new secrets, see section 3
git add .github
git commit -m "add agentic workflows"
git push
```

- Use a release tag for `<tag>`, not a branch, so updates are deliberate.
- `gh aw add` also fetches the shared fragments, skill copies and every workflow named in `dispatch-workflow`: `issue-builder` brings `pr-reviewer`, and the other way round.
- Upgrading from `builder`, `reviewer` or `token-audit`: delete the old `.github/workflows/{builder,reviewer,token-audit}.md` and `.lock.yml` files after adding the renamed ones, and re-run `gh aw add` for `bug-fix` and `wf-delivery` so they dispatch `issue-builder`. Otherwise two builders exist. `agentic-token-audit` starts a fresh `memory/agentic-token-audit` branch, so the old trend on `memory/token-audit` is not carried over: delete that branch or keep it as an archive.
- Commit everything under `.github/workflows/`, including `shared/` and the `*.lock.yml` files. Imports are read at runtime from there.
- Commit `.github/aw/actions-lock.json` if `gh aw compile` creates or changes it.

### Builder network

`issue-builder` installs dependencies and runs the repo's tests, but its network allows only the gh-aw `defaults`. Package registries are blocked until you add the repo's ecosystem. In your copy of `issue-builder.md`:

```yaml
network:
  allowed:
    - defaults
    - node        # or python, dotnet, go, java, rust, ruby; list each the repo needs
```

Then `gh aw compile`. A private registry host goes in the same list. Without it the builder cannot restore packages, tests stay red and it opens no PR.

Workflow sets (pick what you need):

| Goal | Install |
| --- | --- |
| Bug to PR | `issue-triage`, `bug-fix`, `issue-builder`, `pr-reviewer` |
| Plan to PRs (wayfinder) | `wf-to-spec`, `wf-spec`, `wf-plan`, `wf-delivery`, `issue-builder`, `pr-reviewer` |
| Extras | `retro`, `agents-md-sync`, `agentic-token-audit` |

## 3. Tokens and secrets

| Name | Needed by | Required | Where it lives |
| --- | --- | --- | --- |
| `GITHUB_TOKEN` | every workflow | yes, automatic | Provided by Actions. Nothing to create |
| `APP_ID` (variable), `APP_PRIVATE_KEY` (secret) | `issue-builder` | recommended: without it builder PRs start no CI | Repo or org Actions variable and secret |
| `AW_CORE_ISSUES_TOKEN` | `retro` only | only if you install `retro` | Repo or org Actions secret |
| `NUGET_FEED_TOKEN` | `issue-builder` in C# repos | only with a private NuGet feed | Repo or org Actions secret |
| `NUGET_FEED_URL`, `NUGET_FEED_USER` | `issue-builder` in C# repos | only with a private NuGet feed | Repo or org Actions variables (not secret) |
| `COPILOT_GITHUB_TOKEN` | every workflow, option B only | only with option B | Repo Actions secret. Ignored with option A, see [Copilot auth](#copilot-auth-pick-one-option) |

### GitHub App (builder PRs run CI)

Every write runs on the Actions `GITHUB_TOKEN`, and GitHub starts no workflow from an event made with that token. So a builder PR gets no `pull_request` run of the repo's own CI: required status checks stay on *Expected — waiting for status* and the PR cannot be merged without an admin bypass. `issue-builder` therefore takes an org GitHub App, as gh-aw recommends ([Triggering CI](https://github.github.com/gh-aw/reference/triggering-ci/)): its safe outputs mint a short-lived app token, open the PR and push as the app, and push one extra empty commit so CI starts. No app configured: it falls back to `GITHUB_TOKEN` and works as before, without CI.

Create the app once per org (org owner):

1. `https://github.com/organizations/<org>/settings/apps/new`. Org **Settings** → left sidebar bottom **Developer settings** → **GitHub Apps** → **New GitHub App**.
2. **GitHub App name**: for example `<org>-agent-builder`. **Homepage URL**: the org URL.
3. **Webhook**: untick **Active**. The app needs no events.
4. **Repository permissions**, set exactly these (gh-aw requests them when it mints the token; a missing one fails the mint):
   - **Actions**: Read and write (starts `pr-reviewer` by dispatch)
   - **Administration**: Read-only
   - **Contents**: Read and write (branch, commits)
   - **Issues**: Read and write (comments)
   - **Pull requests**: Read and write (open the PR, labels)
   - **Metadata**: Read-only (added automatically)
5. **Where can this GitHub App be installed?**: **Only on this account**. Click **Create GitHub App**.
6. On the app page note the **Client ID** (`Iv23...`). Scroll to **Private keys** → **Generate a private key**. A `.pem` file downloads.
7. Left sidebar **Install App** → **Install** next to the org → **Only select repositories** → pick the target repos → **Install**.

Store them in the target repo (or at org level with `--org <org> --repos ...`). The variable keeps the gh-aw name `APP_ID` but holds the Client ID:

```bash
gh variable set APP_ID --repo <org>/<target-repo> --body "<client-id>"
gh secret set APP_PRIVATE_KEY --repo <org>/<target-repo> < path/to/key.pem
```

Then delete the local `.pem`. Rotate by generating a new key on the app page, `gh secret set` again, and deleting the old key there.

`gh aw compile` stops on `issue-builder` with *New restricted secret(s): APP_PRIVATE_KEY*. Check it is only used by the `Generate GitHub App token` steps in the `.lock.yml`, then `gh aw compile --approve` and commit.

What changes:

- The builder's PR, pushes, comments (`Builder question:`) and dispatches show the app as author instead of `github-actions[bot]`. The other workflows treat both as bot accounts.
- Events made by the app do start workflows. That is the point for CI; `wf-delivery` ignores bot comments, so no loop starts.
- Check it: on a builder PR the **Checks** tab shows your CI. In the repo **Actions** tab the CI run for the last (empty) commit has the app as actor, not `github-actions[bot]`. Not verified against a live run here.

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

`gh aw compile` stops on `retro` with *safe update mode detected unapproved changes, New restricted secret(s): AW_CORE_ISSUES_TOKEN*. That is the expected gate for a new secret: check that `AW_CORE_ISSUES_TOKEN` is only used as `github-token` of `create-issue` in `retro.md`, then run `gh aw compile --approve` and commit the `.lock.yml`.

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

### Private NuGet feed (C# repos)

Add [`shared/nuget-auth.md`](../workflows/shared/nuget-auth.md) under `imports:` in your copy of `issue-builder.md` (it is opt-in, so non-C# repos carry no NuGet secret or `dotnet` network). When the repo has a `.sln`, `.slnx` or `.csproj`, a step before the agent adds your feed as a NuGet source with the secret and runs `dotnet restore`, so `dotnet build` and `dotnet test` resolve private packages. No C# project: the step does nothing. Feed variables unset: restore uses public sources only.

1. Create a read-only token for the feed. GitHub Packages: classic PAT with `read:packages`. Azure Artifacts: PAT with Packaging (Read). Use a service account, not a person, and set an expiry.
2. Store it. `gh` asks for the value:

```bash
gh secret set NUGET_FEED_TOKEN --repo <org>/<target-repo>
gh variable set NUGET_FEED_URL --repo <org>/<target-repo> --body "https://nuget.pkg.github.com/<org>/index.json"
gh variable set NUGET_FEED_USER --repo <org>/<target-repo> --body "<service-account-user>"
```

3. Allow the feed host. Network is closed except `dotnet` defaults, so add the host under `network.allowed` in your copy of `issue-builder.md` (for example `nuget.pkg.github.com`, or `pkgs.dev.azure.com`), then `gh aw compile`.
4. Compile asks you to approve the new secret: `gh aw compile --approve`. Read the diff first, then commit the `.lock.yml`.

The token is on the runner only during the pre-agent restore. A `finally` block removes the feed source afterwards, so the agent never sees the token on disk or in its environment. Restored packages stay in the NuGet cache, so build and test work; adding a new private package needs a human PR. Still use a read-only, feed-scoped token on a service account with an expiry. Not verified against a live run: check that the agent's sandbox sees the cache but not the config entry.

### `dotnet format` hook

A Copilot `postToolUse` hook formats each `.cs` file right after the agent edits it. It lives in [`hooks/`](../hooks/README.md), not in a workflow: copy it into the target repo and commit it.

```bash
mkdir -p .github/hooks
cp hooks/dotnet-format/dotnet-format.* .github/hooks/
git add .github/hooks && git commit -m "add dotnet format hook"
```

`issue-builder` also tells the agent to format after shell rewrites and to run `dotnet format --verify-no-changes` before pushing, as a fallback. Not verified against a live run. For a hard guarantee add `dotnet format --verify-no-changes` to the repo's own CI.

### Custom MCP server

A local C# MCP server (stdio) runs on the runner next to the agent. [`shared/csharp-mcp.md`](../workflows/shared/csharp-mcp.md) registers it and tells the agent what it is for. It is not imported by default, because the project path is yours. In your copy of `issue-builder.md` (and `pr-reviewer.md` if it needs the tools), add it under `imports:`:

```yaml
imports:
  - uses: shared/csharp-mcp.md
    with:
      name: domain-rules
      project: tools/MyMcp
      purpose: it answers domain-rule questions, for example pricing rules.
```

- It builds from the checked-out repo with `dotnet run --project <project>`, which restores through the feed the NuGet step configured. Add the feed host under `network.allowed` as for the builder.
- The `purpose` line goes into the prompt. Tool names alone rarely make the agent reach for it, so say when to call it.
- A server needing a secret cannot take it through `env:`: gh-aw strict mode rejects secrets in agent environment. Give the server read-only access that does not need one, or ask for a design with a pre-agent step.
- Add any host the server calls under `network.allowed`. A server that only reads the repo needs none.
- A server hosted elsewhere (HTTP) uses `url:` and `headers:` in your own `mcp-servers:` block instead of this fragment.

## 4. Labels (once per target repo)

The flow uses labels as state. Create the ones that are not there yet. By hand: open `https://github.com/<org>/<target-repo>/labels` (repo **Issues** tab → **Labels** button), click **New label**, type the name, **Create label**. Or all at once:

```bash
for l in triage bug wayfinder security needs-info duplicate agent-fix blocked \
         wayfinder:map to-spec specced to-tickets planned to-plan ready-for-agent \
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
2. A maintainer adds `agent-fix` the same way (right sidebar **Labels**). `bug-fix` starts `issue-builder`, which opens a PR on `builder/issue-<n>` (see the **Pull requests** tab), then `pr-reviewer` reviews it.
3. Runs: repo **Actions** tab, pick the workflow in the left list, click a run for logs. Nothing listed: the compiled `.lock.yml` files are not on the default branch yet.
4. Start one by hand: **Actions** → pick the workflow (for example `issue-builder`) → **Run workflow** button (right) → fill the inputs → green **Run workflow**. `agentic-token-audit` writes a daily cost report.

A maintainer always merges. Nothing here merges or approves.

## Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| Run fails at the Copilot step with a billing or policy error (option A) | Org policy *Copilot CLI* or *Allow use of Copilot CLI billed to the organization* is off, or the org has no Copilot plan. Or switch to option B |
| Run fails at the Copilot step with an auth error (option B) | `COPILOT_GITHUB_TOKEN` missing, expired, not fine-grained, or lacks **Copilot Requests**. Or `copilot-requests: write` is still in the workflow, so the token is ignored |
| Builder finishes but no PR | *Allow GitHub Actions to create and approve pull requests* is off |
| Builder PR shows no CI checks | No builder app: `APP_ID` or `APP_PRIVATE_KEY` unset, so it fell back to `GITHUB_TOKEN`. Or the app is not installed on this repo |
| Builder run fails at *Generate GitHub App token* | Wrong Client ID or key, or the app lacks one of the permissions in [GitHub App](#github-app-builder-prs-run-ci) |
| A label set by one workflow does not start the next | Expected: events made with `GITHUB_TOKEN` start nothing. The flow hands off by `workflow_dispatch` instead |
| `retro` fails on `create-issue` | `AW_CORE_ISSUES_TOKEN` missing, expired, or lacks Issues write on the target repo |
| `gh aw compile` complains about `dispatch-workflow` | Dispatch targets are not all in `.github/workflows/`. Install both `issue-builder` and `pr-reviewer` |

## Update

```bash
gh aw update
gh aw compile
```

Commit the result. Read the release notes of the new tag first: caps, labels and secrets can change. Option B: delete `copilot-requests: write` again before `gh aw compile`.
