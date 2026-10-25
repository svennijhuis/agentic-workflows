# 101 Verify plugin agents load from main ref

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | Cross-repo | F00 |

## Context

Lock has a runtime warning when a plugin dir has no `.md` after install (hints at marketplace branch). Main has `plugins/squad/agents/*.md`; confirm in trial that Copilot sees `squad-reviewer`.

## Sources

- https://github.github.com/gh-aw/reference/frontmatter/
- https://github.com/svennijhuis/agentPacks/blob/main/plugins/squad/plugin.json

## Design

Check `plugin-diagnostics.log` artifact: `Markdown files found: N`.

## Code example

See Design.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Diagnostics | `gh aw logs pr-review --artifacts agent && rg 'Markdown files found' -r '' --no-filename . \| head -1` | N > 0 |
| 2 | Agent used | `gh aw audit <run> \| rg -c squad-reviewer` | >= 1 |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

Nothing outside the files named in Design.

## Risks

If agents need generated layout, pin the plugin to a marketplace SHA instead and note it.

## Post-merge

None beyond merge.
