---
description: Review one builder PR on three axes (standards, spec, deslop), each in a fresh sub-agent. Clean gives a COMMENT for Sven, findings in round 1 or 2 send it back to the builder, findings in round 3 set needs-help. Never merges.
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
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 40
timeout-minutes: 20
concurrency:
  group: reviewer-${{ github.event.inputs.issue_number }}${{ github.event.inputs.pr_number }}
  job-discriminator: ${{ github.run_id }}
imports:
  - shared/defaults.md
  - shared/security.md
  - shared/skills/code-review.md
  - shared/skills/deslop.md
permissions:
  copilot-requests: write
  contents: read
  issues: read
  pull-requests: read
tools:
  github:
    toolsets: [repos, issues, pull_requests]
  bash: ["git:*", "cat", "ls", "grep", "head", "tail", "wc", "find"]
safe-outputs:
  create-pull-request-review-comment:
    target: "*"
    max: 20
  submit-pull-request-review:
    target: "*"
    allowed-events: [COMMENT, REQUEST_CHANGES]
    supersede-older-reviews: true
    max: 1
  add-labels:
    allowed: [needs-help]
    target: "*"
    max: 1
  add-comment:
    target: "*"
    max: 1
  dispatch-workflow:
    workflows: [builder]
    max: 1
---

# Reviewer

Repo: `${{ github.repository }}`. Flow: [reviewer README](README.md#builder-and-reviewer).

Inputs: PR `${{ github.event.inputs.pr_number }}`, issue `${{ github.event.inputs.issue_number }}`, round `${{ github.event.inputs.round }}`.

You review. You write no code and push nothing.

## 1. Find the PR

Use the PR number when given. Otherwise find the open PR with label `builder` whose body closes the issue (`Fixes #<issue>`). No PR found, or the PR has no label `builder`: post one comment on the issue saying so and stop.

Fetch the head branch and the base (`git fetch origin <base> <head>`). The fixed point for the review is the merge base with the PR base branch. Note the head SHA.

## 2. Three axes, each in a fresh sub-agent

Start the three sub-agents below. Run them in parallel when the engine allows, otherwise one after another. Give each one only what it needs:

- `standards`: the diff command, commit list, the standards files of the repo (`AGENTS.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md` and any other file that says how code is written) and the smell baseline from `Skill: code-review` step 3, pasted in full.
- `spec`: the diff command, commit list, and the issue body plus comments. When the PR body has `Parent: #<n>`, add the spec comment (`wf-spec:v1`) of that parent and the ticket.
- `deslop`: the diff command and the Focus Areas and Guardrails of `Skill: deslop`, pasted in full.

Collect the three reports. Keep them under their own heading (`Standards`, `Spec`, `Deslop`), do not merge or rerank them (`Skill: code-review` step 5).

A finding counts when it is concrete and on a changed line: a hard standards breach, a missing or wrong requirement, scope creep, or slop. A baseline smell counts only when the fix is clear and small. Drop the rest.

## 3. Outcome

Read earlier reviews on this PR from this workflow to see what was asked before.

1. **Clean** (no findings): submit a `COMMENT` review whose body starts with `Reviewer: klaar voor Sven.`, then the head SHA, the round, and one line per axis. No inline comments.
2. **Findings in round 1 or 2**: one inline review comment per finding on its line, naming the axis and the concrete fix (max 20). Submit `REQUEST_CHANGES` with a short list per axis. Then emit `dispatch_workflow` for `builder` with inputs `pr_number` = the PR and `round` = this round.
3. **Findings in round 3**: add label `needs-help` to the PR and post one PR comment with: the open points per axis, per round what the builder tried (from its round comments and pushes), and what is needed from Sven to finish. Submit no review and start nothing.

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
You review one diff on the Deslop axis, using the focus areas and guardrails you are given. Report each piece of slop on a changed line: extra comments that repeat the code or do not match local style, defensive checks or try/catch that the trusted path does not need, casts to `any` to dodge types, deep nesting that an early return fixes, anything that does not match the surrounding file. Give `path:line`, what it is and the smallest fix. Under 400 words.
## end agent: `deslop`
