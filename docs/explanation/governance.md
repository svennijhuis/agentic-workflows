# Governance

Operational rules for the catalog. Format is easy; ownership and pins are not.

## Who owns what

| Surface | Owner | Notes |
| --- | --- | --- |
| This catalog | Sven (`CODEOWNERS`) | `aw.yml`, `workflows/`, `policies/` |
| agentPacks | Adjacent | Plugin trust on laptops |
| mcp-services | Adjacent | Network and data access |
| Consumer repos | App teams | Secrets, Actions enablement, local pins |

## What may be installed

- Keep the catalog **private or internal** so only members can `gh aw add`.
- `private: true` on a catalog workflow blocks install; use only for non-installable control-plane jobs.
- Review triggers, permissions, tools, network, safe outputs, and locks before merge.

## Version pins

Production: exact tags (`@v1.0.0`) or audit SHAs ([POL01](../../policies/POL01.yml)). `@main` is never for production; POL01 rejects it. Moving `@v1` is optional after Block 2 tags land.

Release: tag `vX.Y.Z`, document in [CHANGELOG](../../CHANGELOG.md) and [pins](../reference/pins.md).

## Org compiler defaults

Do not bake model names and AIC budgets into every workflow when org vars exist.

```bash
gh aw env get org-defaults.yml --scope org --org YOUR_ORG
gh aw env update org-defaults.yml --scope org --org YOUR_ORG
```

Precedence: workflow frontmatter, then repo, org, enterprise, compiler fallback. Org-only features stay in [G05](../pbi/governance/G05-org-only-appendix.md) until switch.

## Safe rollout

Staged or report-only first ([POL03](../../policies/POL03.yml)). Pilot one repo. Enable writes with low `max:`. Disable via environment protection or removing dispatch until fixed.

Rollout ladder file: [`governance/rollout.yml`](../../governance/rollout.yml) (Block 2+).

## Cost

Per-workflow caps in frontmatter ([POL02](../../policies/POL02.yml)). Measure AIC in trial and production ([B03a](../pbi/observability/B03a-value-vs-cost.md)).
