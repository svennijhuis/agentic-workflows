# architecture: overview

**Purpose:** G00 org-ready architecture: six linked pages (ARC01-ARC06) that describe containers, repo topology, identity, safe outputs, release, and the org switch. They are the expanded G00 anchor for consumers, C04 auth, and LP02 guards. Facts on gh-aw security layers come from the [GitHub security architecture blog](https://github.blog/ai-and-ml/generative-ai/under-the-hood-security-architecture-of-github-agentic-workflows/) and [safe outputs reference](https://github.github.com/gh-aw/reference/safe-outputs/) (read 2026-10-25).

ARC07 harness model (glossary and layers): [../../explanation/harness-model.md](../../explanation/harness-model.md), PBI [ARC07](../done/ARC07-harness-model.md). ARC08 template field: [ARC08](../done/ARC08-module-boundary-feedback-loop.md).

## PBIs

- [ARC01: Context and containers](../done/ARC01-context.md)
- [ARC02: Repo topology](../done/ARC02-repo-topology.md)
- [ARC03: Identity and auth](../done/ARC03-identity-auth.md)
- [ARC04: Safe output flow](../done/ARC04-safe-output-flow.md)
- [ARC05: Release flow](../done/ARC05-release-flow.md)
- [ARC06: Org switch](../done/ARC06-org-switch.md)

Related governance: [G00-org-target-structure](../done/G00-org-target-structure.md), [G05-org-only-appendix](../done/G05-org-only-appendix.md).

## Dependency sketch

```mermaid
flowchart LR
  G00[G00 governance] --> ARC01[ARC01 context]
  ARC01 --> ARC02[ARC02 topology]
  ARC02 --> ARC03[ARC03 identity]
  ARC03 --> ARC04[ARC04 safe outputs]
  ARC04 --> ARC05[ARC05 release]
  ARC05 --> ARC06[ARC06 org switch]
  ARC03 --> C04[C04 auth doc]
  ARC04 --> M05[M05 cross-repo]
  ARC05 --> X07[X07 benchmark]
```
