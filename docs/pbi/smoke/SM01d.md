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
- Source: PA8 (Tester 2 FAIL on PR #24 at d836922, lows list; Cursor review 5724841554 f2 to f6 on PR #24, confirmed by Reviewer 6548976117) https://github.com/svennijhuis/agentic-workflows/pull/24 https://github.com/svennijhuis/agentic-workflows/pull/24#pullrequestreview-5724841554
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
| 5 | Cursor 5724841554 f2 high: newline plus U+2028 between `Bearer` and the value exits 0 | strip mixed newline and unicode separators before the scheme match (`bad-auth-newline-u2028.yml`) |
| 6 | Cursor 5724841554 f3 medium: a full-line comment `# ghp_FAKE...` exits 0 | run the token rules on full-line comments too (`bad-comment-full-line.yml`) |
| 7 | Cursor 5724841554 f4 medium: lowercase `token` in a comment tail exits 0 | case-insensitive scheme match in comments, allow only `token refresh` (`bad-comment-tail-lower-token.yml`, `good-token-refresh.yml` stays 0) |
| 8 | Cursor 5724841554 f5 medium: `%C2%A0` (NBSP) in the path exits 0 | treat a decoded NBSP as whitespace in the path (`bad-path-dec-nbsp.yml`) |
| 9 | Cursor 5724841554 f6 low: SM01b proof count says 17 new bad fixtures, real count 16 | fix the count in `docs/pbi/done/SM01b.md` (docs only) |
## Steps
1. Extend `scripts/check-smoke.sh` per the table.
2. Add the fixtures; the verify one-hit loop picks them up.
3. Run `./scripts/verify.sh`; both PBI checks print nothing.
## Definition of Done
- [ ] Rows 1, 2, 4, 5, 6, 7 and 8 each have a bad fixture that exits 1 with 1 hit.
- [ ] Row 3 has a good fixture that exits 0.
- [ ] Every existing smoke fixture keeps its exit code and hit count.
- [ ] `./scripts/verify.sh` ends with `0 failures`; no `scripts/check-*.sh` gate weakened.
- [ ] Row 9 count fixed. Docs updated; no em or en dashes, no secrets.
## Named asks for Sven
- None.
## Cost
0 tokens.
