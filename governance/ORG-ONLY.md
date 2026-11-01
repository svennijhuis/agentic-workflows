# Org-only checklist (G05)

Today the catalog lives on the personal account `svennijhuis`. This file lists what changes when it moves to a GitHub org. Nothing here is enabled today; G05 writes this checklist only; no org is created or touched. Org switch is one-way and needs Sven's exact yes; rollback: do not apply the switch steps.

Related PBIs: [G05-org-only-appendix](../docs/pbi/done/G05-org-only-appendix.md), [ARC06-org-switch](../docs/pbi/done/ARC06-org-switch.md), [G00-org-target-structure](../docs/pbi/done/G00-org-target-structure.md), [C02-org-ready-layout](../docs/pbi/done/C02-org-ready-layout.md), [P01-central-repo-ops-hub](../docs/pbi/multi-repo/P01-central-repo-ops-hub.md).

## Structure

### Central repo hub

```mermaid
flowchart TB
  Hub["svennijhuis/agentic-workflows"]
  Hub --> AwYml["aw.yml (includes)"]
  Hub --> Wf["workflows/ (.md + .lock.yml + .card.yml)"]
  Hub --> Shared["workflows/shared/ (defaults, security, reporting, agentpacks, mcp, prompts)"]
  Hub --> Pol["policies/ (POL25, POL31 + checks/)"]
  Hub --> Verify["make verify"]
  Hub --> Gov["governance/ (rollout.yml, rulesets/main.json, ORG-ONLY.md)"]
  Hub --> Pbi["docs/pbi/"]
  Cons["Consumer repos"]
  Cons -->|"gh aw add svennijhuis/agentic-workflows/#lt;wf#gt;@vX.Y.Z (vX.Y.Z tag or 40-hex SHA, never a branch, import-schema inputs only)"| Hub
  Cons -.->|"P01 later work: hub pulls signals from consumer repos (Block 5, todo, Sven's yes)"| Hub
```

### Personal now vs org later

```mermaid
flowchart LR
  subgraph Now["personal now"]
    n1["owner: svennijhuis"]
    n2["engine auth: PAT"]
    n3["rulesets: repo rulesets"]
    n4["secrets: repo secrets"]
    n5["board: user Project"]
    n6["CODEOWNERS: Sven"]
    n7["teams: none"]
  end
  subgraph Later["org later"]
    o1["owner: #lt;org#gt; (Q2)"]
    o2["engine auth: GitHub App + org Copilot billing"]
    o3["rulesets: org rulesets"]
    o4["secrets: org secrets, selected repos"]
    o5["board: org Project"]
    o6["CODEOWNERS: team"]
    o7["teams: aw-maintainers, aw-consumers"]
  end
  n1 ==> o1
  n2 ==> o2
  n3 ==> o3
  n4 ==> o4
  n5 ==> o5
  n6 ==> o6
  n7 ==> o7
  U["unchanged: workflows/, workflows/shared/, policies/, docs/pbi/, aw.yml, import pins, make verify, gh aw add paths except owner"]
```

## Central Copilot billing

- [ ] After switch, for org billing (AI Credits on the org Copilot tenant, per [gh-aw billing](https://github.github.com/gh-aw/reference/billing/)), all of these in one change: enable the org Copilot CLI billing policy (Organization, Settings, Copilot, Policies, Copilot CLI, "Allow use of Copilot CLI billed to the organization"); change `permissions.copilot-requests` from `none` to `write` in each workflow; recompile with `gh aw compile` and commit the updated `.lock.yml`. Without all of these, workflows stay on `none` (seat or PAT billing).
- [ ] Until switch, keep every catalog workflow on `copilot-requests: none` (personal account; org Copilot billing is not used).

## Rulesets

- [ ] Apply [governance/rulesets/main.json](rulesets/main.json) on the default branch (proposed today, not applied on the personal account). As written it has `enforcement: active` (enforces as soon as it is created), rules `deletion` and `non_fast_forward`, and a `pull_request` rule with squash as the only merge method, `required_review_thread_resolution: true`, `dismiss_stale_reviews_on_push: true`, `required_approving_review_count: 0` (no approving review required) and `require_code_owner_review: false` (code-owner review off). Raise the review count or turn on code-owner review only with Sven's yes, once teams exist.
- [ ] Require the verify check from [C01](../docs/pbi/done/C01-verify-script.md) on every PR to the catalog and AW consumer repos (job runs `make verify` in [`.github/workflows/verify.yml`](../.github/workflows/verify.yml)).
- [ ] No force push: the `non_fast_forward` rule in the same ruleset file covers this at org level for the catalog and AW consumer repos.

## Org secrets

- [ ] Store provider trigger credentials in org secrets for [R06](../docs/pbi/triggers/R06-provider-triggers.md) (Jira, Linear, Azure DevOps), not in repo files (secret names only).
- [ ] Share cross-repo tokens via org secrets with selected repos to avoid per-repo PAT sprawl (pairs with GitHub App path in [ARC03](../docs/pbi/done/ARC03-identity-auth.md)).
- [ ] Document secret names in workflow cards and PBI evidence; never commit values.

## Teams

- [ ] Map [.github/CODEOWNERS](../.github/CODEOWNERS) paths (`*`, `/aw.yml`, `/workflows/`, `/governance/`, `/.github/`, all `@svennijhuis` today; the file says to replace them with team handles in an org) to a maintainer team (for example `@<org>/aw-maintainers` per [ARC06](../docs/pbi/done/ARC06-org-switch.md)).
- [ ] Add consumer-facing team (`aw-consumers`) when org Projects and hub workflows need it ([P01](../docs/pbi/multi-repo/P01-central-repo-ops-hub.md) Block 5).
- [ ] Repo visibility (Q2): open, waits on Sven's answer.

## GHES

- [ ] Read [Enterprise configuration](https://github.github.com/gh-aw/reference/enterprise-configuration/) for enterprise host options and compiler enterprise controls; reference only until GHES is needed.
- [ ] Nothing GHES or enterprise is used on the personal account today; open this section only when an enterprise host is needed.

## Q2 decision

Q2 (visibility and org name): open. Recorded here when Sven answers.

Nothing else changes at switch: no catalog layout, workflow behavior, or C12 pin rules change; only the owner string and the boxes above.
