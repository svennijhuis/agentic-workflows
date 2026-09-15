# Repo-local Actions

Workflows in **this** directory run on `svennijhuis/agentic-workflows` itself.

Do not put installable templates here. Those belong in [`../../workflows/`](../../workflows/) so other repos can `gh aw add` them.

`validate-catalog.yml` is ordinary Actions CI for this repo (compile check). It is not an agentic workflow and is not listed in `aw.yml`.

Add orchestrator Markdown here only when this catalog becomes a [control plane](../../docs/CONTROL-PLANE.md). Mark those files `private: true` so they are not installed into product repos.
