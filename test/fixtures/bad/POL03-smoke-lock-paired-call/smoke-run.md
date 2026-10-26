---
on:
  workflow_dispatch:
permissions:
  contents: read
safe-outputs:
  staged: true
  noop:
---
# Bad POL03 case: the .md is dispatch only, but its paired lock was edited to add workflow_call.
