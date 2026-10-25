# ZZ01: Template fixture (good)
- Status: todo
- Area: testing
- Block: 2
- proof: bash scripts/check-pbi-template.sh test/fixtures/template/good.md (exit 0)
- door: two-way
- triage: build (scope clear, no spec needed)
- feedback: bash scripts/check-pbi-template.sh test/fixtures/template/good.md
- harness: none (script)
- review-input: diff + this PBI + DoD, never builder session logs
- kind: script
- Source: PA8 https://github.com/svennijhuis/agentPacks/pull/80
## Goal
Fixture only.
## Technical design
- Components and files: test/fixtures/template/good.md
- Module boundary: one script call in, file:line lines out
