---
steps: 2
---
# Fixture: a long fence holds a short fence and a tilde fence (exits 0; a fence counter or toggle would fail it)

1. First step.
   - verify: the block below is one fence; the inner markers do not close it.

     ````markdown
     ```
     2. not a step, inside the fence
     ~~~
     ````

2. Second step.
   - verify: run the second check.
