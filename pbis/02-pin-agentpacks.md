# 02 Pin agentPacks

Goal: no branch refs. Import only what changes the review.

DoD:
- [x] All agentPacks refs `@34e1dec3535baa1d77cb441ea8c98498dc9b3684` (main; no agentPacks tags yet)
- [x] Keep: squad skill, squad plugin, `/squad-review` command, review standards
- [x] Drop: `git`, `dotnet`, `typescript`, `rust` plugins
- [x] Tag scheme `vX.Y.Z` + moving `v1` in CHANGELOG and CONSUMING

Status: done. Post-merge: tag `v1.0.0` + `v1`. Bump to an agentPacks tag once one exists.
