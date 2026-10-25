# 100 agentPacks: standards importable by gh-aw (PR #79)

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | Cross-repo | none |

## Context

Single source: `plugins/<lang>/standards/*.md` + `shared/standards/*.md`. gh-aw imports plain md by path@ref (verified). Contract test keeps them plain (no frontmatter, no `${{`, no `{{#`).

## Sources

- https://github.com/svennijhuis/agentPacks/pull/79
- https://github.github.com/gh-aw/reference/imports/

## Design

Files: `docs/GITHUB-AGENTIC-WORKFLOWS.md` (section), `tools/AgentPacks.Cli.Tests/StandardsGhAwImportContractTests.cs`.

## Code example

```yaml
imports:
  - svennijhuis/agentPacks/plugins/dotnet/standards/csharp.md@<tag>
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Tests | `dotnet test tools/AgentPacks.slnx 2>&1 \| rg 'Passed!'` | Failed: 0, Passed: 608 |
| 2 | Validate | `dotnet run --project tools/AgentPacks.Cli -- validate` | Source validation passed. |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No index files with nested relative imports.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
