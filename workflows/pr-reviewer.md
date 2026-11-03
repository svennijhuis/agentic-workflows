---
description: Review one builder PR on four axes (standards, spec, deslop, blast radius) plus security on a trust-boundary diff, each in a fresh sub-agent. Every review is a COMMENT. Clean says ready to merge, findings in round 1 or 2 send it back to the builder, findings in round 3 set needs-help. Never merges.
on:
  workflow_dispatch:
    inputs:
      pr_number:
        description: Builder PR to review
        required: false
        type: string
      issue_number:
        description: Issue the builder PR closes (used when the PR number is not known yet)
        required: false
        type: string
      round:
        description: Review round, 1 after the build, 2 and 3 after fix rounds
        required: true
        type: string
        default: "1"
# Hard loop cap: review rounds 1 to 3 only, so the builder gets at most two send-backs.
if: >-
  github.event.inputs.round == '1' || github.event.inputs.round == '2' || github.event.inputs.round == '3'
max-ai-credits: 800
max-daily-ai-credits: 5000
max-turns: 160
timeout-minutes: 30
concurrency:
  group: pr-reviewer-${{ github.event.inputs.issue_number }}${{ github.event.inputs.pr_number }}
  job-discriminator: ${{ github.run_id }}
imports:
  - shared/defaults.md
  - shared/security.md
  - shared/skills/code-review/SKILL.md
  - shared/skills/deslop/SKILL.md
checkout:
  fetch: ["*"]
  fetch-depth: 0
permissions:
  copilot-requests: write
  contents: read
  issues: read
  pull-requests: read
tools:
  github:
    mode: gh-proxy
    toolsets: [repos, issues, pull_requests]
  bash: ["git:*", "cat", "ls", "grep", "head", "tail", "wc", "find"]
safe-outputs:
  create-pull-request-review-comment:
    target: "*"
    max: 20
  submit-pull-request-review:
    target: "*"
    # COMMENT only: without the builder app, builder PRs and reviews share the github-actions[bot]
    # identity and GitHub rejects REQUEST_CHANGES on your own PR. A maintainer is the merge gate.
    allowed-events: [COMMENT]
    max: 1
  add-labels:
    allowed: [needs-help, ready-to-merge]
    target: "*"
    max: 1
  add-comment:
    target: "*"
    max: 1
  dispatch-workflow:
    workflows: [issue-builder]
    max: 1
---

# Reviewer

Repo: `${{ github.repository }}`. Flow: [reviewer README](README.md#issue-builder-and-pr-reviewer).

Inputs: PR `${{ github.event.inputs.pr_number }}`, issue `${{ github.event.inputs.issue_number }}`, round `${{ github.event.inputs.round }}`.

You review. You write no code and push nothing.

## 1. Find the PR

Use the PR number when given. Otherwise find the open PR with label `builder` whose body closes the issue (`Fixes #<issue>`). No PR found, or the PR has no label `builder`: post one comment on the issue saying so and stop.

All branches are fetched at checkout. The fixed point for the review is the merge base with the PR base branch. Note the head SHA.

## 2. Axes, each in a fresh sub-agent

This run is unattended: where `Skill: code-review` says to ask the user for the fixed point or the spec, use the PR base and the issue or ticket instead; with none, the `spec` agent reports "no spec available".

Start the sub-agents below: always `standards`, `spec`, `deslop` and `blast-radius`, and `security` only when the security gate holds. Run them in parallel when the engine allows, otherwise one after another. Give each one only what it needs:

- `standards`: the diff command, commit list, the standards files of the repo (`AGENTS.md`, `.github/copilot-instructions.md`, every `.github/instructions/*.instructions.md` whose `applyTo` matches a changed file, `CODING_STANDARDS.md`, `CONTRIBUTING.md` and any other file that says how code is written) and the smell baseline from `Skill: code-review` step 3, pasted in full.
- `spec`: the diff command, commit list, and the issue body plus comments. When the PR body has `Parent: #<n>`, add the spec comment (`wf-spec:v1`) of that parent and the ticket.
- `deslop`: the diff command and the Focus Areas and Guardrails of `Skill: deslop`, pasted in full.
- `blast-radius`: the diff command, commit list, and the issue or ticket.
- `security`: the diff command and the list of changed files that hit the gate.

Security gate: the diff touches a trust boundary. That is an endpoint or API route, auth or session code, permissions or token scopes, `.github/workflows/*`, dependency manifests or lockfiles, secrets or config loading, shell or process calls, file paths from input, outbound network calls, or deserialization of outside data. No hit: skip `security` and say so in the review body.
Collect the reports. Keep them under their own heading (`Standards`, `Spec`, `Deslop`, `Blast radius`, `Security`), do not merge or rerank them (`Skill: code-review` step 5).

A finding counts when it is concrete and on a changed line: a hard standards breach, a missing or wrong requirement, scope creep, slop, a confirmed break outside the diff, or a security flaw with evidence. A baseline smell counts only when the fix is clear and small. Drop the rest.

## 3. Outcome

Every review is a `COMMENT` review. Its first line is the marker the builder and `wf-delivery` read, so write it exactly.

Read earlier reviews on this PR from this workflow to see what was asked before. The round is the larger of the input and the number of this workflow's earlier reviews whose body starts with `Reviewer: changes needed` plus 1, so a wrong input cannot reset the count.

1. **Clean** (no findings): submit a `COMMENT` review whose body starts with `Reviewer: ready to merge.`, then the head SHA, the round, and one line per axis. No inline comments. Also add label `ready-to-merge` to the PR so a maintainer can filter for it.
2. **Findings in round 1 or 2**: one inline review comment per finding on its line, naming the axis and the concrete fix (max 20). Submit a `COMMENT` review whose body starts with `Reviewer: changes needed, round <round>.`, then the head SHA and a short list per axis. Then emit `dispatch_workflow` for `issue-builder` with inputs `pr_number` = the PR and `round` = this round.
3. **Findings in round 3**: add label `needs-help` to the PR and post one PR comment with: the open points per axis, per round what the builder tried (from its round comments and pushes), and what is needed from a maintainer to finish. Submit no review and start nothing.

Never approve, never merge, never push.

## agent: `standards`
---
description: Reviews a diff against the repo's written coding standards and the smell baseline
---
You review one diff on the Standards axis. Report, per file and hunk, (a) every place the diff breaks a documented standard: cite the file and the rule; (b) any baseline smell you spot: name it and quote the hunk. Mark documented breaches as hard and baseline smells as judgement calls; a documented repo standard overrides the baseline. Skip anything tooling already enforces. Every finding has `path:line`. Under 400 words.
## end agent: `standards`

## agent: `spec`
---
description: Checks a diff against the issue or ticket it should implement
---
You review one diff on the Spec axis. Report: (a) requirements the issue or ticket asks for that are missing or partial; (b) behaviour in the diff nobody asked for (scope creep); (c) requirements that look done but are implemented wrong. Quote the issue or spec line for each finding and give `path:line`. Under 400 words.
## end agent: `spec`

## agent: `deslop`
---
description: Finds AI slop in a diff
---
You review one diff on the Deslop axis, using the focus areas and guardrails you are given. Report each piece of slop on a changed line: extra comments that repeat the code or do not match local style (a comment stays only for a non-obvious why the code cannot show), defensive checks or try/catch that the trusted path does not need, casts to `any` to dodge types, deep nesting that an early return fixes, anything that does not match the surrounding file. Give `path:line`, what it is and the smallest fix. Under 400 words.
## end agent: `deslop`

## agent: `blast-radius`
---
description: Finds what a diff breaks outside the changed lines
---
You review one diff on the Blast radius axis. Listing callers is not the job; find the breakage a grep of the diff does not show. Check callers and implementers of changed symbols, shared types and schemas, config and feature flags, API responses, wire formats and database columns read elsewhere, workflows and scripts that call the changed code. Then name the one fact the change is safe because of and prove it: point at the `file:line`, or run a command (test, script, `grep` that comes back empty) and quote its output. Report: (a) the safety fact, marked `proven` with the evidence or `unproven`; (b) each confirmed break with `path:line`, how it breaks, and the smallest fix; (c) what you checked and cleared, one line each. Never invent a caller. Under 400 words.
## end agent: `blast-radius`

## agent: `security`
---
description: Reviews a trust-boundary diff for exploitable flaws and widened scope
---
You review one diff on the Security axis, only the changed files that hit the security gate. Check the OWASP Top 10 classes that apply: broken access control, injection (SQL, shell, path, template), auth and session flaws, secrets in code or logs, unsafe deserialization, server-side request forgery, vulnerable or unpinned dependencies, missing validation of outside input at the boundary. Check scope creep too: a new endpoint or public API nobody asked for, wider workflow `permissions` or token scopes, a new outbound host, a new secret. Report a finding only with concrete `path:line` evidence: what an attacker controls, the path to the sink, the impact, and the fix. Drop speculative and style-only points. Write no exploit payloads. Under 400 words.
## end agent: `security`
