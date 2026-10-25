# POL11: Least permissions, read-only agent
- Status: todo
- Area: policies
- Wave: W1
- Block: 1
- Lane: Cursor CLI
- Depends on: C01, S00
- proof: bash policies/checks/POL11.sh test/fixtures/bad/POL11.md (must exit 1); bash policies/checks/POL11.sh test/fixtures/good/POL11.md (exit 0); ./scripts/verify.sh includes POL11
- door: two-way
## Goal
Encode least permissions, read-only agent as policy-as-code: `policies/POL11.yml`, gate script `policies/checks/POL11.sh`, and bad fixture `test/fixtures/bad/POL11.md`, enforced by C01.
## Context
GitHub token permissions and agent tool posture must be read-only unless a safe-output job performs writes. Personal account catalog; org-ready rulesets in G05 may mirror these checks later.

Policy text: Agent job permissions minimal; writes only in safe-output jobs.

`policies/checks/POL11.sh` behaviour: Compare permissions blocks and tool write capabilities against policy allowlist.

Bad fixture `test/fixtures/bad/POL11.md`: Agent job with contents: write permission.
## Steps
1. Write `policies/POL11.yml` with machine-readable rules.
2. Implement `policies/checks/POL11.sh` (bash, exit codes, clear stderr).
3. Add `test/fixtures/bad/POL11.md` triggering a single failure.
4. Add matching good coverage in `test/fixtures/good/` where needed.
5. Register check in `scripts/verify.sh`.
## Definition of Done
- [ ] Policy YAML, check script, and bad fixture exist for POL11
- [ ] `policies/checks/POL11.sh` fails on bad fixture and passes on good catalog
- [ ] Policy text included in this PBI and in `shared/policies/` or `policies/` doc
- [ ] Gate log on SHA shows POL11 executed
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant G as scripts/verify.sh
  participant P as policies/checks/POL11.sh
  participant F as test/fixtures/bad/POL11.md
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
