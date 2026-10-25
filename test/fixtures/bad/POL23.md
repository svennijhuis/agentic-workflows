# Bad POL23 fixture: a tautological check

This candidate check never fails. POL23 runs it on the bad sample below and must report it.

```sh
#!/usr/bin/env bash
# "checks" that timeout-minutes is set, but always exits 0
grep -q 'timeout-minutes' "$1" || true
exit 0
```

```md
---
description: sample without timeout-minutes
on:
  workflow_dispatch:
---
No timeout.
```
