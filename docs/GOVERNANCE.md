# Governance

## Owners

| Surface | Owner |
| --- | --- |
| This catalog | `CODEOWNERS` |
| agentPacks | Skills, agents, standards |
| mcp-services | MCP servers |
| Consuming repos | Secrets, Actions on, `source:` pins |

## Visibility

- Repo visibility is the install boundary. `private: true` blocks `gh aw add` entirely; set it only on control-plane jobs in `.github/workflows/`, never on `workflows/` templates.
- Review triggers, permissions, tools, network, safe outputs and lock file before merging a template.

## Versions

See [CHANGELOG](../CHANGELOG.md). Exact tag for prod, moving `v1` for followers, branch only for dev. agentPacks refs are pinned by SHA or tag, never a branch.

## Cost

Defaults are 1,000 AIC/run and 5,000/day. Copilot Pro is 1,500 AIC/month, so every workflow here sets:

```yaml
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
```

Frontmatter only: the compiler ignores these keys in imported fragments. Cheapest run is no agent: `skip-if-match`, or `noop` from `steps:`. Prefer `schedule` / `workflow_dispatch` over `push`. Check spend: `gh aw logs`, `gh aw audit <run>`. Docs: [Cost Management](https://github.github.com/gh-aw/reference/cost-management/).

Org or repo wide defaults via Actions variables (`gh aw env update defaults.yml --scope repo --repo OWNER/REPO`). Keys:

```yaml
# default_max_ai_credits: "50"
# default_max_daily_ai_credits: "200"
# default_max_turns: "15"
# default_timeout_minutes: "10"
# default_model_copilot: ""
```

Precedence: frontmatter > repo var > org > enterprise > compiler fallback.

## Rollout

Report-only first (comments, no `create-pull-request`). One pilot repo. Then writes with `max: 1`. Disable by deleting the lock file.

## Control plane (later)

Only when this repo should dispatch work to other repos ([CentralRepoOps](https://github.github.com/gh-aw/patterns/central-repo-ops/)): orchestrator in `.github/workflows/` with `private: true`, read-only token, `safe-outputs.dispatch-workflow` with `max:`; worker template in `workflows/`; GitHub App scoped to targets. No copied skills, no product CI, no unattended `/squad` loops.
