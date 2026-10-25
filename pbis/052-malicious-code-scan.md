# 052 Malicious code scan

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | Workflows | [001](001-central-catalog-layout.md), [003](003-cost-caps.md), [004](004-personal-copilot-auth.md) |

## Context

Daily review of the last 3 days of commits for suspicious patterns (exfiltration, obfuscation, install hooks). Findings as code-scanning alerts.

## Sources

- https://github.github.com/gh-aw/gallery/security-review/
- https://github.com/githubnext/agentics/blob/main/workflows/malicious-code-scan.md

## Design

Files: `workflows/malicious-code-scan.md`, `workflows/malicious-code-scan.lock.yml`, `aw.yml` include, row in `workflows/README.md` and root README.

Frontmatter (compile-checked against gh-aw v0.93.4 while writing this PBI):

```yaml
---
description: "Malicious code scan"
on:
  schedule: daily
  workflow_dispatch:
engine: copilot
max-ai-credits: 50
max-daily-ai-credits: 200
max-turns: 15
timeout-minutes: 10
imports:
  - shared/defaults.md
  - shared/security.md
permissions:
  contents: read
  security-events: read
  issues: read
  copilot-requests: none
tools:
  github:
    toolsets: [repos]
safe-outputs:
  create-code-scanning-alert:
    max: 10
---
```

```mermaid
flowchart LR
  T["schedule"] --> A["pre-activation (skip rules)"]
  A -->|skip / noop| Z["end, 0 AIC"]
  A --> B["agent job (read-only, caps 50/200/15/10)"]
  B --> D["threat detection"]
  D --> S["safe-outputs: create-code-scanning-alert"]
```

## Code example

Prompt body:

```markdown
Diff commits from the last 3 days. Flag: base64 blobs, network calls in build scripts, new postinstall hooks, credential reads. One alert per finding with file and line. No findings: noop.
```

Consumer:

```bash
gh aw add svennijhuis/agentic-workflows/malicious-code-scan@v1
git add .github/workflows/malicious-code-scan.md .github/workflows/malicious-code-scan.lock.yml
gh aw update malicious-code-scan            # later, 3-way merge
gh aw logs malicious-code-scan --json | jq '.runs[] | {aic, duration}'
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Workflow file exists | `test -f workflows/malicious-code-scan.md && echo ok` | ok |
| 2 | Compiles strict | `gh aw compile workflows/malicious-code-scan.md --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded |
| 3 | Lint clean | `gh aw lint workflows/malicious-code-scan.md; echo rc=$?` | rc=0 |
| 4 | Four cost caps | `rg -c '^(max-ai-credits: 50\|max-daily-ai-credits: 200\|max-turns: 15\|timeout-minutes: 10)$' workflows/malicious-code-scan.md` | 4 |
| 5 | Personal auth | `rg -c '^  copilot-requests: none$' workflows/malicious-code-scan.md` | 1 |
| 6 | No org billing mode | `rg -n 'copilot-requests: write' workflows/malicious-code-scan.md` | no output |
| 7 | No branch refs | `rg -n '@(main\|marketplace\|master)\b' workflows/malicious-code-scan.md` | no output |
| 8 | Every safe output capped | `rg -c '^    max: ' workflows/malicious-code-scan.md` | >= 1 |
| 9 | In manifest | `rg -c 'workflows/malicious-code-scan.md' aw.yml` | 1 |
| 10 | Listed in workflows/README.md | `rg -c '\[malicious-code-scan' workflows/README.md` | 1 |
| 11 | Lock committed | `git ls-files workflows/malicious-code-scan.lock.yml` | workflows/malicious-code-scan.lock.yml |
| 12 | Name is not an agentPacks skill | `gh api 'repos/svennijhuis/agentPacks/git/trees/main?recursive=1' --jq '.tree[].path' \| rg -x 'plugins/.*/skills/malicious-code-scan/SKILL.md'` | no output |
| 13 | Trial dry run | `gh aw trial ./workflows/malicious-code-scan.md --dry-run; echo rc=$?` | rc=0 |
| 14 | Guard script (C01/POL) | `bash scripts/verify.sh; echo rc=$?` | rc=0 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No write outputs beyond the listed safe-outputs. No cross-repo writes.

## Risks

False positives on test fixtures; keep alerts as warnings.

## Post-merge

Tag a catalog release (006). Consumer sets `COPILOT_GITHUB_TOKEN` (012). Check AIC after 5 runs (076).
