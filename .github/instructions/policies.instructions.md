---
applyTo: "policies/**,test/fixtures/**"
---

# Policies and fixtures

This repo keeps two policy checks:

| Id | Rule file | Check |
| --- | --- | --- |
| POL25 | [POL25.yml](../../policies/POL25.yml) | Agentic workflows are `workflow_dispatch` only |
| POL31 | [POL31.yml](../../policies/POL31.yml) | No `skills:` in `workflows/shared/` fragments |

Shared helpers: `policies/checks/lib.sh`.

## Edit workflow

1. Change `policies/POLnn.yml` if the rule changed.
2. Update `policies/checks/POLnn.sh` to match.
3. Update `test/fixtures/bad/` and `test/fixtures/good/` for that id.
4. Run `make verify`.

Each check runs on the repo, then on fixtures: every bad case exits 1 with exactly one hit; every good case exits 0 with no output.

## Test one check

```bash
bash policies/checks/POL25.sh test/fixtures/bad/POL25-no-on/smoke-run.yml
bash policies/checks/POL31.sh test/fixtures/good/POL31/workflows/squad-review.md
```

## Cross-links

- [docs.instructions.md](docs.instructions.md)
- [AGENTS.md](../../AGENTS.md)

Do not embed secrets or real tokens in fixtures.
