# Repo-local Actions

Workflows in this directory run on `svennijhuis/agentic-workflows` itself. Installable templates live in [`../../workflows/`](../../workflows/).

| File | What |
| --- | --- |
| [verify.yml](verify.yml) | Runs [`scripts/verify.sh`](../../scripts/verify.sh). `workflow_dispatch` only (POL03); actions pinned by SHA (POL01). |

Actions is billing blocked (Q0). Until it runs again, the local `./scripts/verify.sh` log on the exact head SHA, posted as a PR comment, is the gate.

Any trigger other than `workflow_dispatch` needs the workflow name in [`governance/rollout.yml`](../../governance/rollout.yml), which needs Sven's exact yes.
