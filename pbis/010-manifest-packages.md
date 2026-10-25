# 010 aw.yml package README and nested packages

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P3 | Todo | Platform | [001](001-central-catalog-layout.md) |

## Context

`gh aw add owner/repo` installs the package root from `aw.yml`. Nested packages (`workflows/ops/aw.yml`) let consumers add a bundle (ops: token-audit, exception-watcher).

## Sources

- https://github.github.com/gh-aw/reference/aw-yml-package-manifest/
- https://github.github.com/gh-aw/specs/repository-package-manifest-specification/

## Design

```yaml
# workflows/ops/aw.yml (later)
manifest-version: "1"
name: ops
includes:
  - ../token-audit.md
  - ../exception-watcher.md
```

## Code example

```bash
gh aw add svennijhuis/agentic-workflows/workflows/ops@v1
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Manifest valid | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | succeeded |
| 2 | Spec read | `curl -sL https://github.github.com/gh-aw/reference/aw-yml-package-manifest/ \| rg -c includes` | >= 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Nested package path semantics to verify on the spec page before shipping.

## Post-merge

None beyond merge.
