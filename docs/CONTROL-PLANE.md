# Control plane (later)

Empty on purpose. Put **runnable** orchestrators here only when this repository should dispatch work across other repos.

Until then, keep installable templates under [`workflows/`](../workflows/) and leave [`.github/workflows/`](../.github/workflows/) unused so Actions in *this* repo stays quiet.

## When to add it

Use [CentralRepoOps](https://github.github.com/gh-aw/patterns/central-repo-ops/) when you need:

- One private control repo that lists org repositories and dispatches per-repo workers (rollouts, policy, security patches).
- Or a tracker repo that receives issues from many components via `target-repo`.

Pattern:

1. Orchestrator workflow in **this** repo (`.github/workflows/`): `on.schedule`, `private: true`, read-only GitHub token, `safe-outputs.dispatch-workflow` with a `max:`.
2. Worker template in `workflows/` (installed into targets **or** dispatched with `checkout.repository` + `create-pull-request.target-repo`).
3. GitHub App (not a PAT) scoped to the target repositories.

Keep orchestrator permissions narrow; workers do writes.

## What not to put here

- Copies of agentPacks skills.
- Product CI for other applications.
- Unattended `squad` loops against every repo.

Related: [MultiRepoOps](https://github.github.com/gh-aw/patterns/multi-repo-ops/), [OrchestratorOps](https://github.github.com/gh-aw/patterns/orchestrator-ops/).
