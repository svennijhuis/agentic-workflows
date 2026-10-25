# 103 pstack principles prompt fragment for write workflows

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Cross-repo | [001](001-central-catalog-layout.md) |

## Context

Write workflows (pr-fix, simplifier, test-improver) share rules: reproduce first, subtract before add, prove with real output, never weaken a test. One fragment, imported. Gist: verification first, deterministic parts in scripts, every repeated mistake becomes a check.

## Sources

- https://github.com/cursor/plugins/tree/main/pstack/skills/principle-prove-it-works
- https://github.com/cursor/plugins/tree/main/pstack/skills/principle-subtract-before-you-add
- https://github.com/cursor/plugins/tree/main/pstack/skills/principle-fix-root-causes
- https://github.com/cursor/plugins/tree/main/pstack/skills/principle-make-operations-idempotent
- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (points 1, 4, 8, 17)

## Design

```markdown
<!-- workflows/shared/prompts/engineering-rules.md -->
---
description: Engineering rules for write workflows.
---
- Reproduce before fixing. Root cause, not symptom.
- Remove before adding. Smallest diff.
- Prove it: paste the real test output.
- Never weaken, skip or rewrite a failing test to go green.
```

## Code example

`imports: [shared/prompts/engineering-rules.md]`

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Imported by write workflows | `rg -l 'create-pull-request:\|push-to-pull-request-branch:' workflows/*.md \| xargs rg -L 'engineering-rules.md'` | no output |
| 2 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
