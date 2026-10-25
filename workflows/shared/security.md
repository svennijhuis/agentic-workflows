---
description: Safety baseline. Closed network, threat detection on. Importers add named hosts only.
network:
  allowed: [defaults]
safe-outputs:
  threat-detection: true
---

Network stays closed except the gh-aw defaults. Add named hosts on the importing workflow; no wildcards (POL06). Threat detection stays on (POL13). No secrets in this file (POL04).
