# POL12: Explicit allowed-repos and target-repo
- Status: todo
- Area: policies
- Wave: W1
- Block: 1
- Lane: Cursor CLI
- Depends on: C01, C04
- proof: bash policies/checks/POL12.sh test/fixtures/bad/POL12.md (must exit 1); bash policies/checks/POL12.sh test/fixtures/good/POL12.md (exit 0); ./scripts/verify.sh includes POL12
- door: two-way
## Goal
Encode explicit allowed-repos and target-repo as policy-as-code: `policies/POL12.yml`, gate script `policies/checks/POL12.sh`, and bad fixture `test/fixtures/bad/POL12.md`, enforced by C01.
## Context
Cross-repo workflows must declare `target-repo` and/or `allowed-repos`; no implicit all-repos access. Personal account catalog; org-ready rulesets in G05 may mirror these checks later.

Policy text: `target-repo: '*'` requires documented runtime choice and read guards.

`policies/checks/POL12.sh` behaviour: Fail cross-repo workflows missing allowed-repos or target-repo declarations.

Bad fixture `test/fixtures/bad/POL12.md`: Cross-repo output without target-repo.
## Steps
1. Write `policies/POL12.yml` with machine-readable rules.
2. Implement `policies/checks/POL12.sh` (bash, exit codes, clear stderr).
3. Add `test/fixtures/bad/POL12.md` triggering a single failure.
4. Add matching good coverage in `test/fixtures/good/` where needed.
5. Register check in `scripts/verify.sh`.
## Definition of Done
- [ ] Policy YAML, check script, and bad fixture exist for POL12
- [ ] `policies/checks/POL12.sh` fails on bad fixture and passes on good catalog
- [ ] Policy text included in this PBI and in `shared/policies/` or `policies/` doc
- [ ] Gate log on SHA shows POL12 executed
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant G as scripts/verify.sh
  participant P as policies/checks/POL12.sh
  participant F as test/fixtures/bad/POL12.md
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
