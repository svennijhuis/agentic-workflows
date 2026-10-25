# Repository layout (C02)

Owner variable: `svennijhuis` today. Only owner strings and org-only settings change at org switch ([ARC06](../pbi/done/ARC06-org-switch.md)). Workflow files, policies, and pins stay the same.

## Tree (depth 2)

```text
.
├── aw.yml
├── AGENTS.md
├── CHANGELOG.md
├── README.md
├── CONTRIBUTING.md
├── workflows/
│   ├── squad-review.md
│   ├── squad-review.lock.yml
│   └── shared/
│       ├── defaults.md
│       ├── security.md
│       ├── reporting.md
│       ├── agentpacks.md
│       ├── mcp/
│       └── prompts/
├── policies/
│   ├── POLnn.yml
│   └── checks/
├── scripts/
│   └── verify.sh
├── test/
│   └── fixtures/
├── governance/
│   ├── rollout.yml
│   └── rulesets/
├── docs/
│   ├── how-to/
│   ├── reference/
│   ├── explanation/
│   └── pbi/
└── .github/
    ├── aw.json
    ├── copilot-instructions.md
    ├── instructions/
    ├── agents/
    ├── skills/
    └── workflows/
```

Install: `gh aw add svennijhuis/agentic-workflows/<workflow-stem>@vX.Y.Z`. Workflow files are flat under `workflows/` (no nested package paths in Block 1).

## Why `workflows/shared/`

gh-aw v0.93.4 refuses imports outside the workflows folder, for example: `path ../shared/defaults.md must be within workflows folder`. Shared fragments therefore live at `workflows/shared/`, not a top-level `shared/`.

## Post-F01 squad-review removal

When [F01](../pbi/agent-factory/F01-pr-review.md) ships, delete:

- `workflows/squad-review.md`
- `workflows/squad-review.lock.yml`
- `workflows/shared/agentpacks.md` (only if F01 does not reuse it)
- `docs/reference/squad-review.md`
- The `workflows/squad-review.md` line in `aw.yml` `includes:`

## See also

- PBI [C02](../pbi/done/C02-org-ready-layout.md)
- [decisions/0001-repo-layout.md](../pbi/decisions/0001-repo-layout.md)
