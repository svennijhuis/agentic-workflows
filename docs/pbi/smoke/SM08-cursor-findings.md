# SM08: Close the 8 open Cursor findings on SM01, SM04, SM05, SM07 (docs first)
- Status: todo
- Area: smoke
- Wave: W3
- Block: 3
- Lane: Cursor CLI
- Depends on: none (docs only; SM01, SM04, SM05 and SM07 are on main at b3e05e1)
- proof: every SM08 DoD row below is a line in SM01, SM04, SM05 or SM07 on the merged SHA (Reviewer greps each named fixture path in its target PBI); `bash scripts/check-pbi-template.sh` and `bash scripts/check-pbi-docs.sh` print nothing; `./scripts/verify.sh` ends with `0 failures`
- door: two-way
- triage: spec (the 8 findings of Cursor review 5648771343 on PR #5 at 8936269; each one is a doc fix with a named fixture and a DoD row)
- feedback: `grep -c` on each fixture path from the table below in its target PBI returns 1 or more; the two docs checks print nothing; `./scripts/verify.sh` gives `0 failures`
- harness: none (docs)
- review-input: diff + this PBI + DoD (+ linked spec) + PR description, never builder session logs (PA6)
- kind: script (docs edits; the checks they specify are scripts)
- Source: PA8 (no D row; Sven, Development Agentic Workflows room, 2026-10-26 12:49 "Please merge pbis pr", Product Owner GO on #5 moved the open findings here) https://github.com/svennijhuis/agentic-workflows/pull/5#pullrequestreview-5648771343
## Goal
Fold the 8 open findings (1 high, 6 medium, 1 low) of the Cursor review on PR #5 at 8936269 into SM01, SM04, SM05 and SM07, so no smoke build starts on a spec that fails open.
## Context
PR #5 merged as b3e05e1 with these 8 findings open. Product Owner waived the Cursor gate for #5 only (docs, nothing turned on), on the condition that this PBI lands first.

Gate rule: no SM01 to SM07 build PR starts before SM08 is done (this PBI merged and moved to `docs/pbi/done/`). SM01, SM04, SM05 and SM07 link here. SM02, SM03 and SM06 are untouched by the findings, but they depend on SM01, SM04, SM05 or SM07, so the gate reaches them too.

Each finding was checked against the repo at b3e05e1. All 8 hold. Finding 4 is narrowed (see its row): the evidence is `policies/checks/POL25.sh:31` and `:40` (`yes_for ... && continue` skips every trigger test) and `policies/POL25.yml:13` (`sven_yes: []`, the documented PA1 yes path for agentic schedules). Dropping `sven_yes` fully would remove that PA1 path, which is out of scope for a smoke PBI. So `sven_yes` keeps lifting only the agentic `workflow_dispatch`-only rule, and the `deployment_status` fail, the `workflow_call` allowlist and the agentic `workflow_call` fail run before it. `sven_yes` never lifts `workflow_call` on an agentic file.

Findings (line numbers at b3e05e1):

| # | Sev | Where | Verdict | Fix (text to add to the target PBI) | Fixture | DoD row added to the target PBI |
|---|---|---|---|---|---|---|
| 1 | high | `docs/pbi/smoke/SM04.md:82` | fix | `check-smoke-auth.sh` reads triggers only through `on_triggers` in `scripts/lib/on-triggers.sh`; exit 2 (parse error or bad shape) and exit 3 (no `on:`) are hits. `check-smoke-auth.sh` exits 1 when `on_triggers` returns 2 or 3. After dropping `roles`, `skip-bots`, `skip-roles` the list must be non-empty (an empty list exits 1) and every name `workflow_dispatch` or `workflow_call`. Never `yq '.on \| keys'`. | `test/fixtures/smoke-auth/bad-trigger-push.yml` is the scalar `on: push`; new `bad-trigger-list.yml` (`on: [issue_comment]`); `bad-trigger-release.yml` stays a map (`on: {release: {}}`); new `bad-trigger-settings-only.yml` (`on: {roles: [admin]}`, empty after the drop), new `bad-trigger-no-on.yml` (no `on:` key, `on_triggers` exit 3), new `bad-trigger-on-shape.yml` (`on: 1`, `on_triggers` exit 2) | Triggers are read with `on_triggers`; scalar, list and map forms are checked alike; `on_triggers` exit 2 or 3 and an empty list after the drop each exit 1; `bad-trigger-push.yml` (scalar), `bad-trigger-list.yml` (list), `bad-trigger-settings-only.yml`, `bad-trigger-no-on.yml` and `bad-trigger-on-shape.yml` each exit 1 |
| 2 | medium | `docs/pbi/smoke/SM04.md:79` | fix | The environment rule applies to every job that can mint an OIDC token: job `permissions` has `id-token: write`, or the job has no `permissions` key and the workflow-level `permissions` has `id-token: write`. On each such job the parsed `environment` must be the string `smoke-${{ inputs.env }}`; a map, null or any other string exits 1. | new `test/fixtures/smoke-auth/bad-env-object.yml` (`environment: {name: nonprod}`), new `bad-inherited-id-token.yml` (workflow-level `id-token: write`, second job without job `permissions`, `environment: nonprod`) | Every job that has or inherits `id-token: write` declares `environment` as the string `smoke-${{ inputs.env }}`; `bad-env-object.yml` and `bad-inherited-id-token.yml` each exit 1; `good.yml` still exits 0 |
| 3 | medium | `docs/pbi/smoke/SM05.md:141` | fix | Agentic path: after `D -->\|yes\|`, add a POL03 staged node before `OK`: a write output without `safe-outputs.staged: true` and a basename not on `promoted:` fails. Matches `policies/checks/POL03.sh:34` to `:42` (staged check after `triggers_ok`, skipped when promoted). | existing `test/fixtures/bad/POL03-smoke-unstaged-write.md` (SM05:102) | The SM05 sequence diagram draws the POL03 staged check before `OK` on the agentic dispatch-only path; `bad/POL03-smoke-unstaged-write.md` exits 1 |
| 4 | medium | `docs/pbi/smoke/SM05.md:46` | fix (narrowed) | In `POL25.sh` the `deployment_status` fail, the `workflow_call` allowlist and the agentic `workflow_call` fail run before `yes_for` (`:31`, `:40`) as well as before `promoted`. A `sven_yes` row never lets `deployment_status`, an unlisted `workflow_call`, or `workflow_call` on an agentic `.md` (even when its entry lists `workflow_call`) through; it lifts only the agentic dispatch-only rule for other triggers such as `schedule`. `POL25.sh` reads its config from `$POL25_CFG` (default `policies/POL25.yml`). POL23 exports `POL25_CFG=<case>/POL25.yml` for a case folder that holds one, next to `POL_ROLLOUT`, and never counts `POL25.yml` (or `rollout.yml`) as a workflow file, so the one-workflow-file rule still holds. | new `test/fixtures/bad/POL25-smoke-sven-yes-deployment-status/` (case `POL25.yml` `sven_yes` lists the workflow, it uses `deployment_status`), new `bad/POL25-smoke-sven-yes-unlisted-call/` (same, `workflow_call` with no `deterministic_triggers` entry), new `bad/POL25-smoke-sven-yes-listed-call/` (agentic `.md` on `workflow_call`, its entry lists `workflow_call`, case `POL25.yml` `sven_yes` lists it), new `good/POL25-smoke-sven-yes-schedule/` (agentic `.md` on `workflow_dispatch` plus `schedule`, case `POL25.yml` `sven_yes` lists it; exit 0, so the yes is really read) | POL23 exports `POL25_CFG` to the case `POL25.yml` and does not treat it as a workflow; `sven_yes` does not bypass the `deployment_status` fail, the `workflow_call` allowlist or the agentic `workflow_call` fail; the three `bad/POL25-smoke-sven-yes-*` cases exit 1 and `good/POL25-smoke-sven-yes-schedule/` exits 0 |
| 5 | medium | `docs/pbi/smoke/SM05.md:149` | fix | Node RT is POL03 only. POL25 stops at `L -->\|yes\|` with no hit (matches SM05:42 and :43). POL03 also fails a name in the entry `triggers` list other than `workflow_dispatch` and `workflow_call` unless it is on `promoted:`. | new `test/fixtures/good/POL25-smoke-call-plus-pr/` (entry lists `workflow_call`, file also has `pull_request`; POL25 exits 0), new `bad/POL03-smoke-entry-extra/` (file `on:` is `workflow_dispatch` plus `workflow_call` only; `pull_request` is only in the entry `triggers` list and not on `promoted:`; POL03 exits 1 on the entry rule alone, apart from `bad/POL03-smoke-extra-trigger/` at SM05:92) | RT is marked POL03 only; `good/POL25-smoke-call-plus-pr/` exits 0 under POL25; `bad/POL03-smoke-entry-extra/` exits 1 under POL03 |
| 6 | medium | `docs/pbi/smoke/SM07.md:45` | fix | "Does not parse" is defined, not left to a markdown parser (CommonMark runs an unclosed fence to end of file, so it parses). `smoke/SETUP.md` starts with YAML frontmatter (`steps: <n>`). The check slices the frontmatter the way `fm` in `policies/checks/lib.sh:34` does (line 1 is `---`, up to the next `---`) and runs `yq` on that slice only, never on the whole markdown file. Before the verify-line scan it exits 1 when the slice is missing, when `yq` on the slice exits non-zero, when `steps` is missing or not equal to the count of numbered steps, or when a fence is still open at end of file (fence lines are tracked open and close, not counted, so two unclosed fences fail too). | `test/fixtures/smoke-setup/bad-broken.md` becomes invalid YAML inside the frontmatter slice; new `bad-no-frontmatter.md` (no slice); new `bad-unclosed-fence.md` (valid frontmatter, every step has a verify line, one unclosed fence); new `bad-two-unclosed.md` (two unclosed fences, even fence count); new `bad-steps-mismatch.md` (`steps: 3`, two numbered steps) | The slice parse, the `steps` count and the fence tracking run before the verify-line scan; `bad-broken.md`, `bad-no-frontmatter.md`, `bad-unclosed-fence.md`, `bad-two-unclosed.md` and `bad-steps-mismatch.md` each exit 1; `good.md` and `smoke/SETUP.md` exit 0 (their slice parses) |
| 7 | medium | `docs/pbi/smoke/SM01.md:34` | fix | Exit 1 unless `auth` is exactly `none` or `smoke-jwt`. Exit 1 when any scalar has a token shape: three dot-separated segments of 10 or more `[A-Za-z0-9_-]` chars, or a value starting with `Bearer `. Fixtures use a fake placeholder made of `FAKE` plus zeros, never a real or JWT-prefixed value. | new `test/fixtures/smoke/bad-auth-unknown.yml` (`auth: basic`), new `bad-auth-token.yml` (a header value `FAKE0000000000.FAKE0000000000.FAKE0000000000`), new good `good-dotted.yml` (`path: /v1.2.3`, short segments pass) | `auth` other than `none` or `smoke-jwt` exits 1; a token-shaped scalar exits 1; `bad-auth-unknown.yml` and `bad-auth-token.yml` exit 1, `good-dotted.yml` exits 0 |
| 8 | low | `docs/pbi/smoke/SM05.md:98` (review says :99) | fix | Date gets the same blank case as quote (SM05:96, :97). | new `test/fixtures/bad/POL03-smoke-date-blank/` and `bad/POL25-smoke-date-blank/` (`yes.date: " "`, runner is dispatch-only) | Both `*-smoke-date-blank/` cases exit 1 |

SM07 manual setup (PO, 2026-10-26): Sven's manual setup step in SM07 stays documented and switched off. It never blocks SM08 or any SM build PR; the offline proof (fixtures, `check-smoke-setup.sh`, `./scripts/verify.sh`) is the gate, and the live step waits for Sven's yes.

Counts after the fix: SM01 gains 2 bad and 1 good fixture (11 bad, 2 good). SM04 gains 6 bad fixtures (`bad-trigger-list`, `bad-trigger-settings-only`, `bad-trigger-no-on`, `bad-trigger-on-shape`, `bad-env-object`, `bad-inherited-id-token`). SM05 gains 2 good and 6 bad cases (9 good, 37 bad), so its proof line count is updated. SM07 gains 4 bad fixtures (`bad-no-frontmatter`, `bad-unclosed-fence`, `bad-two-unclosed`, `bad-steps-mismatch`).
## Steps
1. Edit SM01, SM04, SM05 and SM07: add each fix, fixture and DoD row from the table to the named PBI, update fixture counts in proof, feedback and Flow lines.
2. Redraw the SM05 sequence diagram (findings 3 and 5) and keep it valid mermaid.
3. Run `bash scripts/check-pbi-template.sh`, `bash scripts/check-pbi-docs.sh` and `./scripts/verify.sh`.
4. Move this file to `docs/pbi/done/` with `- Status: done` and `- PR: #<n>` in the same PR, and point the gate links in SM01, SM04, SM05 and SM07 and the links in `docs/pbi/smoke/README.md` and `docs/pbi/README.md` at `done/SM08-cursor-findings.md` (Reviewer, PR #8).
## Definition of Done
- [ ] Finding 1: SM04 names `on_triggers` as the only trigger reader, makes its exit 2 and 3 and an empty list exit 1, and lists `bad-trigger-push.yml` (scalar), `bad-trigger-list.yml`, `bad-trigger-settings-only.yml`, `bad-trigger-no-on.yml` and `bad-trigger-on-shape.yml` (Cursor 5651657748 medium 3)
- [ ] Finding 2: SM04 applies the environment rule to jobs that inherit `id-token: write` and lists `bad-env-object.yml` and `bad-inherited-id-token.yml`
- [ ] Finding 3: SM05 diagram has the POL03 staged node before `OK` on the agentic path, tied to `bad/POL03-smoke-unstaged-write.md`
- [ ] Finding 4: SM05 rule order says `sven_yes` does not bypass the `deployment_status` fail, the `workflow_call` allowlist or the agentic `workflow_call` fail; POL23 exports `POL25_CFG` and does not count `POL25.yml` as a workflow; SM05 lists the three `bad/POL25-smoke-sven-yes-*` cases and `good/POL25-smoke-sven-yes-schedule/` (Cursor 5651657748 medium 2)
- [ ] Finding 5: SM05 node RT is POL03 only; `good/POL25-smoke-call-plus-pr/` and `bad/POL03-smoke-entry-extra/` listed, and `bad/POL03-smoke-entry-extra/` has `pull_request` only in the entry `triggers` list, not in the file `on:` (Cursor 5651657748 medium 4)
- [ ] SM07 still documents Sven's manual setup step as switched off and non-blocking; no SM build PR waits on it
- [ ] Finding 6: SM07 defines the parse step (`yq` on the `fm` frontmatter slice only, `steps` equals the numbered-step count, fence open and close tracked to end of file) and lists `bad-broken.md` (bad YAML in the slice), `bad-no-frontmatter.md`, `bad-unclosed-fence.md`, `bad-two-unclosed.md` and `bad-steps-mismatch.md` (Cursor 5651657748 high 1)
- [ ] Finding 7: SM01 has the `auth` allowlist and token-shape rows and lists `bad-auth-unknown.yml`, `bad-auth-token.yml` and `good-dotted.yml`; no real or JWT-prefixed token in any file
- [ ] Finding 8: SM05 lists `bad/POL03-smoke-date-blank/` and `bad/POL25-smoke-date-blank/`
- [ ] SM05 proof line counts match the fixture list (9 good, 37 bad)
- [ ] On the move to `docs/pbi/done/`, the gate links in SM01, SM04, SM05, SM07 and both README links point at `done/SM08-cursor-findings.md`
- [ ] `bash scripts/check-pbi-template.sh` and `bash scripts/check-pbi-docs.sh` print nothing; `./scripts/verify.sh` ends with `0 failures`; no em or en dash; mermaid renders
- [ ] A fresh Cursor review on the SM08 PR head has no open medium or above
## Technical design
- Components and files: `docs/pbi/smoke/SM01.md`, `SM04.md`, `SM05.md`, `SM07.md`, `README.md`, this file (moved to `docs/pbi/done/`)
- Module boundary: the DoD rows in SM01, SM04, SM05 and SM07; the checks they specify (`check-smoke.sh`, `check-smoke-auth.sh`, `check-smoke-setup.sh`, POL03, POL25) are built later in those PBIs
- Interfaces: none new; fixture paths and DoD rows only
- Sequence:

```mermaid
flowchart LR
  R[Cursor review 5648771343, 8 findings] --> S8[SM08 table]
  S8 --> E1[SM01: auth, token shape]
  S8 --> E4[SM04: on_triggers, inherited OIDC env]
  S8 --> E5[SM05: staged node, sven_yes order, RT POL03 only, date blank]
  S8 --> E7[SM07: frontmatter slice parse, steps count, fence tracking]
  E1 --> G[SM08 done]
  E4 --> G
  E5 --> G
  E7 --> G
  G --> B[SM01 to SM07 builds may start]
```

- Failure modes: a finding left out keeps its PBI failing open; Reviewer checks each table row against the target PBI
- Security: no secrets; the token fixture is a fake `FAKE` placeholder
- Observability: Reviewer grep per fixture path; verify log
- Cost: 0
- Rollback: revert the PR
- Proof: same as proof: above
- Door: two-way (docs only)
## Evidence
verify log on the PR SHA, empty output of both docs checks, grep per fixture path
## Flow
```mermaid
flowchart LR
  A[8 findings] --> B[edit SM01 SM04 SM05 SM07]
  B --> C[docs checks empty, verify 0 failures]
  C --> D[Cursor review, no medium or above]
  D --> E[merge, move SM08 to done]
```
## Named asks for Sven
- None. Docs only.
## Cost
0 (docs)
## Sources
- [PR #5 Cursor review at 8936269](https://github.com/svennijhuis/agentic-workflows/pull/5#pullrequestreview-5648771343)
- [PR #5 Product Owner GO, findings moved to a follow-up](https://github.com/svennijhuis/agentic-workflows/pull/5#issuecomment-6415300262)
- repo at b3e05e1: `scripts/lib/on-triggers.sh`, `policies/checks/POL03.sh`, `policies/checks/POL25.sh`, `policies/POL25.yml`
- https://spec.commonmark.org/0.31.2/#fenced-code-blocks (an unclosed fence runs to the end of the document)
