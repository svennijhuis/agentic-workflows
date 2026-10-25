# loops: overview

**Purpose:** LP00 finds work, LP01 delivers it, LP02 maps who starts what and guards both loops. Release ids L01-L07 stay in `release/`; loop docs use LP00-LP02 to avoid a clash.

## PBIs

- [LP00: Improvement loop](LP00-improvement-loop.md) (find work: logs to issues to fix PRs)
- [LP01: Delivery loop](LP01-delivery-loop.md) (board: plan, grill, pick up, review, merge)
- [LP02: Event map](LP02-event-map.md) (automatic and human triggers, guards, one-way doors)

## Dependency sketch

```mermaid
flowchart TD
  LP02[LP02 guards and triggers]
  LP00[LP00 improvement loop]
  LP01[LP01 delivery loop]
  M[Merged by Sven]
  LP02 -.-> LP00
  LP02 -.-> LP01
  LP00 -->|agent-ok or risk low auto path| LP01
  LP01 --> M
  LP00 --> M
```
