# POL10: Who can trigger (on.roles, skip-bots, author association)
- Status: todo
- Area: policies
- Wave: W1
- Block: 1
- Lane: Cursor CLI
- Depends on: C01
- proof: bash policies/checks/POL10.sh test/fixtures/bad/POL10.md (must exit 1); bash policies/checks/POL10.sh test/fixtures/good/POL10.md (exit 0); ./scripts/verify.sh includes POL10
- door: two-way
## Goal
Encode who can trigger (on.roles, skip-bots, author association) as policy-as-code: `policies/POL10.yml`, gate script `policies/checks/POL10.sh`, and bad fixture `test/fixtures/bad/POL10.md`, enforced by C01.
## Context
Restrict who may start workflows using `on.roles`, skip bots, and author association rules where applicable. Personal account catalog; org-ready rulesets in G05 may mirror these checks later.

Policy text: Public repos must not allow anonymous dispatch of write-capable workflows without role checks.

`policies/checks/POL10.sh` behaviour: Validate `on` trigger guards match policy template for each trigger type.

Bad fixture `test/fixtures/bad/POL10.md`: workflow_dispatch without role guard on write workflow.
## Steps
1. Write `policies/POL10.yml` with machine-readable rules.
2. Implement `policies/checks/POL10.sh` (bash, exit codes, clear stderr).
3. Add `test/fixtures/bad/POL10.md` triggering a single failure.
4. Add matching good coverage in `test/fixtures/good/` where needed.
5. Register check in `scripts/verify.sh`.
## Definition of Done
- [ ] Policy YAML, check script, and bad fixture exist for POL10
- [ ] `policies/checks/POL10.sh` fails on bad fixture and passes on good catalog
- [ ] Policy text included in this PBI and in `shared/policies/` or `policies/` doc
- [ ] Gate log on SHA shows POL10 executed
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant G as scripts/verify.sh
  participant P as policies/checks/POL10.sh
  participant F as test/fixtures/bad/POL10.md
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
