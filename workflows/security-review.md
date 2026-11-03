---
description: AI-assisted security review (gallery example, adapted from Daily Malicious Code Scan). Reports code scanning alerts only. Manual only.
on:
  workflow_dispatch:
permissions:
  contents: read
  pull-requests: read
  security-events: read
safe-outputs:
  create-code-scanning-alert:
    max: 20
---

# Security Review

Source: [gallery Security Review](https://github.github.com/gh-aw/gallery/security-review/).

Review code changes from the last three days for secret exfiltration, unexpected network access, suspicious system commands, obfuscation, hidden backdoors, or privilege escalation.

Use repository and pull request context to tell intentional behavior from anomalies. Create a code scanning alert only with concrete file and line evidence. Include category, severity, evidence, likely impact, confidence and recommended fix. No speculative or style-only reports.

Findings are leads for the maintainer, not proof.
