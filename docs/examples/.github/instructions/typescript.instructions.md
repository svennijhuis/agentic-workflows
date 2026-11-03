---
applyTo: "**/*.ts,**/*.tsx"
---

# TypeScript

Template. Copy to `.github/instructions/typescript.instructions.md` in a target repo and adjust. The builder and reviewer apply it to changed files that match `applyTo`.

- `strict` stays on. No `any`; use `unknown` and narrow it.
- No non-null `!` and no `as` casts to silence the compiler. Fix the type instead.
- Parse outside data (JSON, env, request bodies) with one schema at the boundary, then pass the parsed type on.
- Model states as a discriminated union, not as several optional fields or booleans.
- Exhaustive `switch` on unions: end with a `never` check.
- Named exports only. One module, one reason to change.
- `async` functions return a `Promise` that is awaited or returned; no floating promises.
