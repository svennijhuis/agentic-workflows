# G00: Org target structure
- Status: todo
- Area: governance
- Wave: W1
- Block: 1
- Lane: Cursor CLI
- Depends on: none
- proof: test -f docs/pbi/governance/G00-org-target-structure.md && grep -q '## Definition of Done' docs/pbi/governance/G00-org-target-structure.md
- door: two-way
## Goal
Document the org-ready target structure before C02 lands: layout, naming, versioning, `import-schema` parameter seams, and auth seams (PAT now, GitHub App later). Owner is one variable; nothing else changes at org switch except G05 checklist items.
## Context
Plan v3.8: G00 is expanded into the six architecture pages [ARC01](../architecture/ARC01-context.md) context, [ARC02](../architecture/ARC02-repo-topology.md) topology, [ARC03](../architecture/ARC03-identity-auth.md) identity, [ARC04](../architecture/ARC04-safe-output-flow.md) safe-output flow (incl. cross-repo M05), [ARC05](../architecture/ARC05-release-flow.md) release and [ARC06](../architecture/ARC06-org-switch.md) org switch; overview in [architecture/00-overview.md](../architecture/00-overview.md). Plan v3.1 item 1. Matches gh-aw Recommended Enterprise Pattern: `aw.yml`, flat `workflows/<name>.md`, root `shared/`, `policies/`, `scripts/verify.sh`, consumer `gh aw add svennijhuis/agentic-workflows/<wf>@<tag>`. Tags are stable releases; branches are dev only. RACI ties to G02; rollout ladder to G01.
## Steps
1. Publish governance target doc (or extend RACI.md) with directory tree matching plan C02.
2. Define naming: workflow file slug equals install name; labels in `aw.yml` for discovery.
3. Versioning: semver tags on catalog; moving `v1` policy in L01 (Q7); never install from branch.
4. Document `import-schema` inputs as the only consumer customization surface (pairs with G00a).
5. Auth seams: `COPILOT_GITHUB_TOKEN` fine-grained PAT today (C04); GitHub App path documented, not required (Q3).
6. Cross-link G05 as org-only delta checklist only.
## Definition of Done
- [ ] Layout and naming documented and aligned with C02 DoD
- [ ] Versioning and tag rules reference L01 and POL01
- [ ] Auth seams documented without secrets in repo
- [ ] Mermaid flow shows consumer install path
- [ ] ARC01-ARC06 pages exist, each with a mermaid diagram that renders on GitHub
## Technical design
- Components and files: `docs/pbi/architecture/ARC01-context.md` to `ARC06-org-switch.md` (6 pages, one mermaid each)
- Interfaces: None (docs). ARC03 token table is the input for C04; ARC06 is the input for G05
- Sequence:

```mermaid
sequenceDiagram
  participant G as G00
  participant A as ARC01-ARC06
  participant C as C04 auth
  participant R as Reviewer
  G->>A: owns 6 pages
  A->>C: ARC03 token table
  R->>A: checks diagrams on change
```

- Failure modes: Docs drift from the code, so ARC05 release flow links the pages and Reviewer checks diagrams on every change
- Security: ARC03 token table is the single source for C04; no secret values in docs (POL20)
- Observability: n/a for runtime; GitHub renders each mermaid block
- Cost: 0 AIC (docs)
- Rollback: Revert the PR
- Proof: All 6 ARC pages render on GitHub
- Door: two-way (docs)
## Evidence
(links to governance docs, verify log on SHA when C02 merges)
## Flow
```mermaid
sequenceDiagram
  participant Sven as svennijhuis
  participant Cat as agentic-workflows
  participant Con as consumer repo
  Sven->>Cat: tag vX.Y.Z on catalog
  Con->>Cat: gh aw add owner/wf@vX.Y.Z
  Cat-->>Con: workflow + pinned imports
  Note over Con: import-schema inputs only
```
## Named asks for Sven
none
## Cost
n/a
## Sources
- https://github.github.com/gh-aw/guides/sharing-workflows/
- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- Plan v3.1 G00
