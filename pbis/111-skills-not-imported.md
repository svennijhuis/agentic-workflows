# 111 Fix: `skills:` silently dropped from imported fragment

| Priority | Status | Epic | Depends on |
| --- | --- | --- | --- |
| P1 | Todo | pr-review | [002](002-pin-agentpacks-imports.md) |

## Context

Observed on this branch (gh-aw v0.93.4): `workflows/shared/agentpacks.md` declares `skills: [.../squad/skills/squad@<sha>]`, but `pr-review.lock.yml` has no skill install step. Moving the same line into `pr-review.md` frontmatter makes the compiler emit `Install frontmatter skill: svennijhuis/agentPacks/plugins/squad/skills/squad` and `GH_AW_INFO_SKILLS`. Without it `/squad-review` cannot load `squad` (`disable-model-invocation`). Pre-existing on main (old `shared/squad.md` had the same pattern). Gist point 8: turn the trap into a check (C01/POL).

## Sources

- https://github.github.com/gh-aw/reference/imports/
- https://github.github.com/gh-aw/reference/frontmatter/
- https://gist.github.com/ayush-that/809328c80b267ffa1d23349f4bfebbac (point 8)

## Design

```diff
 # workflows/shared/agentpacks.md
-skills:
-  - svennijhuis/agentPacks/plugins/squad/skills/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684
 plugins:
   - svennijhuis/agentPacks/plugins/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684
 # workflows/pr-review.md
+skills:
+  - svennijhuis/agentPacks/plugins/squad/skills/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684
 permissions:
```
Also: one line in `docs/AGENTPACKS.md`, `CONTRIBUTING.md` (`skills:` and caps do not merge from imports). Add the rule to the C01/POL check list.

## Code example

Verified locally on a scratch copy: after the move, lock line `- name: "Install frontmatter skill: svennijhuis/agentPacks/plugins/squad/skills/squad"` appears.

## DoD

| # | Check | Command | Expected |
| --- | --- | --- | --- |
| 1 | Skill install step in lock | `rg -c 'Install frontmatter skill: svennijhuis/agentPacks/plugins/squad/skills/squad' workflows/pr-review.lock.yml` | 1 |
| 2 | No skills in fragments | `rg -n '^skills:' workflows/shared` | no output |
| 3 | Compile | `gh aw compile --dir workflows --strict 2>&1 \| tail -1` | Compiled 1 workflow: 1 succeeded, 1 warning |

## Evidence

Not started. Paste the real output of each DoD command here when done.

## Non-goals

No other frontmatter changes.

## Risks

None known; plugin import already merges.

## Post-merge

None beyond merge.
