# TPL02: Backfill template fields on the existing PBIs
- Status: todo
- Area: docs
- Wave: W2
- Block: 2
- Lane: Cursor CLI
- Depends on: TPL01
- proof: bash scripts/check-pbi-template.sh $(git ls-files 'docs/pbi/*/*.md') reports 0 hits
- door: two-way
- triage: build (mechanical, one PR)
- feedback: check-pbi-template.sh in file mode over every PBI
- harness: Cursor CLI (docs edits)
- review-input: diff + this PBI + DoD (+ linked spec) + PR description, never builder session logs (PA6)
- kind: skill
- Source: PA8 https://github.com/svennijhuis/agentPacks/pull/80 https://github.com/svennijhuis/agentic-workflows/pull/4
## Goal
Every existing PBI (about 221, plus the done moves) gets the 5 fields, `Source:` and `Module boundary:`. Then the TPL01 check can run on all PBIs, not only on the diff.
## Context
PO scope fix on PA8: TPL01 checks only new or changed PBIs; this is the backfill. Not built in PR #4: docs only, nothing enabled (PA9).
## Steps
1. Fill the fields per PBI from its own Sources section.
2. Switch verify.sh to file mode over all PBIs.
## Definition of Done
- [ ] 0 TPL01 and ARC08 hits over all PBIs
- [ ] verify.sh checks all PBIs
- [ ] G05 (`docs/pbi/done/G05-org-only-appendix.md`): `## Technical design` sits below the Definition of Done and fills the ten template fields (Components and files, Interfaces, Sequence, Failure modes, Security, Observability, Cost, Rollback, Proof, Door) (Cursor 5657406190 f3 on PR #12)
- [ ] `scripts/check-pbi-template.sh` diff mode also checks renamed (`R`) PBI files whose similarity is under 100%, so an edit plus a move into `done/` cannot escape the check; a fixture rename with an edited body gives hits (Reviewer note n1 on PR #12, comment 6424506602)
## Technical design
- Components and files: `docs/pbi/**`, `scripts/verify.sh`, `scripts/check-pbi-template.sh`
- Module boundary: the 6 header lines per PBI
- Interfaces: same as TPL01
- Sequence:

```mermaid
sequenceDiagram
  participant A as caller
  participant B as TPL02
  A->>B: input
  B-->>A: result or file:line hits
```

- Failure modes: A Source without a D id for a PBI that predates the links: use PA8 plus the PR URL
- Security: Docs only
- Observability: verify.sh
- Cost: 0 AIC
- Rollback: Revert the PR
- Proof: same as proof: above
- Door: two-way (revert is one commit)
## Evidence
(todo)
## Flow
```mermaid
flowchart LR
  S1[Fill the fields per PBI from its own Sources section]
  S2[Switch verify.sh to file mode over all PBIs]
  S1 --> S2
```
## Named asks for Sven
none
## Cost
0 AIC
## Sources
- [agentPacks PR #80 (same 5 template fields)](https://github.com/svennijhuis/agentPacks/pull/80)
- [agentic-workflows PR #4 room (PO additions PA1 to PA9)](https://github.com/svennijhuis/agentic-workflows/pull/4)
- [Cursor review 5657406190 on PR #12 (f3)](https://github.com/svennijhuis/agentic-workflows/pull/12#pullrequestreview-5657406190) and [Reviewer comment 6424506602 (n1)](https://github.com/svennijhuis/agentic-workflows/pull/12#issuecomment-6424506602), carried by the [PO GO](https://github.com/svennijhuis/agentic-workflows/pull/12#issuecomment-6424705952)
- Strategy id list v3.12 (aw-final-ids.md), url-learnings.md PA8
