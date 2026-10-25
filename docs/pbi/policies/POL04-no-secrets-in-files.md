# POL04: No secrets in files
- Status: todo
- Area: policies
- Wave: W1
- Block: 1
- Lane: Cursor CLI
- Depends on: C01
- proof: bash policies/checks/POL04.sh test/fixtures/bad/POL04.md (must exit 1); bash policies/checks/POL04.sh test/fixtures/good/POL04.md (exit 0); ./scripts/verify.sh includes POL04
- door: two-way
## Goal
Encode no secrets in files as policy-as-code: `policies/POL04.yml`, gate script `policies/checks/POL04.sh`, and bad fixture `test/fixtures/bad/POL04.md`, enforced by C01.
## Context
No API keys, PATs, private keys, or connection strings in tracked files. Use GitHub Actions secrets and masked fields for named asks. Personal account catalog; org-ready rulesets in G05 may mirror these checks later.

Policy text: Repository content must not contain high-entropy secret patterns or literal `ghp_`, `github_pat_`, `gho_` tokens.

`policies/checks/POL04.sh` behaviour: Run gitleaks or equivalent plus regex scan on `workflows/`, `shared/`, `docs/`, and `.github/`. Exit 1 on findings.

Bad fixture `test/fixtures/bad/POL04.md`: Markdown containing a fake `ghp_` example token (fixture only).
## Steps
1. Write `policies/POL04.yml` with machine-readable rules.
2. Implement `policies/checks/POL04.sh` (bash, exit codes, clear stderr).
3. Add `test/fixtures/bad/POL04.md` triggering a single failure.
4. Add matching good coverage in `test/fixtures/good/` where needed.
5. Register check in `scripts/verify.sh`.
## Definition of Done
- [ ] Policy YAML, check script, and bad fixture exist for POL04
- [ ] `policies/checks/POL04.sh` fails on bad fixture and passes on good catalog
- [ ] Policy text included in this PBI and in `shared/policies/` or `policies/` doc
- [ ] Gate log on SHA shows POL04 executed
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant G as scripts/verify.sh
  participant P as policies/checks/POL04.sh
  participant F as test/fixtures/bad/POL04.md
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
