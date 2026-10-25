# Control plane (later)

Runnable orchestrators that dispatch work across repos live in `.github/workflows/` **in this repo**. Installable templates stay under `workflows/`.

Block 1: control-plane workflows are `workflow_dispatch` only and billing may be blocked (Q0). Local `./scripts/verify.sh` on SHA is the gate.

## When to add it

[CentralRepoOps](https://github.github.com/gh-aw/patterns/central-repo-ops/) when you need:

- One private control repo listing org repositories and dispatching workers.
- A tracker repo receiving issues from many components via `target-repo`.

Pattern:

1. Orchestrator in `.github/workflows/`: `workflow_dispatch`, `private: true`, narrow token, `safe-outputs.dispatch-workflow` with `max:`.
2. Worker template in `workflows/` (installed or dispatched with `checkout.repository`).
3. GitHub App scoped to targets (preferred over PAT).

## What not to put here

- Copies of agentPacks skills.
- Product CI for other apps.
- Unattended squad loops across every repo.

Related: [MultiRepoOps](https://github.github.com/gh-aw/patterns/multi-repo-ops/), [OrchestratorOps](https://github.github.com/gh-aw/patterns/orchestrator-ops/).
