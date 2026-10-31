# Agents and humans

Entry point for coding agents and maintainers working in `svennijhuis/agentic-workflows`.

## Layout

| Path | Role |
| --- | --- |
| `aw.yml` | Package manifest for `gh aw add` |
| `workflows/*.md` | Installable workflows (flat names) |
| `workflows/shared/` | Importable fragments (no `on:`) |
| `policies/` | POL rules and `policies/checks/` gates |
| `scripts/verify.sh` | Local gate (see below) |
| `test/fixtures/` | Good/bad POL fixtures |
| `governance/` | Rollout ladder, proposed rulesets (not applied) |
| `docs/` | Diataxis docs ([docs/README.md](docs/README.md)) |
| `docs/pbi/` | Backlog (Builder-owned content) |

Shared imports must stay under `workflows/shared/` because gh-aw v0.93.4 rejects paths outside `workflows/` ([layout.md](docs/reference/layout.md)).

## Verify before PR

```bash
./scripts/verify.sh
```

Must end with `0 failures` (exit 0). Exit 1 is a finding to fix; exit 2 is needs-human (a missing or wrong tool, see `.github/aw.json`). How-to: [docs/how-to/verify-workflow.md](docs/how-to/verify-workflow.md). Skill: [.github/skills/verify-aw/SKILL.md](.github/skills/verify-aw/SKILL.md).

Q0: GitHub Actions billing is blocked. Attach the verify log on the exact commit SHA to the PR.

## Rules for agents

- Never merge PRs. Never force push. Normal `git push` only when Sven or the Builder asks you to push.
- No secrets or token values in files. Secret names only ([POL04](policies/POL04.yml), [POL20](policies/POL20.yml)).
- No em dash (U+2014) or en dash (U+2013) in markdown. Plain ASCII quotes.
- Catalog workflows stay `workflow_dispatch` only until Sven's exact yes enables more triggers.
- Do not run `gh aw trial`, `gh aw run`, or other token-spending commands unless Sven gave exact yes for that run.
- Findings rule (gist A5): the same Reviewer or Tester FAIL twice on the same item, or any revert, becomes a POL check PBI in the next nF block; no prose-only lesson.

## Instruction surfaces

- [.github/copilot-instructions.md](.github/copilot-instructions.md) (repo-wide)
- [.github/instructions/aw.instructions.md](.github/instructions/aw.instructions.md) (`workflows/**`)
- [.github/instructions/policies.instructions.md](.github/instructions/policies.instructions.md) (`policies/**`, `test/fixtures/**`)
- [.github/instructions/docs.instructions.md](.github/instructions/docs.instructions.md) (`docs/**`)
- [.github/agents/aw-author.agent.md](.github/agents/aw-author.agent.md) (workflow PR helper)

Link [policies/POLnn.yml](policies/) for rules. Do not restate policy text in prompts.

## Policies and backlog

- Policies: `policies/POL01.yml` through `policies/POL29.yml`, plus `policies/POL31.yml`
- PBI index: [docs/pbi/README.md](docs/pbi/README.md)
