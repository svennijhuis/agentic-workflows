---
applyTo: "policies/**,test/fixtures/**"
---

# Policies and fixtures

Each policy has `policies/POLnn.yml` (human rule + why) and `policies/checks/POLnn.sh` (gate). Shared helpers: `policies/checks/lib.sh`.

## Edit workflow

1. Change `policies/POLnn.yml` if the rule changed.
2. Update `policies/checks/POLnn.sh` to match.
3. Update `test/fixtures/bad/POLnn.md` (or `test/fixtures/bad/POL17/` folder) so the bad case still fails.
4. Update paired `test/fixtures/good/POLnn.md` if needed.
5. Run `./scripts/verify.sh`.

POL23 meta check: every check must fail on its bad fixture and pass on good ([POL23](../../policies/POL23.yml)).

## Test one check

```bash
bash policies/checks/POLnn.sh test/fixtures/bad/POLnn.md
bash policies/checks/POLnn.sh test/fixtures/good/POLnn.md
```

## Cross-links

- [docs.instructions.md](docs.instructions.md)
- [AGENTS.md](../../AGENTS.md)
- PBI index [docs/pbi/policies/00-overview.md](../../docs/pbi/policies/00-overview.md)

Do not embed secrets or real tokens in fixtures ([POL04](../../policies/POL04.yml), [POL20](../../policies/POL20.yml)).
