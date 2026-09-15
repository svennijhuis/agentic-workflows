# Governance

Operational rules for an org catalog. Technical format is the easy part; ownership and pins are not.

## Who owns what

| Surface | Owner | Notes |
| --- | --- | --- |
| This catalog | Platform / you (`CODEOWNERS`) | Review `aw.yml`, `workflows/`, governance files |
| agentPacks | Same or adjacent | Plugin trust boundary; hooks run on laptops |
| mcp-services | Same or adjacent | Network and data access |
| Consuming repos | App teams | Secrets, enabling Actions, local `source:` pins |

## What may be installed where

- Keep this repository **private or internal** so only org members can `gh aw add`. That is the org boundary.
- Set `private: true` only on workflows that must not be installed anywhere (control-plane orchestrators). Catalog templates under `workflows/` must remain installable.
- Review triggers, permissions, tools, network, safe outputs, and lock files before merging a new template.

## Version pins (consumers)

Prefer exact tags (`@v1.2.0`) or SHAs in production. Moving `@v1` is for teams that run `gh aw update` on a cadence. `@main` is for catalog development.

Release process (when you have something real to ship): tag `v0.1.0` / `v1.0.0` on this repo; optionally move a `v1` ref. Document the tag in the PR that cuts it.

## Org compiler defaults

Do not bake model names and AIC budgets into every workflow. Set GitHub Actions variables at org scope.

Example keys: [`governance/defaults.example.yml`](../governance/defaults.example.yml)

```bash
# Inspect
gh aw env get org-defaults.yml --scope org --org YOUR_ORG

# Apply after editing a real (non-example) file
gh aw env update org-defaults.yml --scope org --org YOUR_ORG
```

Precedence: workflow frontmatter → repo variable → org → enterprise → compiler fallback.

Policy gates such as `GH_AW_POLICY_ALLOW_CREATE_PULL_REQUEST=false` can disable PR creation org-wide. See [Governance](https://github.github.com/gh-aw/guides/governance/) and [Compiler enterprise controls](https://github.github.com/gh-aw/reference/compiler-enterprise-environment-controls/).

## Safe rollout

Start report-only (`create-issue` / comments, no `create-pull-request`). Pilot on one repo. Then enable writes with `max: 1`. Keep a way to disable the workflow (delete lock file, or `if:` / environment protection).

Details: [Safe Rollout](https://github.github.com/gh-aw/guides/using-at-scale/) (Using at Scale) and [CentralRepoOps](https://github.github.com/gh-aw/patterns/central-repo-ops/).

## Cost

Use `max-ai-credits`, rate limits, and `gh aw outcomes` on accepted safe outputs. See [Cost Management](https://github.github.com/gh-aw/reference/cost-management/).
