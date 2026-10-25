# POL01: Pinned versions only (no @main, tag or SHA)
- Status: todo
- Area: policies
- Wave: W1
- Block: 1
- Lane: Cursor CLI
- Depends on: C01
- proof: bash policies/checks/POL01.sh test/fixtures/bad/POL01.md (must exit 1); bash policies/checks/POL01.sh test/fixtures/good/POL01.md (exit 0); ./scripts/verify.sh includes POL01
- door: two-way
## Goal
Encode pinned versions only (no @main, tag or sha) as policy-as-code: `policies/POL01.yml`, gate script `policies/checks/POL01.sh`, and bad fixture `test/fixtures/bad/POL01.md`, enforced by C01.
## Context
Workflows and imports must pin immutable refs: release tags, major tags with documented move policy, or full commit SHAs. Floating branch refs and `@main` are forbidden in catalog and consumer lock files. Personal account catalog; org-ready rulesets in G05 may mirror these checks later.

Policy text: All `uses:` imports and GitHub Actions refs in compiled workflows resolve to a tag or SHA recorded in `.lock.yml`. `@main` and unnamed branches are violations.

`policies/checks/POL01.sh` behaviour: Scan `workflows/**/*.md`, `.github/workflows/**`, and `.lock.yml` for forbidden ref patterns (`@main`, `@master`, bare branch names without tag semantics). Check both `imports:` and `plugins:` lines per C12 v1.1 (no `plugins:` main SHA). Accept `@vX.Y.Z` or 40-hex SHA of a tagged generated agentPacks commit. Exit 1 with file:line listing.

Bad fixture `test/fixtures/bad/POL01.md`: Example workflow snippet importing `@main` or marketplace branch ref.
## Steps
1. Write `policies/POL01.yml` with machine-readable rules.
2. Implement `policies/checks/POL01.sh` (bash, exit codes, clear stderr).
3. Add `test/fixtures/bad/POL01.md` triggering a single failure.
4. Add matching good coverage in `test/fixtures/good/` where needed.
5. Register check in `scripts/verify.sh`.
## Definition of Done
- [ ] Policy YAML, check script, and bad fixture exist for POL01
- [ ] `policies/checks/POL01.sh` fails on bad fixture and passes on good catalog
- [ ] Policy text included in this PBI and in `shared/policies/` or `policies/` doc
- [ ] Gate log on SHA shows POL01 executed
## Evidence
(commands, logs, verify log on SHA, run links)
## Flow
```mermaid
sequenceDiagram
  participant G as scripts/verify.sh
  participant P as policies/checks/POL01.sh
  participant F as test/fixtures/bad/POL01.md
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
