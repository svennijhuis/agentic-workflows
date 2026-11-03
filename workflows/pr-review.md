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
    # Dismisses older REQUEST_CHANGES only. COMMENT close-older is the close_older job.
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
          # Dedupe: bot author, title marker, group-by-day, expiry EXPIRY_DAYS.
          # Close-older is the close_older job (minimizeComment), not supersede-older-reviews.
          # BEGIN DECIDE
          decide() {
            local files="$1" head="$2" today="$3" expiry="$4" reviews="$5"
            case "${files}" in
              ''|*[!0-9]*) return 1 ;;
            esac
            if [ "${files}" -eq 0 ]; then
              printf 'noop|empty-diff\n'
              return 0
            fi
            local best_at="" best_sha="" submitted sha state author
            if [ -n "${reviews}" ] && [ -f "${reviews}" ]; then
              while IFS=' ' read -r submitted sha state author; do
                [ -n "${submitted:-}" ] || continue
                [ "${state:-}" = "COMMENT" ] || continue
                [ "${author:-}" = "github-actions[bot]" ] || continue
                if [ -z "${best_at}" ] || [ "${submitted}" \> "${best_at}" ] || [ "${submitted}" = "${best_at}" ]; then
                  best_at="${submitted}"
                  best_sha="${sha}"
                fi
              done < "${reviews}"
            fi
            if [ -z "${best_at}" ]; then
              printf 'review|no-prior\n'
              return 0
            fi
            local today_s review_s age best_day
            best_day="${best_at%%T*}"
            today_s=$(date -u -d "${today}" +%s)
            review_s=$(date -u -d "${best_day}" +%s)
            age=$(( (today_s - review_s) / 86400 ))
            if [ "${best_sha}" = "${head}" ] && [ "${best_day}" = "${today}" ]; then
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
          files_count=$(gh api --paginate "repos/${REPO}/pulls/${PR_NUMBER}/files" --jq 'length' | awk '{ if ($0 !~ /^[0-9]+$/) exit 2; s += $1; n += 1 } END { if (n < 1) exit 2; print s }')
          case "${files_count}" in
            ''|*[!0-9]*) echo "files_count must be digits" >&2; exit 1 ;;
          esac
          head_sha=$(gh api "repos/${REPO}/pulls/${PR_NUMBER}" --jq .head.sha)
          today=$(date -u +%Y-%m-%d)
          reviews_file=$(mktemp)
          gh api --paginate "repos/${REPO}/pulls/${PR_NUMBER}/reviews" \
            --jq '.[] | select(.state == "COMMENTED") | select(.user.login == "github-actions[bot]") | select(.submitted_at != null and .commit_id != null) | select(.body != null and (.body | contains("<!-- aw-pr-review -->"))) | [.submitted_at, .commit_id, "COMMENT", .user.login] | join(" ")' \
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
            echo "review: ${reason}; close-older minimizes prior bot COMMENT reviews after publish; expiry ${EXPIRY_DAYS} days"
          fi
  agent:
    needs: [activation, diff_precheck]
    if: "needs.diff_precheck.result == 'success' && needs.diff_precheck.outputs.empty != 'true'"
  close_older:
    needs: [diff_precheck, safe_outputs]
    if: "needs.safe_outputs.result == 'success' && needs.diff_precheck.outputs.empty != 'true'"
    runs-on: ubuntu-slim
    permissions:
      actions: read
      contents: read
      pull-requests: write
    steps:
      - name: Minimize prior workflow COMMENT reviews
        env:
          PR_NUMBER: ${{ github.event.inputs.pr }}
          REPO: ${{ github.repository }}
          GH_TOKEN: ${{ github.token }}
          RUN_ID: ${{ github.run_id }}
          # Keep this equal to safe-outputs.staged. Only the string false may call minimizeComment.
          STAGED: "true"
        run: |
          set -euo pipefail
          # Close-older for COMMENT reviews. supersede-older-reviews dismisses REQUEST_CHANGES only.
          # BEGIN CLOSE
          close_plan() {
            local file="$1" run_at="$2"
            local id at author state marker published=0 any=0
            case "${run_at}" in
              [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T*) ;;
              *) return 1 ;;
            esac
            if [ ! -f "${file}" ]; then
              printf 'none\n'
              return 0
            fi
            while IFS=' ' read -r id at author state marker; do
              [ -n "${id:-}" ] || continue
              [ "${author:-}" = "github-actions[bot]" ] || continue
              [ "${state:-}" = "COMMENTED" ] || continue
              [ "${marker:-}" = "yes" ] || continue
              case "${id}" in
                *[!A-Za-z0-9_+=/-]*) return 1 ;;
              esac
              if [ "${at}" \> "${run_at}" ] || [ "${at}" = "${run_at}" ]; then
                published=1
              fi
            done < "${file}"
            if [ "${published}" -ne 1 ]; then
              printf 'none\n'
              return 0
            fi
            while IFS=' ' read -r id at author state marker; do
              [ -n "${id:-}" ] || continue
              [ "${author:-}" = "github-actions[bot]" ] || continue
              [ "${state:-}" = "COMMENTED" ] || continue
              [ "${marker:-}" = "yes" ] || continue
              if [ "${at}" \< "${run_at}" ]; then
                printf '%s\n' "${id}"
                any=1
              fi
            done < "${file}"
            if [ "${any}" -eq 0 ]; then
              printf 'none\n'
            fi
          }
          close_action() {
            local staged="$1" file="$2" run_at="$3"
            if [ "${staged}" != "false" ]; then
              printf 'skip\n'
              return 0
            fi
            close_plan "${file}" "${run_at}"
          }
          # END CLOSE
          if [ "${STAGED}" != "false" ]; then
            echo "close-older: staged, write skipped"
            exit 0
          fi
          case "${PR_NUMBER}" in
            ''|*[!0-9]*) echo "pr number must be digits" >&2; exit 1 ;;
          esac
          case "${REPO}" in
            */*) ;;
            *) echo "repo must be owner/name" >&2; exit 1 ;;
          esac
          case "${RUN_ID}" in
            ''|*[!0-9]*) echo "run id must be digits" >&2; exit 1 ;;
          esac
          run_at=$(gh api "repos/${REPO}/actions/runs/${RUN_ID}" --jq .run_started_at)
          reviews_file=$(mktemp)
          gh api --paginate "repos/${REPO}/pulls/${PR_NUMBER}/reviews" \
            --jq '.[] | [.node_id, (.submitted_at // ""), (.user.login // ""), (.state // ""), (if (.body != null and (.body | contains("<!-- aw-pr-review -->"))) then "yes" else "no" end)] | join(" ")' \
            > "${reviews_file}"
          result=$(close_action "false" "${reviews_file}" "${run_at}")
          rm -f "${reviews_file}"
          if [ "${result}" = "none" ]; then
            echo "close-older: none"
            exit 0
          fi
          while IFS= read -r id; do
            [ -n "${id}" ] || continue
            gh api graphql -f query="mutation(\$id:ID!){ minimizeComment(input:{subjectId:\$id, classifier:OUTDATED}) { minimizedComment { isMinimized } } }" -f id="${id}"
          done <<< "${result}"
          echo "close-older: minimized"
---

# PR review

Imported above: shared defaults (engine copilot), security, the report format, and the agentPacks review command. Follow that command. Do not restate the review contract here.

- Repository: `${{ github.repository }}`
- Pull request: `#${{ github.event.inputs.pr }}`

Fetch the pull request diff, files, commits, and description yourself with the GitHub tools. Nothing from the repository is pasted into this prompt.

The deterministic pre-check already ran in `diff_precheck` (0 AIC). It writes `noop` and skips this job when the pull request has no changed files, when a COMMENT review from `github-actions[bot]` carrying the title marker `<!-- aw-pr-review -->` already covers this head inside the 7 day expiry, or when that same head was reviewed today (group-by-day). A marker from any other author is ignored. The latest `submitted_at` wins, including two reviews on the same UTC date. A newer head still reviews. A review older than the expiry is reviewed again. After this run publishes a COMMENT, `close_older` minimizes older marker COMMENT reviews from `github-actions[bot]` (close-older). While `staged: true`, that step does not call the write API. `supersede-older-reviews` dismisses older REQUEST_CHANGES reviews only, and this workflow does not submit that event.

Override only the IDE I/O:

- Do not ask to save a markdown report
- Do not write `docs/reviews/` or `docs/learnings.md`
- Do not start a plan, implement, verifier, or fix round
- Do not call any safe output except `noop` or one `submit-pull-request-review`
- Event is `COMMENT` only. Never `APPROVE` or `REQUEST_CHANGES`
- The review body uses the shared report format, starts with the title line `[aw] pr-review`, and includes the marker `<!-- aw-pr-review -->`
- If you cannot review, call `noop` and stop

Staged: until Sven's yes after audited runs, outputs are previews only.
