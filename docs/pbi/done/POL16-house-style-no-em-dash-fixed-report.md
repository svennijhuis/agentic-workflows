# POL16: House style (no em dash, fixed report format)
- Status: done
- PR: #4
- Area: policies
- Wave: W1
- Block: 1
- Lane: Cursor CLI
- Depends on: C01, C11
- proof: bash policies/checks/POL16.sh test/fixtures/bad/POL16.md (must exit 1); bash policies/checks/POL16.sh test/fixtures/good/POL16.md (exit 0); ./scripts/verify.sh includes POL16
- door: two-way
## Goal
Encode house style (no em dash, fixed report format) as policy-as-code: `policies/POL16.yml`, gate script `policies/checks/POL16.sh`, and bad fixture `test/fixtures/bad/POL16.md`, enforced by C01.
## Context
Markdown and reports must not contain U+2013 or U+2014; issue and PR bodies follow `shared/reporting.md` format. Personal account catalog; org-ready rulesets in G05 may mirror these checks later.

Policy text: Use ASCII hyphen or rephrase; reports use fixed headings and footers from shared reporting.

`policies/checks/POL16.sh` behaviour: Unicode dash scan on tracked md files; optional structure check against reporting template for workflow outputs.

Bad fixture `test/fixtures/bad/POL16.md`: Text containing an en dash or em dash character.
## Steps
1. Write `policies/POL16.yml` with machine-readable rules.
2. Implement `policies/checks/POL16.sh` (bash, exit codes, clear stderr).
3. Add `test/fixtures/bad/POL16.md` triggering a single failure.
4. Add matching good coverage in `test/fixtures/good/` where needed.
5. Register check in `scripts/verify.sh`.
## Definition of Done
- [ ] Policy YAML, check script, and bad fixture exist for POL16
- [ ] `policies/checks/POL16.sh` fails on bad fixture and passes on good catalog
- [ ] Policy text included in this PBI and in `shared/policies/` or `policies/` doc
- [ ] Gate log on SHA shows POL16 executed
## Technical design
- Components and files: `policies/POL16.yml` (rule + why), `policies/checks/POL16.sh`, `test/fixtures/bad/POL16.md` (shared POL design, see [00-overview.md](../policies/00-overview.md#shared-technical-design-pol01-pol23))
- Interfaces: Check gets the repo root, prints `file:line POL16 message`, exit 1 on hit; verify.sh loops all checks. This check: no em dash, report uses shared/reporting.md
- Sequence:

```mermaid
sequenceDiagram
  participant V as verify.sh
  participant P as POL16.sh
  participant F as workflows/ and shared/
  V->>P: run on repo root
  P->>F: read only
  P-->>V: file:line POL16 lines + exit code
```

- Failure modes: Tautological check that never fails, so POL23 runs it on its bad fixture `test/fixtures/bad/POL16.md` (em dash) and needs exit 1
- Security: Read-only grep or yq, no tokens, no network
- Observability: One line per hit `file:line POL16 message` in verify.sh output
- Cost: 0 AIC (script)
- Rollback: Remove POL16.sh from the verify.sh loop (the policy doc stays)
- Proof: verify.sh fails on `test/fixtures/bad/POL16.md` and passes on `test/fixtures/good/`
- Door: two-way (script)
## Evidence

Shipped in PR #4 (Block 1). Gate: `./scripts/verify.sh` log on the exact head SHA, posted as a PR comment (Q0, Actions billing blocked).
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant G as scripts/verify.sh
  participant P as policies/checks/POL16.sh
  participant F as test/fixtures/bad/POL16.md
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
