# ADR 0002: Settled decisions (PR 0)

- Status: accepted (documentation)
- Date: 2026-10-25
- Scope: agentic-workflows personal catalog, plan v3.1 through v3.9b

## Decisions

1. **Provider**: GitHub Copilot, `engine: copilot`, everywhere.
2. **Personal account**: Fine-grained PAT `COPILOT_GITHUB_TOKEN`. `copilot-requests` not used (org billing only). POL21 enforces `copilot-requests: none`.
3. **Org-ready day one**: Owner is one variable. Org-only features (central billing, rulesets, org secrets, teams, GHES) documented in G05 as ready, not used on personal account.
4. **Triggers**: Every workflow uses `workflow_dispatch` and staged/report-only first, then writes. Nothing scheduled or token-spending goes live without Sven's exact yes. Hourly cron (M03) only after yes plus measured cost.
5. **Cost caps**: 50 AIC per run, 200 per day as starting suggestion (unverified). Tiers: S <= 20, M 20-60, L 60-150, XL > 150 AIC. Measure over first 3 runs per workflow.
6. **squad-review**: Stays until F01 merges. Removal PBIs list each file removed.
7. **Q0 Actions billing**: Blocked until fixed. Local `scripts/verify.sh` on exact SHA replaces CI until then (single gate, C01).
8. **No force push**: POL19 forbids force push and `+refs` in automation (normal git push only for humans).
9. **C12 v1.1 pins**: agentPacks `imports:` and `plugins:` use tag on generated commit or SHA, never main SHA for `plugins:`.
10. **F01 manual only**: `workflow_dispatch` and `/pr-review` slash. No `pull_request` until F01b after 3 audited F01 runs and Sven yes.
11. **PR #2**: Stays open as reference until PR 0 merges; then PO closes unmerged with comment linking C01, POL01, POL02, POL21, POL22, C12, F01, L02. Branch kept.
12. **Repo layout**: ADR 0001 (root `workflows/`, root `shared/`, `aw.yml`, policies, verify script).
13. **Named asks**: Q0-Q8, Q11 (X07 per-run budget), M02, X01, Y06, B04, F01b yes, M05_READ_TOKEN, P04_ASSIGN_TOKEN, Copilot enablement per repo, P14 poll yes, PR #2 close policy. Secrets via masked fields only.
14. **gist A1 (proof and door)**: Every PBI file lists `proof:` (command that proves DoD) and `door: two-way|one-way`. One-way actions need Sven's yes in the block asks plus a rollback note on the PBI.
15. **gist A2**: [X06](../done/X06-verification-skill.md) is the first PBI in Block 1 (before C01); thin wrapper spec over `scripts/verify.sh`.
16. **gist A3**: C01 `scripts/verify.sh` prints `file:line rule-id message` per failure, last line `N failures`, exit 0 only when N is 0.
17. **gist A4**: [POL23](../done/POL23-no-tautological-checks.md) meta-check: every POL check must fail bad fixtures and pass good fixtures.
18. **gist A5 (findings rule)**: Same FAIL from Reviewer or Tester twice, or any revert, becomes a POL check PBI in the next nF block (not prose only).
19. **gist A6**: [B03a](../observability/B03a-value-vs-cost.md) in Block 3; kill rule after two below-cost blocks; full [B03](../observability/B03-outcomes-impact.md) stays Block 5.
20. **gist A7 (Bar H)**: Workflows fetch context via tools and imports; prompts do not paste repo content.
21. **X07 benchmark** (plan v3.7): [X07](../testing/X07-workflow-benchmark.md) is the only benchmark PBI and is the harness, not a cost compare. Fixed cases with known answers, one score per run (found, false alarms, misses, turns, time, AIC) in `docs/benchmarks/<workflow>.md` with a baseline. One-way door: Sven's yes per run, per-run budget is named ask Q11. Each NOW workflow gets 5 or more cases in B3. A score below baseline blocks L01, L02 and AO05.
22. **Folds** (plan v3.8): F76 log insights folds into [M05](../monitoring/M05-github-log-watcher.md), F77 issue to PR folds into [P04](../multi-repo/P04-research-plan-assign-copilot.md). The human go label is `agent-ok` (replaces the old fix label everywhere). C01 is `scripts/verify.sh` only. AO10 absorbs F75.
23. **Board pick-up** (plan v3.8b): [P14](../multi-repo/P14-board-pick-up.md) is a 30 min poll with a deterministic noop pre-step (0 AIC when Ready is empty). It is a scheduled workflow, so it stays off until Sven's exact yes (one-way, B5); its Actions minutes (48 runs a day) count toward the measured cost. AO03 kill switch moves to B2 as a guard dependency for `/stop`.
24. **Cross-repo self-fix** (plan v3.9, v3.9b): M05 runs centrally, allowlist `aw.yml` `m05.repos` (svennijhuis only, POL12 check). Risk class comes from rules in `shared/risk-classes.md`; the model may only raise it; no rule match is high. Low risk hands off to P04 in the same run (no label). P04 only assigns the issue to the Copilot cloud agent, which opens the draft PR under its own identity. No token of ours writes code or PRs in another repo.
25. **Merge rule**: Builder squash merges PR 0 (and each later PBI PR in agentic-workflows) after all gates, under the room merge exception. Fix PRs that M05, P04 or P14 cause in any repo are merged by Sven; an agent never merges them.
26. **Technical design required**: every PBI has a filled `## Technical design` section ([_template.md](../_template.md)); an empty field is a Reviewer FAIL.

## Consequences

PBIs, policies, and verify checks must match this list. New decisions get ADR 0003+ in `docs/pbi/decisions/`.

## Sources

- User PR 0 rules and `agentic-workflows-pbi-plan.md` v3.1 to v3.9b
- [gist-review.md](../gist-review.md)
- `gist-handover-agentic-workflows.md`
