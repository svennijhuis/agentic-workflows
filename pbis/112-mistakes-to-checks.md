# 112 Weekly miner: repeated agent mistakes become checks

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Ops | [076](076-token-audit.md), C01 |

## Context

Gist: every repeated agent mistake becomes a lint or structure; mine past runs for corrections. Weekly report-only workflow reads `gh aw logs`/`audit` failures and human review replies on agent PRs, groups repeats, and proposes one concrete check (C01/POL rule, lint, or agentPacks standard line) per repeat. Appends to one buffer issue (F00 idea 3 owns the buffer; this PBI only feeds it).

## Sources

- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (points 8, 20, 28)
- https://github.github.com/gh-aw/reference/audit/
- https://github.com/githubnext/agentic-ops/blob/main/.github/workflows/agentic-token-optimizer.md

## Design

```yaml
on:
  schedule: weekly
  workflow_dispatch:
tools:
  agentic-workflows:
  github:
    toolsets: [repos, issues, pull_requests]
safe-outputs:
  add-comment:
    max: 1
```

## Code example

Prompt body:
```markdown
List failed or low-outcome runs from the last 7 days (agentic-workflows logs, audit).
Read human replies on agent PRs. Group by same mistake. Only groups seen 2+ times.
For each: the check that makes it impossible (rule id, file, exact grep or lint). Comment on the buffer issue.
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Report-only | `rg -n 'create-pull-request\|push-to-pull-request-branch' workflows/mistakes-to-checks.md` | no output |
| 2 | Compile | `gh aw compile workflows/mistakes-to-checks.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/mistakes-to-checks.md` | 4 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Does not write checks itself. Does not own the buffer issue (F00).

## Risks

Needs Sven yes (schedule + tokens).

## Post-merge

None beyond merge.
