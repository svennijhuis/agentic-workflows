# POL05: min-integrity required
- Status: todo
- Area: policies
- Wave: W1
- Block: 1
- Lane: Cursor CLI
- Depends on: C01, S02
- proof: bash policies/checks/POL05.sh test/fixtures/bad/POL05.md (must exit 1); bash policies/checks/POL05.sh test/fixtures/good/POL05.md (exit 0); ./scripts/verify.sh includes POL05
- door: two-way
## Goal
Encode min-integrity required as policy-as-code: `policies/POL05.yml`, gate script `policies/checks/POL05.sh`, and bad fixture `test/fixtures/bad/POL05.md`, enforced by C01.
## Context
Workflows that read untrusted GitHub content must set `min-integrity: approved` (or stricter) per gh-aw integrity filtering. Personal account catalog; org-ready rulesets in G05 may mirror these checks later.

Policy text: Integrity level must not be lowered below `approved` for catalog workflows.

`policies/checks/POL05.sh` behaviour: Assert `min-integrity` present in security import chain and not set to permissive values.

Bad fixture `test/fixtures/bad/POL05.md`: Workflow missing min-integrity or set to none.
## Steps
1. Write `policies/POL05.yml` with machine-readable rules.
2. Implement `policies/checks/POL05.sh` (bash, exit codes, clear stderr).
3. Add `test/fixtures/bad/POL05.md` triggering a single failure.
4. Add matching good coverage in `test/fixtures/good/` where needed.
5. Register check in `scripts/verify.sh`.
## Definition of Done
- [ ] Policy YAML, check script, and bad fixture exist for POL05
- [ ] `policies/checks/POL05.sh` fails on bad fixture and passes on good catalog
- [ ] Policy text included in this PBI and in `shared/policies/` or `policies/` doc
- [ ] Gate log on SHA shows POL05 executed
## Technical design
- Components and files: `policies/POL05.yml` (rule + why), `policies/checks/POL05.sh`, `test/fixtures/bad/POL05.md` (shared POL design, see [00-overview.md](00-overview.md#shared-technical-design-pol01-pol23))
- Interfaces: Check gets the repo root, prints `file:line POL05 message`, exit 1 on hit; verify.sh loops all checks. This check: `min-integrity` set
- Sequence:

```mermaid
sequenceDiagram
  participant V as verify.sh
  participant P as POL05.sh
  participant F as workflows/ and shared/
  V->>P: run on repo root
  P->>F: read only
  P-->>V: file:line POL05 lines + exit code
```

- Failure modes: Tautological check that never fails, so POL23 runs it on its bad fixture `test/fixtures/bad/POL05.md` (key missing) and needs exit 1
- Security: Read-only grep or yq, no tokens, no network
- Observability: One line per hit `file:line POL05 message` in verify.sh output
- Cost: 0 AIC (script)
- Rollback: Remove POL05.sh from the verify.sh loop (the policy doc stays)
- Proof: verify.sh fails on `test/fixtures/bad/POL05.md` and passes on `test/fixtures/good/`
- Door: two-way (script)
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant G as scripts/verify.sh
  participant P as policies/checks/POL05.sh
  participant F as test/fixtures/bad/POL05.md
  G->>P: run check
  P->>F: optional fixture test in X03
  alt violation
    P-->>G: exit 1
  else clean tree
    P-->>G: exit 0
  end
```
## Named asks for Sven
none
## Cost
n/a
## Sources
- https://github.github.com/gh-aw/guides/sharing-workflows/
- https://github.github.com/gh-aw/reference/auth/
- https://github.github.com/gh-aw/reference/cost-management/
- https://github.github.com/gh-aw/reference/imports/
- https://github.github.com/gh-aw/reference/engines/copilot/
- https://github.github.com/svennijhuis/agentic-workflows
