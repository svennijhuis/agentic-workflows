owner: @svennijhuis

## PBI

POL25 docs/pbi/done/POL25-agentic-dispatch-only.md

## Architecture summary

One new check, policies/checks/POL25.sh, reads the on: keys of each workflow and its lock. It reuses lib.sh, so the interface is the same file:line output as every POL check.

## Questions for owner

none

## Proof

./scripts/verify.sh ends in 0 failures on the head SHA.

## Door

two-way
