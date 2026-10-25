# 018 Network allowlist by ecosystem

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | Security | [001](001-central-catalog-layout.md) |

## Context

`shared/security.md` has `allowed: []`; workflows that build need ecosystem ids. Unions across imports.

## Sources

- https://github.github.com/gh-aw/reference/network/
- https://github.github.com/gh-aw/guides/network-configuration/

## Design

```yaml
# workflows/shared/network-dotnet.md
network:
  allowed: [defaults, dotnet]
# network-node.md -> [defaults, node]; network-rust.md -> [defaults, rust]
```

## Code example

```yaml
imports:
  - shared/security.md
  - shared/network-dotnet.md
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Fragments exist | `ls workflows/shared/network-*.md \| wc -l` | 3 |
| 2 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
