# POL19: No force push
- Status: todo
- Area: policies
- Wave: W1
- Block: 1
- Lane: Builder
- Depends on: C01
- proof: bash policies/checks/POL19.sh test/fixtures/bad/POL19.md (must exit 1); bash policies/checks/POL19.sh test/fixtures/good/POL19.md (exit 0); ./scripts/verify.sh includes POL19
- door: one-way
- one-way gate: Sven's exact yes required (named ask in its block). Rollback: remove ruleset change and revert automation commit
## Goal
Forbid force push, `+refs` push specs, and `--force-with-lease` in repo automation, release scripts, and documented operator procedures. Enforce via ruleset (org-ready, G05) and `policies/checks/POL19.sh`.
## Context
agentPacks generated marketplace commits must not be rewritten by force push (see agentPacks plan PBI 02). Tag moves for moving `v1` are a separate Sven decision (Q7), not a blanket force push to main.
## Steps
1. Write `policies/POL19.yml` policy text.
2. Implement `policies/checks/POL19.sh`: scan `.github/workflows/`, `scripts/`, and release docs for `--force`, `+refs`, `--force-with-lease`, and `git push --force` patterns.
3. Add `test/fixtures/bad/POL19.md` with a sample workflow step that force-pushes tags.
4. Register in `scripts/verify.sh`.
5. Document org ruleset mirror in G05.
## Definition of Done
- [ ] Policy YAML, check script, and bad fixture exist for POL19
- [ ] Check fails on bad fixture and passes on clean tree
- [ ] Policy text included in this PBI
- [ ] Verify log on SHA shows POL19 executed
## Technical design
- Components and files: `policies/POL19.yml` (rule + why), `policies/checks/POL19.sh`, `test/fixtures/bad/POL19.md` (shared POL design, see [00-overview.md](00-overview.md#shared-technical-design-pol01-pol23))
- Interfaces: Check gets the repo root, prints `file:line POL19 message`, exit 1 on hit; verify.sh loops all checks. This check: ruleset export has non_fast_forward; scripts have no `push -f`/`--force`
- Sequence:

```mermaid
sequenceDiagram
  participant V as verify.sh
  participant P as POL19.sh
  participant F as workflows/ and shared/
  V->>P: run on repo root
  P->>F: read only
  P-->>V: file:line POL19 lines + exit code
```

- Failure modes: Tautological check that never fails, so POL23 runs it on its bad fixture `test/fixtures/bad/POL19.md` (`git push --force`) and needs exit 1
- Security: Read-only grep or yq, no tokens, no network
- Observability: One line per hit `file:line POL19 message` in verify.sh output
- Cost: 0 AIC (script)
- Rollback: Remove POL19.sh from the verify.sh loop (the policy doc stays)
- Proof: verify.sh fails on `test/fixtures/bad/POL19.md` and passes on `test/fixtures/good/`
- Door: one-way for the POL19 ruleset part (Sven sets the ruleset); the check itself is two-way
## Evidence
(commands, verify log on SHA)
## Flow
```mermaid
sequenceDiagram
  participant V as scripts/verify.sh
  participant P as policies/checks/POL19.sh
  V->>P: scan automation for force push
  alt violation
    P-->>V: exit 1
  else clean
    P-->>V: exit 0
  end
```
## Named asks for Sven
Q7 (moving `v1` tag exception policy, if any)
## Cost
n/a
## Sources
- Plan v3.1 POL19
- agentPacks cloud-local plan PBI 02 (no force push on generated commit)
