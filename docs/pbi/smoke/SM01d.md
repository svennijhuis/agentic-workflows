# SM01d: check-smoke carry from PR #24 Tester 2 lows
- Status: todo
- Area: smoke
- Wave: W3
- Block: 3
- Lane: Builder
- Depends on: SM01b
- proof: each bad fixture in Context exits 1 with 1 hit under `bash scripts/check-smoke.sh`; each good fixture exits 0; `./scripts/verify.sh` ends with `0 failures`; both PBI checks print nothing
- door: two-way
- triage: build (Tester 2 lows on PR #24 at d836922, same on main, not blocking)
- feedback: `scripts/check-smoke.sh` exits 1 on each bad case and 0 on each good case; `./scripts/verify.sh` ends with `0 failures` (proof)
- harness: none (script)
- review-input: diff + this PBI + DoD (+ linked spec) + PR description, never builder session logs (PA6)
- kind: script (deterministic)
- Source: PA8 (Tester 2 FAIL on PR #24 at d836922, lows list) https://github.com/svennijhuis/agentic-workflows/pull/24
- Module boundary: `scripts/check-smoke.sh` only, input a smoke YAML file, output `file:line SMOKE message`, exit 0, 1 or 2
## Goal
Close the low findings Tester 2 left on PR #24, without weakening any smoke gate.
## Context
| # | Gap today | Fix |
|---|---|---|
| 1 | `/api/../admin` and `/api/%2e%2e/admin` exit 0 (path traversal on the same host) | reject `..` segments on the raw and the once-decoded path (`bad-path-dotdot.yml`, `bad-path-enc-dotdot.yml`) |
| 2 | `/https:%2f%2fevil.example` exits 0 (stays on base host) | reject a decoded path that holds a scheme (`bad-path-dec-scheme.yml`) |
| 3 | `?q=a%20b` in a query value is a hit (false positive) | allow a decoded space inside a query value, keep it banned in the path (`good-query-value-space.yml`) |
| 4 | `Authorization: Token FAKE` gives 2 hits | one hit per scalar for the scheme rules (`bad-auth-token-scheme.yml` exits 1 with 1 hit) |
## Steps
1. Extend `scripts/check-smoke.sh` per the table.
2. Add the fixtures; the verify one-hit loop picks them up.
3. Run `./scripts/verify.sh`; both PBI checks print nothing.
## Definition of Done
- [ ] Rows 1, 2 and 4 each have a bad fixture that exits 1 with 1 hit.
- [ ] Row 3 has a good fixture that exits 0.
- [ ] Every existing smoke fixture keeps its exit code and hit count.
- [ ] `./scripts/verify.sh` ends with `0 failures`; no `scripts/check-*.sh` gate weakened.
- [ ] Docs updated; no em or en dashes, no secrets.
## Named asks for Sven
- None.
## Cost
0 tokens.
