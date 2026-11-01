# verify-aw

Run the catalog gate before you open or update a PR. This skill has no rules of its own; it only calls `make verify`.

## When to run

- After you change anything under `workflows/`, `policies/`, or `test/fixtures/`.
- Before you ask for review on a workflow or policy change.
- When CI is blocked (Q0): the verify log on the exact commit SHA is the gate.

## Command

From the repository root:

```bash
make verify
```

Same as `bash scripts/verify.sh`.

## Green output

- Section headers only, each line prefixed with `# `.
- No failure lines between headers and the summary.
- Last line is exactly: `0 failures`
- Exit code `0`.

Example tail:

```text
# POL31 repo
# POL31 fixtures
2 bad cases, 3 good cases
0 failures
```

Expected headers in order: `# make compile`, `# POL25 repo`, `# POL25 fixtures`, `# POL31 repo`, `# POL31 fixtures`.

## Read a failure line

Format: `file:line RULE message`

Fix the file at that path. Re-run `make verify` until the last line is `0 failures`.

## Exit codes

- `0`: green, last line `0 failures`.
- non-zero: failed. Each finding is a `file:line RULE message` line. Fix it and re-run. A missing gh-aw, or one not at the pin in `.github/aw.json`, fails `make compile`: run `make install`, then re-run.

## One policy check

```bash
bash policies/checks/POL25.sh path/to/tree
bash policies/checks/POL31.sh path/to/tree
```

## Trial (printed only, do not run here)

Trial runs spend AIC. Block 1 docs only print the command. Run only after Sven's exact yes for that workflow.

```bash
# gh aw trial --repo <trial-repo> --workflow <name>   # Sven's yes required
```

See [docs/how-to/trial.md](../../../docs/how-to/trial.md) and [docs/how-to/verify-workflow.md](../../../docs/how-to/verify-workflow.md).
