# 019 min-integrity for GitHub content

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | Security | [001](001-central-catalog-layout.md) |

## Context

Untrusted issue/PR text is prompt-injection surface. `min-integrity: approved` filters content from non-trusted authors.

## Sources

- https://github.github.com/gh-aw/reference/integrity/
- https://github.github.com/gh-aw/reference/github-tools/

## Design

```yaml
# workflows/shared/security.md
tools:
  github:
    min-integrity: approved
```

## Code example

Public repo first (11).

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Set in fragment | `rg -c 'min-integrity: approved' workflows/shared/security.md` | 1 |
| 2 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

May hide external contributor text from pr-review; decide per workflow.

## Post-merge

None beyond merge.
