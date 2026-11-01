# Verify a change

Local gate for this catalog. Same path for Builder, Tester, and agents.

## Run the full gate

From the repo root:

```bash
make verify
```

This runs `bash scripts/verify.sh`, which:

1. **`# make compile`**: `make compile` (`gh aw compile --strict` on `workflows/` and on `.github/workflows` when it holds agentic `.md` files). Fails if lock files drift (recompile and commit `.lock.yml`).
2. **`# POL25 repo`**: repo-wide agentic dispatch check.
3. **`# POL25 fixtures`**: bad cases exit 1 with one hit; good cases exit 0 with no output.
4. **`# POL31 repo`**: no `skills:` in shared fragments.
5. **`# POL31 fixtures`**: same contract as POL25 fixtures.

Exit codes:

- `0` pass: last line `0 failures`.
- `1` fail: one line per issue as `file:line RULE message`. A missing gh-aw, or one not at the pin in `.github/aw.json`, also fails `make compile` (run `make install`).

## One check on one path

```bash
bash policies/checks/POL25.sh
bash policies/checks/POL25.sh test/fixtures/bad/POL25-no-on/smoke-run.yml   # expect exit 1
bash policies/checks/POL31.sh test/fixtures/good/POL31/workflows/squad-review.md # expect exit 0
```

Fixture folders live under `test/fixtures/bad/POL25-*`, `test/fixtures/good/POL25-*`, and `test/fixtures/{bad,good}/POL31/`.

## Q0: Actions billing blocked

Attach the full `make verify` log for the exact PR commit SHA as a PR comment. Do not treat missing CI as a pass.

## Trial command (print only)

Do not run in Block 1. Spend AIC only with Sven's exact yes per workflow.

```bash
# gh aw trial --repo <trial-repo> --workflow <workflow-name>
```

## See also

- Skill: [.github/skills/verify-aw/SKILL.md](../../.github/skills/verify-aw/SKILL.md)
- [AGENTS.md](../../AGENTS.md)
- CI: [`.github/workflows/verify.yml`](../../.github/workflows/verify.yml)
