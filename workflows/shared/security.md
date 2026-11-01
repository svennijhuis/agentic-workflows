---
description: Safety baseline. Closed network, threat detection on. Importers add named hosts only.
network:
  allowed: [defaults]
safe-outputs:
  threat-detection: true
---

Network stays closed except the gh-aw defaults. Add named hosts on the importing workflow; no wildcards. Threat detection stays on. No secrets in this file (names only in workflow cards and docs).
