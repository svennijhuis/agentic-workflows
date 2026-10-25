# 027 import-schema: pick review stacks by parameter

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | pr-review | [002](002-pin-agentpacks-imports.md), [100](100-agentpacks-standards-contract.md) |

## Context

Consumers delete standards lines today. `import-schema` lets them pass `stacks: [dotnet]` instead. Verify that `imports:` inside a parameterised fragment can be conditional; if not, keep one fragment per stack.

## Sources

- https://github.github.com/gh-aw/reference/imports/

## Design

```yaml
# workflows/shared/standards/review.md
import-schema:
  stacks:
    type: array
    default: [dotnet, typescript, rust]
```
```yaml
imports:
  - uses: shared/standards/review.md
    with:
      stacks: [dotnet]
```

## Code example

Consumer passes stacks once.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Compile with param | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |
| 2 | Only dotnet in lock | `rg -c 'plugins_typescript_standards' workflows/pr-review.lock.yml` | 0 when stacks=[dotnet] |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

import-schema may not gate nested imports; prototype first, keep per-stack fragments as fallback.

## Post-merge

None beyond merge.
