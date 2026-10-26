# Roadmap: steps, blocks and why

State as of 2026-10-26 20:45 (Amsterdam, UTC+1). Main is `5624c0f`. This page only orders and links. The PBI files are the source of truth, and this page never copies their text.

Link legend: a normal link means the file is on main. `path (in #n at sha)` means the file only exists in that open PR so far.

## Goal

1. This repo is a catalog of policy-gated agentic workflows for GitHub (gh-aw), built personal first (svennijhuis) and org-ready.
2. Every rule is a `policies/POLnn.yml` file with a check in `policies/checks/POLnn.sh` and good and bad fixtures in `test/fixtures/`.
3. One runner, `scripts/verify.sh`, runs all checks: exit 0 ok, 1 finding, 2 needs a human.

## 1. All blocks and their order

Backlog blocks B0 to B6 are in [docs/pbi/README.md](pbi/README.md). The work now in flight sits in B2 (VF, WF, TPL), B3 (SM) and B5 (G).

```mermaid
flowchart TD
  B0[B0 PR0 docs, done #3] --> B1[B1 foundation + verify, done #4]
  B1 --> B2[B2 guards + v0.1]
  B2 --> B3[B3 NOW workflows]
  B3 --> B4[B4 monitoring]
  B4 --> B5[B5 scale]
  B5 --> B6[B6 later]

  subgraph VF[VF verify, B2]
    VF01[VF01 done #10] --> VF02a[VF02a done #9]
    VF01 --> VF02d1[VF02d1 done #13]
    VF02b[VF02b todo] --> VF02c[VF02c todo] --> VF02d[VF02d todo + carries] --> VF02e[VF02e todo] --> VF02f[VF02f todo]
    VF02a --> VF02f
    VF02f --> VF02L{{VF02L Sven only}}
  end

  subgraph SM[SM smoke, B3]
    SM01[SM01 done #11] --> SM01a[SM01a todo, file in #15] --> SM01b[SM01b todo, file in #18]
    SM05a[SM05a open #14] --> SM05b[SM05b todo] --> SM05c[SM05c todo]
    SM07a[SM07a open #16] --> SM07b{{SM07b Sven only}}
    SM04a[SM04a open #17] --> SM04b[SM04b todo]
    SM01 --> SM03a[SM03a todo]
    SM04b --> SM03b[SM03b todo]
    SM03a --> SM06[SM06 todo]
    SM03b --> SM06
    SM06 --> SM03L{{SM03L Sven only}}
    SM05c --> SM03L
    SM07b --> SM03L
    SM03L --> SM02[SM02 agentic, last]
  end

  subgraph WF[WF shared lister]
    WF01[WF01 todo, file in #18]
  end

  subgraph G[G governance]
    G00[G00 G00a G02a done #4] --> G05[G05 done #12] --> G05a[G05a todo, file in #15]
    G05 --> GSW{{org switch, Sven exact yes}}
  end

  subgraph TPL[TPL template]
    TPL01[TPL01 done #4] --> TPL02[TPL02 todo]
  end

  VF01 --> SM05a
  VF02d1 --> SM05a
  SM05c --> WF01
  WF01 --> VF02b
  VF01 --> SM07a
  VF01 --> SM04a
  B1 --> VF01
```

Why this order: `POL23.sh` and `verify.sh` are shared hot files. Only one open PR may edit `POL23.sh`, so the lane 1 chain (SM05a, SM05b, SM05c, WF01, VF02b) runs strictly in series.

## 2. Blocks

### VF: one verify entry point and a consumer verify template

- Goal: one `scripts/verify.sh` for CI, the local gate and every agent, plus a verify template consumer repos can install.
- Why: before VF01 every caller could run its own lint mix, and a gate that only uses denylists keeps getting bypassed (Cursor 5655973880 found 2 highs on main after #10). VF02 adds POL30 so a consumer template cannot spend tokens or auto-trigger without Sven's yes.
- Steps in order: VF01, VF02a, VF02d1, then VF02b, VF02c, VF02d, VF02e, VF02f, then VF02L (Sven only).
- Index: [docs/pbi/verify/README.md](pbi/verify/README.md). Parent: [docs/pbi/verify/VF02.md](pbi/verify/VF02.md).

| PBI | Status | File |
|---|---|---|
| VF01 | merged #10, squash `a174b5b` | [docs/pbi/done/VF01.md](pbi/done/VF01.md) |
| VF02a | merged #9, squash `2e41e13` | [docs/pbi/done/VF02a-pol01-extension.md](pbi/done/VF02a-pol01-extension.md) |
| VF02d1 | merged #13, squash `5624c0f` (2 rounds, waivers to VF02d) | [docs/pbi/done/VF02d1.md](pbi/done/VF02d1.md) |
| VF02b, VF02c, VF02d, VF02e, VF02f | todo, sections in the parent | [docs/pbi/verify/VF02.md](pbi/verify/VF02.md) |
| VF02L | Sven only, no PR | [docs/pbi/verify/VF02.md](pbi/verify/VF02.md) |

Next: VF02b, after WF01 (lane 1, edits POL23).

### SM: post-deploy API smoke on tst and acc

- Goal: a fixed smoke scenario format, offline checks for setup, auth and triggers, a runner and a report, then one live install in the API repo.
- Why: smoke runs against real environments with a token, so a bad scenario or workflow could leak secrets, hit prod or run on the wrong trigger. Every check fails closed before anything goes live.
- Steps in order (lane 2 unless noted): SM01, SM07a, SM04a, SM01a, SM01b, SM04b, SM03a, SM03b, SM06. Lane 1: SM05a, SM05b, SM05c. Then Sven only: SM07b, SM03L. SM02 (agentic) is last.
- SM08 holds the Cursor findings and closes when SM01, SM04a, SM05a, SM05b, SM05c and SM07a are merged.
- Index: [docs/pbi/smoke/README.md](pbi/smoke/README.md).

| PBI | Status | File |
|---|---|---|
| SM01 | merged #11, squash `9680af0` | [docs/pbi/done/SM01.md](pbi/done/SM01.md) |
| SM05a | open [#14](https://github.com/svennijhuis/agentic-workflows/pull/14), head `2512df8` | `docs/pbi/done/SM05a-det-triggers-pol03.md` (in #14 at 2512df8) |
| SM07a | open [#16](https://github.com/svennijhuis/agentic-workflows/pull/16), head `bdab17f` | `docs/pbi/done/SM07a-setup-check.md` (in #16 at bdab17f) |
| SM04a | open [#17](https://github.com/svennijhuis/agentic-workflows/pull/17), head `8226e99` | `docs/pbi/done/SM04a-auth-check.md` (in #17 at 8226e99) |
| SM01a | todo, PBI file in open [#15](https://github.com/svennijhuis/agentic-workflows/pull/15), head `368f837` | `docs/pbi/smoke/SM01a.md` (in #15 at 368f837) |
| SM01b | todo, PBI file in open [#18](https://github.com/svennijhuis/agentic-workflows/pull/18), head `905e953` | `docs/pbi/smoke/SM01b.md` (in #18 at 905e953) |
| SM05b, SM05c | todo, sections in the parent | [docs/pbi/smoke/SM05.md](pbi/smoke/SM05.md) |
| SM04b | todo, section in the parent | [docs/pbi/smoke/SM04.md](pbi/smoke/SM04.md) |
| SM03a, SM03b | todo | [docs/pbi/smoke/SM03.md](pbi/smoke/SM03.md) |
| SM06 | todo | [docs/pbi/smoke/SM06.md](pbi/smoke/SM06.md) |
| SM07b | Sven only, no PR | [docs/pbi/smoke/SM07.md](pbi/smoke/SM07.md) |
| SM03L | Sven only, live, off | [docs/pbi/smoke/SM03.md](pbi/smoke/SM03.md) |
| SM02 | todo, agentic, last | [docs/pbi/smoke/SM02.md](pbi/smoke/SM02.md) |
| SM08 | todo, closes with the build PBIs | [docs/pbi/smoke/SM08-cursor-findings.md](pbi/smoke/SM08-cursor-findings.md) |

Next: finish #14, #16, #17 inside the 2 round cap. Then SM05b (lane 1) and SM01a or SM04b (lane 2).

### G: governance and the org switch

- Goal: the repo is built org-ready from day 1, so moving to an org is a checklist, not a rewrite.
- Why: Sven wants a central place for GitHub agentic workflows later, but the org switch is one-way (billing, rulesets, org secrets, teams). Everything else stays the same at the switch.
- Steps in order: G00, G00a, G02a, G05, G05a. The switch itself waits for Sven.

| PBI | Status | File |
|---|---|---|
| G00, G00a, G02a | merged #4, squash `2ccf76d` | [G00](pbi/done/G00-org-target-structure.md), [G00a](pbi/done/G00a-consumer-strategy.md), [G02a](pbi/done/G02a-pr-owner-architecture-questions.md) |
| G05 | merged #12, squash `f184995` | [docs/pbi/done/G05-org-only-appendix.md](pbi/done/G05-org-only-appendix.md), checklist [governance/ORG-ONLY.md](../governance/ORG-ONLY.md) |
| G05a | todo, PBI file in open [#15](https://github.com/svennijhuis/agentic-workflows/pull/15), head `368f837` | `docs/pbi/governance/G05a-org-only-followups.md` (in #15 at 368f837) |
| Org switch | off, needs Sven's exact yes | [governance/ORG-ONLY.md](../governance/ORG-ONLY.md) |

Next: G05a (docs only, lane 3) after #15 merges.

### TPL: one PBI template

- Goal: one PBI template for this repo and agentPacks, with 5 fields plus Source.
- Why: reviewers and testers need the same fields (proof, door, triage, feedback, harness, review input) in every PBI, or gates are judged on chat instead of the file.
- Steps in order: TPL01, then TPL02 (backfill old PBIs).

| PBI | Status | File |
|---|---|---|
| TPL01 | merged #4, squash `2ccf76d` | [docs/pbi/done/TPL01-one-pbi-template.md](pbi/done/TPL01-one-pbi-template.md) |
| TPL02 | todo (file on main; #15 also edits it) | [docs/pbi/docs/TPL02-template-backfill.md](pbi/docs/TPL02-template-backfill.md) |

Next: TPL02, lane 3, after #15 merges.

### WF: one shared workflow file lister

- Goal: every policy and the verify loops find workflow files the same way (`*.yml`, `*.yaml`, `*.lock.yml`).
- Why: the same bug hit 3 times (#14 POL03 loop, verify.sh fixture loops, check-smoke), each time because a script had its own `*.yml` glob.
- Steps in order: shared lib plus unit test, switch every loop to it, POL23 case for local globs, delete the dead globs.

| PBI | Status | File |
|---|---|---|
| WF01 | todo, PBI file in open [#18](https://github.com/svennijhuis/agentic-workflows/pull/18), head `905e953` (round 1 in progress) | `docs/pbi/verify/WF01.md` (in #18 at 905e953) |

Next: lane 1, after SM05c and before VF02b.

## 3. Todo PBIs (parked, filed, not started)

| Item | Where it is written | Lane, after |
|---|---|---|
| WF01 shared lister | `docs/pbi/verify/WF01.md` (in #18) | lane 1, after SM05c |
| SM01b check-smoke carry (Cursor 5657706637) | `docs/pbi/smoke/SM01b.md` (in #18) | lane 2, after SM01a |
| SM01a row 1 `\|` fix | parked, to apply to `docs/pbi/smoke/SM01a.md` after #15 merges | lane 3 |
| SM04b token hygiene | [docs/pbi/smoke/SM04.md](pbi/smoke/SM04.md) | lane 2, after SM04a (#17) |
| SM05b, SM05c | [docs/pbi/smoke/SM05.md](pbi/smoke/SM05.md) | lane 1, after SM05a (#14) |
| VF02d carries, 25 items | VF02d section of [docs/pbi/verify/VF02.md](pbi/verify/VF02.md) (older rows); the new rows land with #18 round 1, not pushed at 905e953 | lane 1, VF02d |

VF02d carries 21 to 25 come from the #13 waivers: a second job running verify without checkout (21), `timeout-minutes: 0` passes (22), curl short options let POL27 accept any curl line (23, Cursor high), tar flags and archive not pinned (24), `setup_allow` not in the mutation proof (25).

## 4. Lanes

| Lane | Who | Order |
|---|---|---|
| 1 | Builder, Grok path (policy chain, edits POL23) | VF02d1 (done), SM05a, SM05b, SM05c, WF01, VF02b, VF02c, VF02d, VF02e |
| 2 | Builder, Cursor CLI (one script each) | SM07a, SM04a, SM01a, SM04b, SM01b, SM03a, SM03b, SM06, VF02f |
| 3 | Docs only PRs | #18 now; later G05a, TPL02, the SM01a row 1 fix |

## 5. What stays off and why

| Item | Why it is off | Who unblocks |
|---|---|---|
| SM07b | Sven runs `smoke/SETUP.md` himself and names the API repo | Sven |
| SM03L | live smoke install in another repo, one-way, needs SM07b | Sven's exact yes |
| VF02L | staged dispatch run plus agentPacks publish, one-way | Sven's exact yes |
| Token dependent steps | Sven will not add a GitHub token, so they are proven offline only (stubs, fixtures) and stay documented and off | Sven |
| Org switch (G05) | one-way: billing, rulesets, org secrets, teams | Sven's exact yes |
| Azure | no apply by bots; bots never touch Entra or Azure | Sven's exact yes |
| Spend (tokens, credits) | nothing that spends runs without a yes | Sven |

## 6. Recurring issues and the shared fix

| Issue | Seen in | Shared fix |
|---|---|---|
| Workflow files listed as `*.yml` only, so `*.yaml` and lock files are missed | #14, verify.sh loops, check-smoke | WF01 `scripts/lib/wf-files.sh` |
| Hex where an int is expected (`0x12C`, `0x2`) | SM01a, #16 | shared `is_dec_int` helper in `scripts/lib` (candidate, no PBI id yet) |
| YAML anchors, aliases and duplicate keys slip past checks | #13, #16, #17 | shared `yaml_strict` precheck in `scripts/lib` (candidate, no PBI id yet) |
| Denylists keep getting bypassed | #10, #13 | allowlists (VF02d1 run allowlist) |

## 7. Rules of the road

- One PBI per PR, max 2 fix rounds (the build is round 0). Anything still open after round 2 goes to a named todo PBI and does not block.
- Merge gates: Tester PASS (odd PRs Tester, even PRs Tester 2), Reviewer PASS, `verify.sh` 0 failures, 0 open threads, Cursor review on the head SHA, PO GO.
- Builder squash merges one PBI at a time. The second PR merges main in before its GO.
- Only one open PR edits `POL23.sh` at a time.
- Never force push; use a `-v2` branch. Personal svennijhuis only. FAKE values in fixtures.

## 8. Next session start list

1. Check #14, #15, #16, #17, #18 for gate state on their current heads. Whichever of #14 and #18 merges second renumbers SM05 steps 6 to 9.
2. Apply the SM01a row 1 `|` fix after #15 merges.
3. Lane 1: SM05b. Lane 2: SM04b (after #17) or SM01a.
4. Lane 3: G05a and TPL02 when free.
5. Open the shared `is_dec_int` and `yaml_strict` question with PO: own PBI ids or fold into WF01.
6. Sven only, any time: SM07b.
