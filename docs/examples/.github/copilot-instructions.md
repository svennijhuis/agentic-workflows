# Copilot instructions

Template. Copy to `.github/copilot-instructions.md` in a target repo and replace every line with the repo's own rules. The builder and reviewer read this file next to `AGENTS.md`; a rule here wins over their defaults. Keep only rules a reviewer can check on a diff.

## Build and test

- Install: `npm ci`
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint`

## Code

- Validate outside input once, at the boundary (HTTP handler, CLI args, config load). Trust internal types after that.
- No new dependency without a reason in the PR body.
- Errors: throw typed errors from the domain, map them to responses in one place.
- Comments only for a non-obvious why. No comments that repeat the code.

## Tests

- Test behaviour a caller can see, not internals.
- A bug fix lands with a regression test that fails before the fix.

## Do not touch

- `migrations/` already applied: add a new migration instead.
- Generated files: `*.lock.yml`, `dist/`.
