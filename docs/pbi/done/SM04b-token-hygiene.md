# SM04b: Smoke auth check, part 2 (check-smoke-auth.sh token hygiene and PR #17 lows)
- Status: done
- PR: #22
- Area: smoke
- Wave: W3
- Block: 3
- Lane: Builder
- Depends on: SM04a (done, #17). Part of [SM04](../smoke/SM04.md); live template auth step and README chain stay in SM03b; first run probe table stays in SM03L
- proof: in the `scripts/verify.sh` smoke auth loop, `bash scripts/check-smoke-auth.sh` exits 0 on each of the 5 `test/fixtures/smoke-auth/good*.yml` and exits exactly 1 with one hit on each of the 53 `test/fixtures/smoke-auth/bad-*.yml`; `./scripts/verify.sh` ends with `0 failures`
- door: two-way
- triage: build (token hygiene part of SM04, split out by Strategy on 2026-10-26; SM04a landed parse, triggers and the OIDC environment rule in #17)
- feedback: the `scripts/verify.sh` smoke auth loop: each good fixture exits 0, each bad fixture exits 1 with exactly one `file:line SMOKEAUTH message` line
- harness: none (script)
- review-input: diff + this PBI + DoD (+ [SM04](../smoke/SM04.md), Cursor 5658105243 f1, Reviewer 6425694406 lows 1 and 2 on PR #17, Cursor 5721745072 on PR #22) + PR description, never builder session logs (PA6)
- kind: script (deterministic)
- Source: PA8 (Sven, Development Agentic Workflows room, 2026-10-25 17:48 and 17:50; split by Strategy, SM04 parts, 2026-10-26) https://github.com/svennijhuis/agentic-workflows/pull/5
## Goal
Extend `check-smoke-auth.sh` so smoke workflow YAML fails closed on secret-shaped inputs, ROPC, wrong roles, missing or late token masking, debug trace, and non-lowercase `id-token` permission values; fix duplicate-key detection so flow-style `on:` maps on one line do not false-positive.
## Context
SM04a added parse, triggers through `on_triggers`, permissions shape and the OIDC environment rule (29 bad, 3 good fixtures). SM04b adds token hygiene on every job that can mint `id-token: write` and passes the environment rule: `azure/login@v2` from `vars.AZURE_*`, a single masked `az account get-access-token` step, and bans on parsed values (comments that mention `party.*` do not trip the check).

PR #17 low 1 (Cursor 5658105243 f1, Reviewer 6425694406): duplicate keys are detected within each map node, not by `(line, key)` across sibling inline maps; `good-flow-on-line.yml` passes. Low 2: any `id-token` permission value other than exactly `write` is a hit (`bad-id-token-write.yml`).

PR #22 fix round 1 (Tester 2 comment 6540392309, Cursor 5721745072): every `get-access-token` step must mask its captured variable; token reads (printf, curl, same line as capture or mask) before `::add-mask::` are hits; yq read failures on workflow inputs, scalars, or `id-token` values exit 1; forbidden and banned values run on every step `run` and `env` scalar including multiline blocks; shell debug trace and `ACTIONS_STEP_DEBUG` true or 1 on any workflow, job, or step; `azure/login@v2` pin on every login step.

POL23 only runs `policies/checks/POLnn.sh`, so the smoke auth loop in `scripts/verify.sh` stays the proof path, like SM04a.
## Steps
1. Extend `scripts/check-smoke-auth.sh`: duplicate-key fix, id-token case rule, forbidden inputs, banned scalars and mint-job token steps.
2. Fixtures in `test/fixtures/smoke-auth/`: 5 good, 53 bad, one hit each (14 new bad in SM04b base, 10 round-1 bad on PR #22, 2 new good; existing good files gain auth steps).
3. `scripts/verify.sh` loop unchanged except the section title (SM04a+SM04b).
## Definition of Done
- [x] Duplicate keys: per-map detection (not `(line, key)` across maps); `good-flow-on-line.yml` exits 0 (Cursor 5658105243 f1, Reviewer 6425694406 low 1)
- [x] `id-token` permission values must be exactly lowercase `write` when the key is present; `bad-id-token-write.yml` exits 1 (Reviewer 6425694406 low 2)
- [x] Forbidden workflow inputs: `client_secret`, `clientSecret`, `client-secret`, `password` (`bad-client_secret.yml`, `bad-clientSecret.yml`, `bad-client-secret.yml`, `bad-password.yml`)
- [x] Banned parsed values: `grant_type=password`, `AZURE_USERNAME`, `party.*` role value, Write or Admin role request in the token step (`bad-ropc.yml`, `bad-azure-username.yml`, `bad-party-star.yml`, `bad-write-role.yml`, `bad-admin-role.yml`)
- [x] Mint job token step: `azure/login@v2` with `client-id` and `tenant-id` from `vars.AZURE_CLIENT_ID` and `vars.AZURE_TENANT_ID`, `allow-no-subscriptions: true`; every `az account get-access-token` step with `SMOKE_API_SCOPE` masks its capture variable; no token read before `::add-mask::` (echo, printf, curl, same line as capture or mask); no shell debug trace on any step; no `ACTIONS_STEP_DEBUG` true or 1 at workflow, job, or step (`bad-echo-token.yml`, `bad-printf-token.yml`, `bad-curl-token.yml`, `bad-no-mask.yml`, `bad-mask-after-use.yml`, `bad-mask-wrong-var.yml`, `bad-second-token-no-mask.yml`, `bad-debug-trace.yml`, `bad-debug-xtrace.yml`, `bad-actions-step-debug-job.yml`, `bad-actions-step-debug-workflow.yml`, `bad-login-v1.yml`)
- [x] yq read failures on workflow inputs (map `on:` only), scalars, step run or env scalars, or `id-token` permission values are hits, never exit 0 (`bad-yq-inputs-fail.yml`)
- [x] Forbidden secret-shaped names and banned values in any parsed scalar, including multiline `run` steps (`bad-client-secret-other-step.yml`)
- [x] Good fixtures exit 0: `good.yml`, `good-trigger-scalar.yml`, `good-trigger-list.yml`, `good-comment-party-star.yml` (comment only forbids `party.*`), `good-flow-on-line.yml`
- [x] `scripts/verify.sh` smoke auth loop: each good exits 0, each bad exits exactly 1 with one hit; `./scripts/verify.sh` ends with `0 failures`
- [ ] Live federated subjects, APIM probe table, and `smoke/templates/smoke-run.yml` auth step: SM07, SM03b, SM03L (not this PR)
## Technical design
- Components and files: `scripts/check-smoke-auth.sh`, `scripts/lib/on-triggers.sh` (import only), `test/fixtures/smoke-auth/` (5 good, 53 bad), `scripts/verify.sh` (loop title)
- Module boundary: SM04a rules unchanged in intent; SM04b adds phases 2 to 7 after parse and before exit; one `file:line SMOKEAUTH message` per hit
- Interfaces: `check-smoke-auth.sh FILE...` exit 0/1/2; `--help`
- Sequence:

```mermaid
flowchart TD
  A[parse, anchors, dup per map] --> B[forbidden inputs and banned scalars]
  B --> C[on_triggers allowlist]
  C --> D[jobs, id-token case, permissions shape]
  D --> E[OIDC environment per mint job]
  E --> F[azure/login and masked token step]
  F --> G[exit 0]
```

- Failure modes: first hit names file and line; yq missing exits 2 (needs-human)
- Security: FAKE test data only in fixtures; no secret values in repo files
- Observability: verify log one line per bad fixture
- Cost: 0
- Rollback: revert the PR
- Proof: same as proof: above
- Door: two-way
## Evidence
verify log on the PR head SHA, one hit line per bad fixture
## Flow
```mermaid
flowchart LR
  S1[SM04a rules] --> S2[token hygiene and #17 lows]
  S2 --> S3[5 good and 53 bad fixtures]
  S3 --> S4[verify.sh loop]
```
## Copy this
Standalone smoke auth gate for another repo (FAKE fixtures only, no secret values):

| Path | Role |
| --- | --- |
| `scripts/check-smoke-auth.sh` | Entrypoint: `bash scripts/check-smoke-auth.sh FILE...` (exit 0 ok, 1 hit, 2 needs-human when yq is missing) |
| `scripts/lib/on-triggers.sh` | Imported by the check (`source` from `scripts/lib/`) |
| `test/fixtures/smoke-auth/good*.yml` | Must all exit 0 |
| `test/fixtures/smoke-auth/bad-*.yml` | Must each exit 1 with exactly one `file:line SMOKEAUTH message` line |

Copy those paths preserving layout under `scripts/` and `test/fixtures/smoke-auth/`. Wire the same loop as `scripts/verify.sh` (SM04a+SM04b smoke auth section) or call the script in CI on workflow YAML paths. Requires `yq` on PATH. Does not copy workflows, policies, or live Azure or GitHub settings.

## Named asks for Sven
- None for this PR (SM07 setup and first live run stay in SM07 and SM03L).
## Cost
0 (script)
## Sources
- [SM04](../smoke/SM04.md) DoD rows for `check-smoke-auth.sh` token hygiene
- Cursor review 5658105243 on PR #17, finding 1 (flow-style `on:` duplicate false positive)
- Reviewer 6425694406 on PR #17, lows 1 and 2 (duplicate keys, `id-token` case)
- Cursor review 5721745072 on PR #22 (mask order, yq fail closed, multiline scalars, debug trace, login pin)
