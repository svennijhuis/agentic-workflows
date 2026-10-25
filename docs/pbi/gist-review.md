# Gist review: Matt Pocock x poteto transcript vs backlog

Source: full transcript (`gist_full.txt`), 32 numbered points + extras E1-E3. Checked against AW plan v3.6, blocks file, agentPacks PR #80 (https://github.com/svennijhuis/agentPacks/pull/80) plan.
Verdicts: covered, partly, gap, not ours (reason). Every gap/partly row names the PBI or addition that closes it (ids A1-A7 for AW, AP15-AP20 for agentPacks, listed below table).

| # | Point (short quote) | AW: where (PBI, block) | AP: where (PBI) | Verdict | Fix |
|---|---|---|---|---|---|
| 1 | Verification is the key skill ("allow it to verify") | [X06](testing/X06-verification-skill.md) in B1, [C01](core/C01-verify-script.md) verify.sh B1 | squad verify-harness exists | gap (no proof per PBI) | A1 `proof:` field, A2 [X06](testing/X06-verification-skill.md) first in B1 |
| 2 | Self-verify, score, "hill climbing" | [C01](core/C01-verify-script.md) pass/fail B1, [X07](testing/X07-workflow-benchmark.md) benchmark score vs baseline B2 (5+ cases per NOW workflow in B3, lower score blocks L01, L02, AO05), [X04](testing/X04-graders-evals.md) graders B5 | scenarios-md | covered | A3 verify.sh ends with failure count; X07 score is the hill-climbing number |
| 3 | Own verification skill per app, kept current | [X06](testing/X06-verification-skill.md) B1 | none for harness drift | partly | A2; AP20 harness drift check |
| 4 | "deterministic parts" into script, skill thin | [C01](core/C01-verify-script.md) B1, [L02](release/L02-update-vs-upgrade-safe-update.md) bump-pin.sh B5 | none | partly | AP19 determinism sweep |
| 5 | Shared script, not rebuilt per agent | [C01](core/C01-verify-script.md) one script for local + CI, B1 | PackCheckScriptTwin (#78) | covered | none |
| 6 | Ask how much can be deterministic | [POL01](policies/POL01-pinned-versions-only.md)-22 checks B1 | none | partly | AP19 |
| 7 | Migrations by script/codemod | [L02](release/L02-update-vs-upgrade-safe-update.md) `scripts/bump-pin.sh <ref>` B5 | no migration in flight | covered | none |
| 8 | Repeated mistake becomes a lint ("lint rules") | POL checks via [C01](core/C01-verify-script.md) B1 | AP06 contract tests | partly (no repeat rule) | A5 findings rule; AP17 |
| 9 | One way, no "god file" | [C02](core/C02-org-ready-layout.md) + decisions/0001-repo-layout B1, one file per workflow | #77 Folders standard | covered (AW), partly (AP) | AP: god-file checklist line stays a #77 fold-in |
| 10 | Strict lint + narrow types | POL01/02/21/22 B1, compile `--strict` | AP06 | covered | none |
| 11 | Easy to change safely, guardrails | [C01](core/C01-verify-script.md) + POLs B1, [S00](security/S00-security-architecture-explainer.md)-[S06](security/S06-checkout-forks.md) B2 | AP02 no force push check | covered | none |
| 12 | Engineer builds environment ("sharp knives") | whole B1 | whole Phase A | not ours (role statement, no PBI) | none |
| 13 | Context not control, agent fetches own context | shared/ imports [C05](core/C05-imports-import-schema.md), import-schema [G00a](governance/G00a-consumer-strategy.md) | [C12](core/C12-agentpacks-import-contract.md) v1.1 allowlist | partly | A7 Bar H line |
| 14 | Outer loop to inner loop with triggers | triggers/ + [F06](agent-factory/F06-daily-issue-triage.md) triage B3, [F72](agent-factory/F72-issue-triage-repro.md) B3 | not plugin scope | covered | none |
| 15 | Find where you are "the bottleneck", answer from data | [F03](agent-factory/F03-repo-status.md) repo-status B3, [B02](observability/B02-weekly-spend-overview.md) B3 | none | covered | none |
| 16 | Coordinator groups related reports | [F73](agent-factory/F73-issue-grouping.md) grouping B5 | not plugin scope | covered | none |
| 17 | "reproduce the issue" on main first | [F72](agent-factory/F72-issue-triage-repro.md) triage with repro B3 | squad-planner prose only | covered (AW), gap (AP) | AP16 repro-first contract test |
| 18 | Findings "buffer", act in batches | [F74](agent-factory/F74-findings-buffer.md) buffer B3, nF findings blocks | learnings.md | covered | none |
| 19 | Most volume is "gardening" | [F07](agent-factory/F07-doc-updater.md) doc updater, [F14](agent-factory/F14-link-checker.md) links, [F15](agent-factory/F15-markdown-linter.md) md lint B3 | #78 redundancy | covered | none |
| 20 | Sample review, fix env on repeats | [AO10](agent-ops/AO10-sampled-human-review.md) sampled human review B5 (absorbs [F75](agent-factory/F75-weekly-merged-pr-sample.md)) | none | partly | A5 |
| 21 | Autopilot verifiers "fuzz", count = cost knob | none | none | not ours (token heavy, caps [POL02](policies/POL02-cost-caps-required.md) bound spend; revisit in B6 if [B03](observability/B03-outcomes-impact.md) shows value) | none |
| 22 | Review after landing, "revert" + lint | [AO10](agent-ops/AO10-sampled-human-review.md) B5 (absorbs F75), squash merge per PBI | Sven merges | partly | A5 (a revert counts as a repeat) |
| 23 | "two-way doors" automate, one-way gate | Sven-yes asks per block | planning-contract has rollout row only | gap | A1 `door:` field; AP15 |
| 24 | Formal verification (TLA+, Lean) | none | none | not ours (no concurrent state machine in catalog or pack) | none |
| 25 | Clear "intent and your goals" | PBI goal + DoD, [G00a](governance/G00a-consumer-strategy.md) doc | PBI template | covered | none |
| 26 | Kill "tautological" tests | [X03](testing/X03-gate-fixtures.md) fixtures B1 (no rule) | testing-principles 0 hits | gap | A4 [POL23](policies/POL23-no-tautological-checks.md); AP: line stays #77 fold-in |
| 27 | "Grilling", agent questions you | [P13](multi-repo/P13-grilling-workflow.md) grilling workflow B3, Q0-Q11 asks per block, room process | squad-planner + review contract | covered | none |
| 28 | Mine "transcripts" for corrections | Fleet retro (fleet process) | squad-retro | partly | A5; AP17 |
| 29 | Skills "get smaller and smaller" | [X06](testing/X06-verification-skill.md) thin wrapper over [C01](core/C01-verify-script.md) | Matt-tiny skills direction | covered | none |
| 30 | Own your knives, mix libraries | n/a | pstack + Matt picks (#73) | not ours (AW) / covered (AP) | none |
| 31 | "difficult to measure", measure skill impact | [B02](observability/B02-weekly-spend-overview.md) spend B3, [B03](observability/B03-outcomes-impact.md) outcomes B5 | none | gap (no kill rule) | A6; AP18 |
| 32 | "clean context", short script output | none in [C01](core/C01-verify-script.md) DoD | indexer file:line (AP handover) | partly | A3 one-line output |
| E1 | Grok Bot = outer loop, Cursor Projects = inner loop | not repo scope | not pack scope | not ours (fleet routines) | none |
| E2 | Burst of related issues, coordinator spawns topology | [F73](agent-factory/F73-issue-grouping.md) B5 | n/a | covered | none |
| E3 | Smarter models, "delete those parts" of skills | [X06](testing/X06-verification-skill.md) stays thin | AP19 removes steps | covered via AP19 | none |

## AW additions (into PR 0 docs)
- A1 PBI template (docs/pbi/README.md): every PBI gets `proof:` (exact command that proves DoD, e.g. `scripts/verify.sh`, `gh aw compile --strict`, audited run id) and `door: two-way | one-way`. One-way = token spend, writes outside repo, tags/releases, secrets, Azure, rulesets. One-way always needs Sven's yes in the block asks plus a rollback note.
- A2 [X06](testing/X06-verification-skill.md) verification skill is first PBI of B1 (before [C01](core/C01-verify-script.md)), thin wrapper over verify.sh; Tester uses it from B2.
- A3 [C01](core/C01-verify-script.md) DoD adds: output one line per failure `file:line rule-id`, nothing on pass, last line `N failures` (exit code = pass/fail).
- A4 [POL23](policies/POL23-no-tautological-checks.md) no tautological checks: every POL check needs a bad fixture that must fail and a good one that must pass; gate runs the check against both and fails if the bad one passes. B1.
- A5 Findings rule (blocks README): a FAIL from Reviewer or Tester on the same thing twice, or any revert, becomes a POL check PBI in the next nF block. No prose-only lesson.
- A6 [B03a](observability/B03a-value-vs-cost.md) value vs cost (B3, split from [B03](observability/B03-outcomes-impact.md)): per workflow one row of AIC spend ([B02](observability/B02-weekly-spend-overview.md)) vs outcome (issues triaged, PR comments kept). Kill rule: 2 blocks with value below cost = workflow disabled, PBI to remove. Full [B03](observability/B03-outcomes-impact.md) stays B5.
- A7 Bar H line: a workflow fetches its own context with tools and imports; the prompt never pastes repo content.

## agentPacks additions (PR #80 follow-up, Phase D gist)
- AP15 `door: two-way | one-way` in planning-contract, human gate + rollback note on one-way (23).
- AP16 contract test: bug-fix plan carries a failing repro step before implement (17).
- AP17 retro repeat to check: same learning 2+ times in learnings.md, retro proposes the check and stops appending prose (8, 18, 28).
- AP18 skill impact record per run: fix rounds, verifier verdict, rough token cost, for before/after compare (31).
- AP19 determinism sweep over squad, verify-harness, scenarios-md, pack-check: mechanical steps into AgentPacks.Cli or pack-check/scripts (4, 5, 6).
- AP20 verify-harness drift check: pack-check flags missing or renamed harness commands (3).
- AP PBI template also gets `proof:` and `door:` (same as A1).
- Stay #77 fold-ins (code paused, no new PBI): tautological-tests line (26), god-file checklist line (9), indexer `file:line` output assert (32).
