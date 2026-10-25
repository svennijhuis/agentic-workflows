# 089 ChatOps conventions

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P2 | Todo | Patterns | [005](005-naming-rules.md) |

## Context

Slash names = workflow names, kebab-case, never an agentPacks skill or command name, `strategy: centralized`, `reaction: eyes`, status comment on.

## Sources

- https://github.github.com/gh-aw/patterns/chat-ops/
- https://github.github.com/gh-aw/reference/command-triggers/

## Design

```yaml
on:
  slash_command:
    name: <workflow-name>
    strategy: centralized
    events: [pull_request_comment]
  reaction: eyes
```

## Code example

Rule in CONTRIBUTING.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Rule in CONTRIBUTING | `rg -c 'slash' CONTRIBUTING.md` | >= 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

Low; doc or config only.

## Post-merge

None beyond merge.
