---
description: Label resolved wayfinder maps ready for specification.
intent: Keep wayfinder maps open until a spec is published by adding a single-use to-spec gate after all decision sub-issues are closed.
on:
  issues:
    types: [closed, edited, labeled, unlabeled, reopened]
  workflow_dispatch:
# /wayfinder (run locally with the user's gh) closes each decision ticket, then edits the map. Only a
# closed or reopened wayfinder:* ticket, or the wayfinder:map label itself, can make a map ready.
# Map edits, ticket creation and claims do not, so they start nothing.
if: >-
  github.event_name == 'workflow_dispatch' ||
  ((github.event.action == 'closed' || github.event.action == 'reopened') &&
   contains(toJSON(github.event.issue.labels.*.name), 'wayfinder:')) ||
  ((github.event.action == 'labeled' || github.event.action == 'unlabeled') &&
   github.event.label.name == 'wayfinder:map')
max-ai-credits: 75
max-daily-ai-credits: 750
max-turns: 30
timeout-minutes: 10
concurrency:
  group: wf-to-spec
  queue: max
  job-discriminator: ${{ github.run_id }}
imports:
  - shared/defaults.md
  - uses: shared/has-work.md
    with:
      label-sets: "wayfinder:map,-to-spec,-specced,-to-tickets,-to-plan,-planned"
permissions:
  copilot-requests: write
  contents: read
  issues: read
  pull-requests: read
tools:
  github:
    mode: gh-proxy
    toolsets: [repos, issues]
safe-outputs:
  add-labels:
    target: "*"
    allowed: [to-spec]
    required-labels: ["wayfinder:map"]
    issues: true
    pull-requests: false
    create-if-missing: true
    max: 1
  dispatch-workflow:
    workflows: [wf-spec]
    max: 1
  noop:
    report-as-issue: false
    max: 1
network:
  allowed: []
---

# Label resolved wayfinder maps for specification

Find the oldest open issue labelled `wayfinder:map` that is not already labelled
`to-spec`, `specced`, `to-tickets`, `to-plan`, or `planned` and has all of its wayfinder decision
sub-issues closed.

A map becomes eligible for the specification gate when:

- it has at least one native wayfinder decision sub-issue, and every such
  sub-issue is closed (paginate the full list);
- the map itself is still open; and
- it does not already have a spec marker or a follow-on planning state.

When such a map is found, add the label `to-spec`, then emit `dispatch_workflow`
for `wf-spec` (no inputs), and stop. A label set by this workflow does not start
other workflows (GitHub ignores events made with `GITHUB_TOKEN`); the dispatch
does. Do not close the
map, do not create a planning ticket, and do not publish a spec from this
workflow.

If no eligible map is found, call `noop` with the first blocking condition and
make no visible write.

An explicit `to-spec` label on an ordinary issue is also supported by the
specification workflow; this automatic gate only selects resolved maps.
