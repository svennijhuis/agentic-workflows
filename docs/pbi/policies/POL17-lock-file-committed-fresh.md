# POL17: Lock file committed and fresh
- Status: todo
- Area: policies
- Wave: W1
- Block: 1
- Lane: Cursor CLI
- Depends on: C01, C05
- proof: bash policies/checks/POL17.sh test/fixtures/bad/POL17.md (must exit 1); bash policies/checks/POL17.sh test/fixtures/good/POL17.md (exit 0); ./scripts/verify.sh includes POL17
- door: two-way
## Goal
Encode lock file committed and fresh as policy-as-code: `policies/POL17.yml`, gate script `policies/checks/POL17.sh`, and bad fixture `test/fixtures/bad/POL17.md`, enforced by C01.
## Context
Every compiled workflow commits `.lock.yml` and lock SHA must match `gh aw compile` output. Personal account catalog; org-ready rulesets in G05 may mirror these checks later.

Policy text: Drift between source `.md` and `.lock.yml` fails the gate.

`policies/checks/POL17.sh` behaviour: Run compile dry-run or diff lock SHAs; fail on mismatch.

Bad fixture `test/fixtures/bad/POL17.md`: Description of stale lock relative to imports (used in fixture tests).
## Steps
1. Write `policies/POL17.yml` with machine-readable rules.
2. Implement `policies/checks/POL17.sh` (bash, exit codes, clear stderr).
3. Add `test/fixtures/bad/POL17.md` triggering a single failure.
4. Add matching good coverage in `test/fixtures/good/` where needed.
5. Register check in `scripts/verify.sh`.
## Definition of Done
- [ ] Policy YAML, check script, and bad fixture exist for POL17
- [ ] `policies/checks/POL17.sh` fails on bad fixture and passes on good catalog
- [ ] Policy text included in this PBI and in `shared/policies/` or `policies/` doc
- [ ] Gate log on SHA shows POL17 executed
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant G as scripts/verify.sh
  participant P as policies/checks/POL17.sh
  participant F as test/fixtures/bad/POL17.md
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
