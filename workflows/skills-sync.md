---
description: Check .github/skills-sources.json, add missing skills to .github/skills/ and update changed ones from the source main. One PR, Sven merges.
on:
  workflow_dispatch:
permissions:
  contents: read
  pull-requests: read
network:
  allowed: []
tools:
  github:
    toolsets: [repos]
safe-outputs:
  create-pull-request:
    title-prefix: "[skills-sync] "
    labels: [skills-sync]
    draft: false
    if-no-changes: ignore
    allowed-files:
      - ".github/skills/**"
      - ".github/skills-sources.json"
    max: 1
---

# Skills sync

Repo: `${{ github.repository }}`. Flow: [skills-sync README](README.md#skills-sync).

Source list: `.github/skills-sources.json`. Each entry has `name`, `repo` (`owner/repo`), `path` (folder in that repo) and `sha` (the pinned commit).

For each entry:

1. Read the latest commit on the `main` branch of `repo`.
2. List the commits between `sha` and that latest commit that touch `path`. Ignore all other commits.
3. **Missing:** `.github/skills/<name>/` does not exist here. Copy every file under `path` at the latest commit into `.github/skills/<name>/`, and set `sha` to the latest commit.
4. **Changed:** there are commits from step 2. Replace `.github/skills/<name>/` with the files under `path` at the latest commit, and set `sha` to the latest commit.
5. **Up to date:** no commits from step 2 and the folder exists. Change nothing.

Copy files as is. Do not edit skill content. Do not touch any file outside `.github/skills/` and `.github/skills-sources.json`.

When nothing was added or updated, stop without a PR.

Otherwise open one PR. Body: a table with skill name, status (added or updated), old SHA, new SHA, and the list of commits from step 2 (short SHA plus title, linked). Never merge.
