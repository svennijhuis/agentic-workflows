# 051 Link checker: fix broken doc links

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Broken links rot docs. Deterministic link check in `steps:`, agent fixes only when broken links exist, else noop (0 AIC).

## Sources

- https://github.com/githubnext/agentics/blob/main/workflows/link-checker.md

## Design

Files: `workflows/link-checker.md`, `workflows/link-checker.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Link checker: fix broken doc links"
on:
  schedule: weekly
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
steps:
  - name: Find broken links
    run: |
      npx --yes lychee --no-progress --format plain '**/*.md' > /tmp/gh-aw/agent/broken-links.txt || true
      [ -s /tmp/gh-aw/agent/broken-links.txt ] || echo '{"type":"noop","message":"no broken links"}' >> "$GH_AW_SAFE_OUTPUTS"
imports:
  - shared/defaults.md
  - shared/security.md
permissions:
  contents: read
  issues: read
  copilot-requests: none
tools:
  github:
    toolsets: [repos]
  edit:
network:
  allowed: [defaults, node]
safe-outputs:
  create-pull-request:
    title-prefix: "[link-checker] "
    draft: true
    max: 1
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["steps (deterministic)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: create-pull-request"]
```

## Code example

Prompt body:

```markdown
Read `/tmp/gh-aw/agent/broken-links.txt`. Fix or remove each broken link. Open one draft PR.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/link-checker@v1
git add .github/workflows/link-checker.md .github/workflows/link-checker.lock.yml
gh aw update link-checker            # later, 3-way merge
gh aw logs link-checker --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/link-checker.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/link-checker.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/link-checker.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/link-checker.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/link-checker.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/link-checker.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/link-checker.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/link-checker.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/link-checker.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[link-checker' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/link-checker.lock.yml` | workflows/link-checker.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/link-checker/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/link-checker.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

Noise: start `staged: true` (020) and pilot on one repo (F00 verification skill).

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
