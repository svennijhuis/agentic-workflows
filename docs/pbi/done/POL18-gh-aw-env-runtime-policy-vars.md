# POL18: gh aw env runtime policy vars
- Status: done
- PR: #4
- Area: policies
- Wave: W1
- Block: 1
- Lane: Cursor CLI
- Depends on: C01
- proof: bash policies/checks/POL18.sh test/fixtures/bad/POL18.md (must exit 1); bash policies/checks/POL18.sh test/fixtures/good/POL18.md (exit 0); ./scripts/verify.sh includes POL18
- door: two-way
## Goal
Encode gh aw env runtime policy vars as policy-as-code: `policies/POL18.yml`, gate script `policies/checks/POL18.sh`, and bad fixture `test/fixtures/bad/POL18.md`, enforced by C01.
## Context
Runtime policy variables exposed via `gh aw env` must match documented policy defaults and must not weaken caps in consumer repos. Personal account catalog; org-ready rulesets in G05 may mirror these checks later.

Policy text: Document allowed env overrides; sensitive vars only via GitHub Actions secrets.

`policies/checks/POL18.sh` behaviour: Compare documented env policy map to workflow env stanzas; fail on unknown override keys.

Bad fixture `test/fixtures/bad/POL18.md`: Workflow setting MAX_AI_CREDITS above policy via env.
## Steps
1. Write `policies/POL18.yml` with machine-readable rules.
2. Implement `policies/checks/POL18.sh` (bash, exit codes, clear stderr).
3. Add `test/fixtures/bad/POL18.md` triggering a single failure.
4. Add matching good coverage in `test/fixtures/good/` where needed.
5. Register check in `scripts/verify.sh`.
## Definition of Done
- [ ] Policy YAML, check script, and bad fixture exist for POL18
- [ ] `policies/checks/POL18.sh` fails on bad fixture and passes on good catalog
- [ ] Policy text included in this PBI and in `shared/policies/` or `policies/` doc
- [ ] Gate log on SHA shows POL18 executed
## Technical design
- Components and files: `policies/POL18.yml` (rule + why), `policies/checks/POL18.sh`, `test/fixtures/bad/POL18.md` (shared POL design, see [00-overview.md](../policies/00-overview.md#shared-technical-design-pol01-pol23))
- Interfaces: Check gets the repo root, prints `file:line POL18 message`, exit 1 on hit; verify.sh loops all checks. This check: required `gh aw env` vars documented in workflow
- Sequence:

```mermaid
sequenceDiagram
  participant V as verify.sh
  participant P as POL18.sh
  participant F as workflows/ and shared/
  V->>P: run on repo root
  P->>F: read only
  P-->>V: file:line POL18 lines + exit code
```

- Failure modes: Tautological check that never fails, so POL23 runs it on its bad fixture `test/fixtures/bad/POL18.md` (undocumented var) and needs exit 1
- Security: Read-only grep or yq, no tokens, no network
- Observability: One line per hit `file:line POL18 message` in verify.sh output
- Cost: 0 AIC (script)
- Rollback: Remove POL18.sh from the verify.sh loop (the policy doc stays)
- Proof: verify.sh fails on `test/fixtures/bad/POL18.md` and passes on `test/fixtures/good/`
- Door: two-way (script)
## Evidence

Shipped in PR #4 (Block 1). Gate: `./scripts/verify.sh` log on the exact head SHA, posted as a PR comment (Q0, Actions billing blocked).
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant G as scripts/verify.sh
  participant P as policies/checks/POL18.sh
  participant F as test/fixtures/bad/POL18.md
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
