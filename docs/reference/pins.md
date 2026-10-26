# Tool and engine pins (C06)

Reproducible compiles require pinned gh-aw and Copilot engine versions ([POL01](../../policies/POL01.yml)).

## `.github/aw.json`

Catalog pin file (Block 1):

- gh-aw compiler **v0.93.5**
- Copilot engine **1.0.101**

Fields follow gh-aw compiler config: action pins, `compiler_version`, and `engine_versions.copilot` (plus checksum when set). `scripts/verify.sh` runs `gh aw compile --dir workflows --strict --actionlint` against these pins.

## Lock file metadata

Each `workflows/*.lock.yml` records resolved import SHAs and shows:

- `compiler_version`
- `engine_versions.copilot`

After frontmatter or pin bumps, recompile and commit fresh locks ([POL17](../../policies/POL17.yml)).

## Bump procedure

1. Read [L04 gh-aw tool pin](../pbi/release/L04-gh-aw-tool-pin.md).
2. Update `.github/aw.json` and any shared engine pin in `workflows/shared/defaults.md` if needed.
3. Recompile all workflows strict; commit lock files.
4. Run `./scripts/verify.sh`.
5. Add an [CHANGELOG.md](../../CHANGELOG.md) entry under the release section.

## See also

- PBI [C06](../pbi/done/C06-copilot-engine-version-pins.md)
- [gh-aw releases](https://github.github.com/gh-aw/reference/releases/)
