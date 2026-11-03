---
# Adapted from github/gh-aw .github/workflows/agentic-token-audit.md (origin githubnext/agentic-ops@c611242a76866fb51d4f7d660c80badc504dd473, MIT).
# Changed: no Python or charts, jq aggregation in a pre-agent step, per-flow view, noop on an empty window, catalog caps.
description: Daily audit of AI Credits (AIC) per agentic workflow and per flow in this repo, with a trend kept in repo-memory. One issue per day, older ones closed.
on:
  schedule: daily around 07:00
  workflow_dispatch:
max-ai-credits: 150
max-daily-ai-credits: 300
max-turns: 40
timeout-minutes: 15
concurrency:
  group: agentic-token-audit
imports:
  - shared/defaults.md
permissions:
  copilot-requests: write
  actions: read
  contents: read
  issues: read
  pull-requests: read
network:
  allowed: []
tools:
  github:
    mode: gh-proxy
    toolsets: [issues, pull_requests]
  agentic-workflows:
  bash: ["jq", "cat", "ls", "date", "mkdir", "cp", "head", "wc", "test"]
  repo-memory:
    branch-name: "memory/agentic-token-audit"
    description: "Daily AIC snapshots per workflow and a rolling 90-day summary"
    file-glob: ["*.json"]
    max-file-size: 102400
    max-patch-size: 51200
steps:
  - name: Download and aggregate the last 24 hours of agentic runs
    env:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    run: |
      set -euo pipefail
      dir=/tmp/gh-aw/agentic-token-audit
      mkdir -p "$dir"

      # gh aw logs streams JSON; on a rate limit the part written so far is still valid.
      logs_exit=0
      gh aw logs --start-date -1d --json -c 300 > "$dir/logs.json" || logs_exit=$?
      if [ ! -s "$dir/logs.json" ] || ! jq -e '.runs' "$dir/logs.json" > /dev/null 2>&1; then
        echo '{"runs":[],"episodes":[]}' > "$dir/logs.json"
      fi
      echo "gh aw logs exit code: $logs_exit" > "$dir/logs-exit.txt"

      jq '{
        generated_at: (now | todateiso8601),
        window: "last 24 hours",
        raw_runs: (.runs | length),
        completed_runs: ([.runs[] | select(.status == "completed")] | length),
        overall: {
          total_aic: ([.runs[] | select(.status == "completed") | .aic // 0] | add // 0),
          total_turns: ([.runs[] | select(.status == "completed") | .turns // 0] | add // 0),
          total_action_minutes: ([.runs[] | select(.status == "completed") | .action_minutes // 0] | add // 0)
        },
        workflows: (
          [.runs[] | select(.status == "completed")]
          | group_by(.workflow_name)
          | map({
              workflow_name: .[0].workflow_name,
              run_count: length,
              total_aic: (map(.aic // 0) | add),
              avg_aic: ((map(.aic // 0) | add) / length),
              max_aic: (map(.aic // 0) | max),
              avg_turns: ((map(.turns // 0) | add) / length),
              total_action_minutes: (map(.action_minutes // 0) | add),
              failures: (map(select(.conclusion != "success")) | length),
              error_count: (map(.error_count // 0) | add),
              costliest_run_url: (max_by(.aic // 0) | .url)
            })
          | sort_by(-.total_aic)
        ),
        flows: (
          [(.episodes // [])[] | {
              episode_id,
              representative_workflow,
              total_runs,
              total_aic: (.total_aic // 0)
            }]
          | sort_by(-.total_aic) | .[:10]
        )
      }' "$dir/logs.json" > "$dir/snapshot.json"

      runs=$(jq '.raw_runs' "$dir/snapshot.json")
      echo "Runs in window: $runs"
      if [ "$runs" -eq 0 ]; then
        # The copilot harness skips the engine when a noop is already in the safe outputs file.
        mkdir -p "$(dirname "$GH_AW_SAFE_OUTPUTS")"
        jq -nc '{type: "noop", message: "No agentic workflow runs in the last 24 hours"}' >> "$GH_AW_SAFE_OUTPUTS"
      fi
safe-outputs:
  create-issue:
    title-prefix: "[agentic-token-audit] "
    close-older-issues: true
    expires: 7d
    max: 1
  noop:
    report-as-issue: false
    max: 1
---

# Token audit

Repo: `${{ github.repository }}`. Flow: [agentic-token-audit README](README.md#agentic-token-audit).

You audit AI Credit (AIC) use of the agentic workflows in this repo. 1 AIC is $0.01. The numbers are gh-aw estimates from public model pricing, not the provider bill. Say so once in the issue.

## Data

- `/tmp/gh-aw/agentic-token-audit/snapshot.json`: already aggregated by a pre-agent step. Use it, do not recompute from the raw file.
- `/tmp/gh-aw/agentic-token-audit/logs.json`: raw `gh aw logs --json` output. Open it only to look up a run the snapshot points at.
- `/tmp/gh-aw/agentic-token-audit/logs-exit.txt`: a non-zero exit code means the window may be partial (rate limit). Say so in the issue.
- `/tmp/gh-aw/repo-memory/default/`: earlier daily snapshots `YYYY-MM-DD.json` and `rolling-summary.json`.

The caps per workflow are in each workflow's frontmatter (`max-ai-credits` per run). Read them from `.github/workflows/<name>.md` when you need them.

## 1. Persist

1. Copy `snapshot.json` to `/tmp/gh-aw/repo-memory/default/<today UTC>.json`.
2. Load `rolling-summary.json` (an array; missing means empty), append `{date, total_aic, completed_runs, total_action_minutes}` for today, keep the last 90 entries, save.
3. When `completed_runs` is 0, skip step 2 so the trend gets no fake zero.

## 2. Report

Create one issue. Title: the total AIC and the heaviest workflow, for example `12.40 AIC, builder 61%`. Sections, `###` headings, plain ASCII:

1. **Summary**: window, completed runs, total AIC (and dollars), total Actions minutes, active workflows. When `raw_runs` > 0 but `completed_runs` is 0, say the window had runs but none completed.
2. **Per workflow**: table of workflow, runs, total AIC, avg AIC, max AIC, cap per run, avg turns, failures, link to the costliest run. Sorted by total AIC.
3. **Per flow**: the top flows (`flows`, gh-aw episodes): representative workflow, runs, total AIC. A flow is one chain such as triage, bug-fix, builder, reviewer rounds.
4. **Trend**: today against the average of the earlier entries in `rolling-summary.json`, when there are at least 2.
5. **Observations**, each with a run link:
   - a workflow above 30% of total AIC;
   - a run whose AIC is at or above 80% of its workflow's `max-ai-credits` (the cap is close; tune it or the prompt);
   - a workflow whose average stays under 20% of its cap for the window (the cap can come down);
   - failures or errors relative to runs.
6. Footer: `Generated by agentic-token-audit (report only).`

Never change workflow files, open PRs or comment elsewhere. This run is unattended: the output is the issue, or `noop` when there is nothing to report.
