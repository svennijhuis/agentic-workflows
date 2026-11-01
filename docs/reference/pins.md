# Tool and engine pins (C06)

Reproducible compiles require pinned gh-aw and Copilot engine versions in [`.github/aw.json`](../../.github/aw.json).

## `.github/aw.json`

- **`gh-aw`**: compiler pin **v0.93.4** (read by `Makefile` and `.github/workflows/verify.yml`).
- **`engines.copilot`**: Copilot engine **1.0.101** (must match `workflows/shared/defaults.md` when you bump).
- **`tools`**: **yq** and **gitleaks** only, each with `version`, `url` and `sha256`. The verify job downloads them for POL25/POL31 checks and the secret scan. git, gh, jq and make are runner-provided.

`make compile` checks the installed gh-aw extension against the top-level pin. `make verify` does not re-pin auxiliary tools locally; CI installs yq and gitleaks from the same file.

## Lock file metadata

Each `workflows/*.lock.yml` records resolved import SHAs and shows `compiler_version` and `engine_versions.copilot`.

After frontmatter or pin bumps, run `make compile` and commit fresh locks.

## Bump procedure

1. Update `.github/aw.json` (for a `tools:` bump: version, url and sha256 together, and matching `curl` lines in `.github/workflows/verify.yml`).
2. Update `workflows/shared/defaults.md` engine version if the Copilot pin changed.
3. `make compile`; commit all `.lock.yml` files.
4. `make verify`.
5. Add a [CHANGELOG.md](../../CHANGELOG.md) entry under the release section.

## See also

- PBI [C06](../pbi/done/C06-copilot-engine-version-pins.md)
- [gh-aw releases](https://github.github.com/gh-aw/reference/releases/)
