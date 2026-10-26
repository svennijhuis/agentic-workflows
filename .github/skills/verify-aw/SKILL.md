# verify-aw

Run the catalog gate before you open or update a PR. This skill has no rules of its own; it only calls `scripts/verify.sh`.

## When to run

- After you change anything under `workflows/`, `policies/`, `test/fixtures/`, or docs that affect compile or POL checks.
- Before you ask for review on a workflow or policy change.
- When CI is blocked (Q0): the verify log on the exact commit SHA is the gate.

## Command

From the repository root:

```bash
./scripts/verify.sh
```

## Green output

- Section headers only, each line prefixed with `# `.
- No failure lines.
- Last line is exactly: `0 failures`
- Exit code `0`.

Example tail:

```text
# policy checks
0 failures
```

## Read a failure line

Format: `file:line RULE message`

Fix the file at that path. Re-run `./scripts/verify.sh` until the last line is `0 failures`.

## Exit codes

- `0`: green, last line `0 failures`.
- `1`: failed. Each finding is a `file:line RULE message` line. Fix it and re-run.
- `2`: needs-human. The gate could not run, so the result is inconclusive, never a pass. The line reads `file:line VERIFY needs-human <reason>`: a tool from `.github/aw.json` is missing or at the wrong version, or a producer crashed with no finding. Do not work around it. Stop and ask a human to install the pinned tool (`.github/aw.json` `tools:` has the version, url and sha256) or to look at the crashed producer, then re-run.

## One policy check on one file

```bash
bash policies/checks/POL16.sh path/to/file.md
```

Use the POL id that matches the rule (see `policies/POLnn.yml`).

## Trial (printed only, do not run here)

Trial runs spend AIC. Block 1 docs only print the command. Run only after Sven's exact yes for that workflow.

```bash
# gh aw trial --repo <trial-repo> --workflow <name>   # Sven's yes required
```

See [docs/how-to/trial.md](../../../docs/how-to/trial.md) and [docs/how-to/verify-workflow.md](../../../docs/how-to/verify-workflow.md).
