# 039 pr-review: detect stacks, load only those standards

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | pr-review | [027](027-import-schema-stacks.md) |

## Context

Deterministic step lists changed file extensions; prompt says which standards apply. Cheaper than reading all 33k chars.

## Sources

- https://github.github.com/gh-aw/patterns/deterministic-ops/
- https://github.com/svennijhuis/agentPacks/blob/main/plugins/pack-check/

## Design

```yaml
steps:
  - run: git diff --name-only origin/${{ github.base_ref }}... | sed 's/.*\.//' | sort -u > /tmp/gh-aw/agent/exts.txt
```

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Step present | `rg -c 'exts.txt' workflows/pr-review.md` | 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
