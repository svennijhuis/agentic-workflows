---
steps: 2
---
# Fixture: HTML comments next to real steps (exits 0)

<!-- intro note, not a step -->
1. First step. <!-- inline note -->
   verify: run the first check.
<!--
3. Not a step.
-->
2. Second step.
   - verify: run the second check:

     ```html
     <!-- inside a fence, this does not open a comment
     ```
