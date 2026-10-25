# testing: overview

**Purpose:** Trial repo, fixtures, verification skill, evals, and the workflow benchmark harness (only benchmark PBI).

## PBIs

- [X01: X01-test-repo-trialops](X01-test-repo-trialops.md)
- [X02: X02-staged-dry-run-checklist](X02-staged-dry-run-checklist.md)
- [X03: X03-gate-fixtures](../done/X03-gate-fixtures.md)
- [X04: X04-graders-evals](X04-graders-evals.md)
- [X05: X05-wasm-playground](X05-wasm-playground.md)
- [X06: X06-verification-skill](../done/X06-verification-skill.md) (first Block 1 PBI, before C01)
- [X07: X07-workflow-benchmark](X07-workflow-benchmark.md) (harness only, Block 2)

## Dependency sketch

```mermaid
flowchart TD
  X06[X06 skill spec] --> C01[C01 verify.sh]
  X01[X01] --> X07[X07 harness]
  X01 --> X02[X02]
  X02 --> X03[X03]
  X03 --> X04[X04]
  X04 --> X05[X05]
  X07 --> L01[L01 release]
  X07 --> L02[L02 bump]
  X07 --> AO05[AO05 change mgmt]
  X07 --> C03[C03 model compare]
  X07 --> B03a[B03a value kill rule]
```
