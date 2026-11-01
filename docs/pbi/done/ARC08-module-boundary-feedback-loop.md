# ARC08: Template field: module boundary and feedback loop
- Status: done
- PR: #4
- Area: architecture
- Wave: W1
- Block: 1
- Lane: Builder
- Depends on: TPL01
- proof: `make verify` (exit 0); `_template.md` documents both fields
- door: two-way
- triage: build (template change with Reviewer bar)
- feedback: Reviewer FAIL when `Module boundary:` or `feedback:` is empty on a PBI PR
- harness: none (docs)
- review-input: diff + this PBI + DoD (+ linked spec) + PR description, never builder session logs (PA6)
- kind: script
- Source: D38 https://x.com/mattpocockuk/status/2112184048248336654
## Goal
`docs/pbi/_template.md` gets `- Module boundary:` in Technical design (deep modules) and the `- feedback:` field names the feedback loop (the test or check that tells the agent it is done). An empty field is a Reviewer FAIL.
## Context
Matt Pocock's map puts "Deep modules" and "Tests and types as feedback loops" in The Environment. The feedback loop field is the TPL01 `feedback:` field, so there is one field, not two.
## Steps
1. Add `- Module boundary:` to `_template.md` Technical design.
2. Describe `feedback:` as the feedback loop in the template.
## Definition of Done
- [x] Template has both fields
- [x] Reviewer FAIL on empty module boundary or empty feedback
- [x] Every new or changed PBI in this PR has both filled
## Technical design
- Components and files: `docs/pbi/_template.md`
- Module boundary: two template lines are the interface; Reviewer enforces on PBI PRs
- Interfaces: Lines `- Module boundary: <text>` and `- feedback: <command>`
- Sequence:

```mermaid
sequenceDiagram
  participant A as caller
  participant B as ARC08
  A->>B: input
  B-->>A: result or file:line hits
```

- Failure modes: A `<placeholder>` counts as empty
- Security: No tokens
- Observability: PBI PR review
- Cost: 0 AIC
- Rollback: Revert the two template lines
- Proof: same as proof: above
- Door: two-way (revert is one commit)
## Evidence
Verify log on the exact head SHA of PR #4 (Q0, Actions billing blocked).
## Flow
```mermaid
flowchart LR
  S1[Add Module boundary to _template.md]
  S2[Describe feedback as the feedback loop]
  S1 --> S2
```
## Named asks for Sven
none
## Cost
0 AIC
## Sources
- [Matt Pocock, Software Factory map](https://x.com/mattpocockuk/status/2112184048248336654)
- Strategy id list v3.12 (aw-final-ids.md), url-learnings.md D38
