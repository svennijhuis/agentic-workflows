# AO14: NIST mapping doc
- Status: todo
- Area: agent-ops
- Wave: W5
- Block: 5
- Lane: Builder
- Depends on: AO01-AO13
- proof: docs/compliance/nist-ai-rmf-mapping.md merged; every AO row and catalog control has Govern, Map, Measure, or Manage filled
- door: two-way
## Goal
Map each AO PBI and catalog gate (`make verify`, workflow frontmatter rules) to NIST AI RMF functions: Govern, Map, Measure, or Manage, for org-ready audits (S11).
## Context
Static doc updated when AO PBIs or the verify gate change. No agent workflow required. Supports G05 org switch narrative.
## Steps
1. Create `docs/compliance/nist-ai-rmf-mapping.md` table.
2. Row per AO01-AO14 plus rows for compile strict, POL25, POL31, and Bar H controls with primary function and notes.
3. Link to source NIST AI 600-1 sections where helpful.
4. Reviewer checks mapping on any new POL or AO PR.
## Definition of Done
- [ ] AO ids listed
- [ ] Catalog gate rows listed (compile strict, POL25, POL31)
- [ ] Each row has Govern, Map, Measure, or Manage
- [ ] Links to AO markdown PBIs resolve
## Technical design
- Components and files: `docs/compliance/nist-ai-rmf-mapping.md`, index link from agent-ops overview.
- Interfaces: none; markdown table for auditors.
- Sequence:

```mermaid
sequenceDiagram
  participant M as maintainer PR
  participant T as mapping table
  participant A as auditor
  M->>T: add row for new control
  A->>T: read Govern Map Measure Manage
```

- Failure modes: stale row; AO or gate change requires mapping update in same PR.
- Security: no secrets in compliance doc.
- Observability: git history shows mapping changes.
- Cost: 0 AIC.
- Rollback: revert mapping PR.
- Proof: file exists; spot-check 5 rows against NIST doc.
- Door: two-way (mapping evolves with catalog).
## Evidence
(mapping PR link; reviewer sign-off in PR description)
## Flow
```mermaid
flowchart LR
  POL[compile strict POL25 POL31] --> MAP[NIST mapping table]
  AO[AO PBIs] --> MAP
  MAP --> AUD[org audit pack]
```
## Named asks for Sven
Optional external audit date (calendar)
## Cost
0 AIC
## Sources
- S11: [NIST AI 600-1](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence) (July 2024)
- Plan v3.7 agent-ops pack (agentic-workflows-pbi-plan.md)
