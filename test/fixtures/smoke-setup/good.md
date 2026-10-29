---
steps: 2
---
# Fixture: good checklist (exits 0)

1. First step.
   verify: run the first check.
2. Second step, with a fenced block.
   - verify: run the second check:

     ```bash
     gh variable list --env smoke-tst --repo example/api
     ```
