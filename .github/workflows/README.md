# Repo-local Actions

Workflows in this directory run on `svennijhuis/agentic-workflows` itself. Installable templates live in [`../../workflows/`](../../workflows/).

| File | What |
| --- | --- |
| [verify.yml](verify.yml) | `make verify` (compile, POL25, POL31, fixtures). `workflow_dispatch` only. Installs pinned gh-aw, yq and gitleaks from [`.github/aw.json`](../../.github/aw.json). |

Actions billing is blocked (Q0). Until it runs again, post the local `make verify` log on the exact head SHA as a PR comment.

Any trigger other than `workflow_dispatch` on catalog workflows needs Sven's exact yes and an entry in [`governance/rollout.yml`](../../governance/rollout.yml).
