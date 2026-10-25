# docs/pbi/smoke/
Post-deploy API smoke on tst and acc. Order: SM07 (Sven, parallel) -> SM01 -> SM05 -> SM04 -> SM03 -> SM06 -> SM02 (agentic, last).
Nothing enabled until Sven yes; Actions billing blocked today.
```mermaid
flowchart LR
  PR[Feature PR] -->|SM02 writes| SC[smoke/feature/scenarios.yml]
  SC -->|SM01 check| V[verify]
  PR --> M[merge] --> REL[release Action tst/acc]
  REL -->|deployment_status, SM05 allows| RUN[SM03 runner]
  RUN -->|SM04 OIDC JWT| API[API tst/acc]
  RUN --> REP[SM06 report + issue]
```
