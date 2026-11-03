---
description: Write AGENTS.md when it is missing, or update it from the commits on main since the last sync marker. One PR with only AGENTS.md, Sven merges.
on:
  workflow_dispatch:
permissions:
  copilot-requests: write
  contents: read
  pull-requests: read
network:
  allowed: []
tools:
  github:
    toolsets: [repos]
safe-outputs:
  create-pull-request:
    title-prefix: "[agents-md-sync] "
    labels: [agents-md-sync]
    draft: false
    if-no-changes: ignore
    allowed-files:
      - "AGENTS.md"
    max: 1
---

# AGENTS.md sync

Repo: `${{ github.repository }}`. Flow: [agents-md-sync README](README.md#agents-md-sync).

The last line of `AGENTS.md` is the marker `<!-- agents-md-sync: <sha> -->`, the `main` commit of the last sync.

## AGENTS.md is missing

Write one from the repo itself, short and factual:

- structure: top-level folders and what lives where
- build, test and lint commands, taken from the real files (Makefile, package.json, scripts, CI workflows)
- conventions you can see in the code and config
- where docs and standards live

Only write what the repo shows. End with the marker set to the current `main` SHA.

## AGENTS.md exists

1. Read the marker SHA. No marker: treat the whole file as handwritten, only add what is missing, and add the marker.
2. List the commits on `main` after the marker SHA. None: stop, no PR.
3. Per commit, check if it makes a line in `AGENTS.md` wrong (a renamed folder, a changed command, a removed tool) or adds something worth one line (a new folder, command or standard).
4. Change only those lines. Keep all other text exactly as is, including handwritten parts.
5. Set the marker to the latest `main` SHA.

No real change (only the marker would move): stop, no PR.

## PR

One PR with only `AGENTS.md`. Body: a table of commit (short SHA plus title, linked) and the change it caused in `AGENTS.md`. Never merge.
