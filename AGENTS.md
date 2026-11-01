# Agents and humans

Entry point for coding agents and maintainers working in `svennijhuis/agentic-workflows`.

## Layout

| Path | Role |
| --- | --- |
| `aw.yml` | Package manifest for `gh aw add` |
| `workflows/*.md` | Installable workflows (flat names) |
| `workflows/shared/` | Importable fragments (no `on:`) |
| `policies/` | POL25, POL31 and `policies/checks/` gates |
| `Makefile` | `make compile`, `make verify` |
| `scripts/verify.sh` | Called by `make verify` (see below) |
| `test/fixtures/` | Good/bad fixtures for POL25 and POL31 |
| `governance/` | Rollout ladder, proposed rulesets (not applied) |
| `docs/` | Diataxis docs ([docs/README.md](docs/README.md)) |
| `docs/pbi/` | Backlog (Builder-owned content) |

Shared imports must stay under `workflows/shared/` because gh-aw v0.93.4 rejects paths outside `workflows/` ([layout.md](docs/reference/layout.md)).

## Verify before PR

```bash
make verify
```

Must end with `0 failures` (exit 0). Exit 1 is a finding to fix (a wrong or missing gh-aw pin also fails `make compile`: run `make install`). How-to: [docs/how-to/verify-workflow.md](docs/how-to/verify-workflow.md). Skill: [.github/skills/verify-aw/SKILL.md](.github/skills/verify-aw/SKILL.md).

Q0: GitHub Actions billing is blocked. Attach the verify log on the exact commit SHA to the PR.

## Rules for agents

- Never merge PRs. Never force push. Normal `git push` only when Sven or the Builder asks you to push.
- No secrets or token values in files. Secret names only.
- No em dash (U+2014) or en dash (U+2013) in markdown. Plain ASCII quotes.
- Catalog workflows stay `workflow_dispatch` only until Sven's exact yes enables more triggers ([POL25](policies/POL25.yml)).
- Do not run `gh aw trial`, `gh aw run`, or other token-spending commands unless Sven gave exact yes for that run.
- Findings rule (gist A5): the same Reviewer or Tester FAIL twice on the same item, or any revert, becomes a frontmatter rule in the workflow, or a repo check PBI only when `gh aw compile --strict` cannot catch it; no prose-only lesson.

## Instruction surfaces

- [.github/copilot-instructions.md](.github/copilot-instructions.md) (repo-wide)
- [.github/instructions/aw.instructions.md](.github/instructions/aw.instructions.md) (`workflows/**`)
- [.github/instructions/policies.instructions.md](.github/instructions/policies.instructions.md) (`policies/**`, `test/fixtures/**`)
- [.github/instructions/docs.instructions.md](.github/instructions/docs.instructions.md) (`docs/**`)
- [.github/agents/aw-author.agent.md](.github/agents/aw-author.agent.md) (workflow PR helper)

Link [policies/POL25.yml](policies/POL25.yml) and [policies/POL31.yml](policies/POL31.yml) for repo-only rules. Other constraints live in workflow frontmatter; `gh aw compile --strict` covers the rest.

## Policies

- [POL25](policies/POL25.yml): agentic workflows are `workflow_dispatch` only.
- [POL31](policies/POL31.yml): no `skills:` in a `workflows/shared/` fragment.
- PBI index: [docs/pbi/README.md](docs/pbi/README.md)
