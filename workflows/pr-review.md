---
description: Report-only PR review. Skills and the review command come from agentPacks, not this file. Manual only.
intent: Run the agentPacks review command in GitHub Actions without copying the review contract.
on:
  workflow_dispatch:
    inputs:
      pr:
        description: Pull request number to review
        required: true
        type: string
  roles: [admin, maintainer]
  skip-bots: [dependabot, renovate, github-actions]
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 15
concurrency:
  group: pr-review-${{ github.event.inputs.pr }}
  cancel-in-progress: true
  job-discriminator: ${{ github.run_id }}
skills:
  - svennijhuis/agentPacks/plugins/squad/skills/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684
imports:
  - shared/defaults.md
  - shared/security.md
  - shared/reporting.md
  - shared/agentpacks.md
  - svennijhuis/agentPacks/plugins/squad/commands/squad-review.md@34e1dec3535baa1d77cb441ea8c98498dc9b3684
permissions:
  contents: read
  pull-requests: read
  issues: read
  actions: read
  copilot-requests: none
network:
  allowed: [defaults]
tools:
  github:
    toolsets: [repos, issues, pull_requests]
    min-integrity: approved
  bash: [cat, grep, head, ls, wc, "git diff:*", "git log:*", "git show:*"]
safe-outputs:
  staged: true
  noop:
    max: 1
    report-as-issue: false
  submit-pull-request-review:
    max: 1
    allowed-events: [COMMENT]
    target: ${{ github.event.inputs.pr }}
    supersede-older-reviews: true
jobs:
  diff_precheck:
    runs-on: ubuntu-slim
    permissions:
      contents: read
      pull-requests: read
      issues: read
      actions: read
    outputs:
      empty: ${{ steps.empty_diff.outputs.empty }}
    steps:
      - name: Empty diff pre-check
        id: empty_diff
        env:
          PR_NUMBER: ${{ github.event.inputs.pr }}
          REPO: ${{ github.repository }}
          GH_TOKEN: ${{ github.token }}
          EXPIRY_DAYS: "7"
        run: |
          set -euo pipefail
          # Dedupe: title marker, group-by-day, close-older via supersede-older-reviews, expiry EXPIRY_DAYS.
          # BEGIN DECIDE
          decide() {
            local files="$1" head="$2" today="$3" expiry="$4" reviews="$5"
            if [ "${files}" -eq 0 ]; then
              printf 'noop|empty-diff\n'
              return 0
            fi
            local best_date="" best_sha="" date sha state
            if [ -n "${reviews}" ] && [ -f "${reviews}" ]; then
              while IFS=' ' read -r date sha state; do
                [ -n "${date:-}" ] || continue
                [ "${state:-}" = "COMMENT" ] || continue
                if [ -z "${best_date}" ] || [ "${date}" \> "${best_date}" ]; then
                  best_date="${date}"
                  best_sha="${sha}"
                fi
              done < "${reviews}"
            fi
            if [ -z "${best_date}" ]; then
              printf 'review|no-prior\n'
              return 0
            fi
            local today_s review_s age
            today_s=$(date -u -d "${today}" +%s)
            review_s=$(date -u -d "${best_date}" +%s)
            age=$(( (today_s - review_s) / 86400 ))
            if [ "${best_sha}" = "${head}" ] && [ "${best_date}" = "${today}" ]; then
              printf 'noop|group-by-day\n'
              return 0
            fi
            if [ "${best_sha}" = "${head}" ] && [ "${age}" -lt "${expiry}" ]; then
              printf 'noop|title\n'
              return 0
            fi
            if [ "${age}" -ge "${expiry}" ]; then
              printf 'review|expired\n'
              return 0
            fi
            printf 'review|new-commits\n'
          }
          # END DECIDE
          case "${PR_NUMBER}" in
            ''|*[!0-9]*) echo "pr number must be digits" >&2; exit 1 ;;
          esac
          case "${REPO}" in
            */*) ;;
            *) echo "repo must be owner/name" >&2; exit 1 ;;
          esac
          files_count=$(gh api --paginate "repos/${REPO}/pulls/${PR_NUMBER}/files" --jq 'length' | awk '{s+=$1} END {print s+0}')
          head_sha=$(gh api "repos/${REPO}/pulls/${PR_NUMBER}" --jq .head.sha)
          today=$(date -u +%Y-%m-%d)
          reviews_file=$(mktemp)
          gh api --paginate "repos/${REPO}/pulls/${PR_NUMBER}/reviews" \
            --jq '.[] | select(.state == "COMMENTED") | select(.body != null and (.body | contains("<!-- aw-pr-review -->"))) | [(.submitted_at[0:10]), .commit_id, "COMMENT"] | join(" ")' \
            > "${reviews_file}"
          result=$(decide "${files_count}" "${head_sha}" "${today}" "${EXPIRY_DAYS}" "${reviews_file}")
          rm -f "${reviews_file}"
          kind=${result%%|*}
          reason=${result#*|}
          if [ "${kind}" = "noop" ]; then
            echo "empty=true" >> "${GITHUB_OUTPUT}"
            echo "noop: ${reason}" >> "${GITHUB_STEP_SUMMARY}"
            echo "noop: ${reason}"
          else
            echo "empty=false" >> "${GITHUB_OUTPUT}"
            echo "review: ${reason}; close-older-issues waits on supersede-older-reviews when a COMMENT is submitted; expiry ${EXPIRY_DAYS} days"
          fi
  agent:
    needs: [activation, diff_precheck]
    if: "needs.diff_precheck.result == 'success' && needs.diff_precheck.outputs.empty != 'true'"
---

# PR review

Imported above: shared defaults (engine copilot), security, the report format, and the agentPacks review command. Follow that command. Do not restate the review contract here.

- Repository: `${{ github.repository }}`
- Pull request: `#${{ github.event.inputs.pr }}`

Fetch the pull request diff, files, commits, and description yourself with the GitHub tools. Nothing from the repository is pasted into this prompt.

The deterministic pre-check already ran in `diff_precheck` (0 AIC). It writes `noop` and skips this job when the pull request has no changed files, when a COMMENT review carrying the title marker `<!-- aw-pr-review -->` already covers this head inside the 7 day expiry, or when that same head was reviewed today (group-by-day). A newer head still reviews. A review older than the expiry is reviewed again, and `supersede-older-reviews` closes the older workflow review on submit (close-older).

Override only the IDE I/O:

- Do not ask to save a markdown report
- Do not write `docs/reviews/` or `docs/learnings.md`
- Do not start a plan, implement, verifier, or fix round
- Do not call any safe output except `noop` or one `submit-pull-request-review`
- Event is `COMMENT` only. Never `APPROVE` or `REQUEST_CHANGES`
- The review body uses the shared report format, starts with the title line `[aw] pr-review`, and includes the marker `<!-- aw-pr-review -->`
- If you cannot review, call `noop` and stop

Staged: until Sven's yes after audited runs, outputs are previews only.
