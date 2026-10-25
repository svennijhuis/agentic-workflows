# 011 Decide public vs private catalog

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | Governance | none |

## Context

Repo is public today. `private: true` only blocks `gh aw add`, content stays visible. Private repo needs a read token for consumers' remote imports.

## Sources

- https://github.github.com/gh-aw/guides/sharing-workflows/
- https://github.github.com/gh-aw/reference/frontmatter/

## Design

Options:
| Option | Effect |
| --- | --- |
| Public | Anyone can install; free Actions minutes |
| Private | Consumers need `github-token` on imports/plugins |

Decision recorded in `docs/GOVERNANCE.md#visibility`.

## Code example

```yaml
plugins:
  - plugin: svennijhuis/agentPacks/plugins/squad@<sha>
    github-token: ${{ secrets.AGENTPACKS_READ_TOKEN }}
```

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Decision written | `rg -n 'Decision:' docs/GOVERNANCE.md` | 1 line |
| 2 | Visibility matches | `gh repo view svennijhuis/agentic-workflows --json visibility --jq .visibility` | PUBLIC or PRIVATE per decision |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Bot does not change visibility; Sven does.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
