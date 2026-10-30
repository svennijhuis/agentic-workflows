---
steps: 2
---
# Fixture: step 2 has a verify line only inside an HTML comment (exits 1)

1. First step.
   verify: run the first check.
2. Second step.
   <!--
   verify: this is a comment, not a verify line
   -->
