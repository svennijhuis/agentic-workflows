# POL13: Threat detection never off
- Status: todo
- Area: policies
- Wave: W1
- Block: 1
- Lane: Cursor CLI
- Depends on: C01, S03
- proof: bash policies/checks/POL13.sh test/fixtures/bad/POL13.md (must exit 1); bash policies/checks/POL13.sh test/fixtures/good/POL13.md (exit 0); ./scripts/verify.sh includes POL13
- door: two-way
## Goal
Encode threat detection never off as policy-as-code: `policies/POL13.yml`, gate script `policies/checks/POL13.sh`, and bad fixture `test/fixtures/bad/POL13.md`, enforced by C01.
## Context
Threat detection must remain enabled for agent runs; disabling is forbidden in catalog workflows. Personal account catalog; org-ready rulesets in G05 may mirror these checks later.

Policy text: `threat-detection: off` or equivalent is a policy violation.

`policies/checks/POL13.sh` behaviour: Scan for threat detection disable flags in workflow and shared security chain.

Bad fixture `test/fixtures/bad/POL13.md`: Workflow disabling threat detection.
## Steps
1. Write `policies/POL13.yml` with machine-readable rules.
2. Implement `policies/checks/POL13.sh` (bash, exit codes, clear stderr).
3. Add `test/fixtures/bad/POL13.md` triggering a single failure.
4. Add matching good coverage in `test/fixtures/good/` where needed.
5. Register check in `scripts/verify.sh`.
## Definition of Done
- [ ] Policy YAML, check script, and bad fixture exist for POL13
- [ ] `policies/checks/POL13.sh` fails on bad fixture and passes on good catalog
- [ ] Policy text included in this PBI and in `shared/policies/` or `policies/` doc
- [ ] Gate log on SHA shows POL13 executed
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant G as scripts/verify.sh
  participant P as policies/checks/POL13.sh
  participant F as test/fixtures/bad/POL13.md
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
