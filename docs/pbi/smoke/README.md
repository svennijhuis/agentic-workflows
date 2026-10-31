# docs/pbi/smoke/
Post-deploy API smoke on tst and acc. Order: SM01 (done), SM01a (done), SM01b (done), SM01c (done), SM01d (todo), SM05, SM04, SM03, SM06, SM02 (agentic, last), SM07 (Sven's manual step, switched off), SM08 (docs, closes after build PBIs).
Follow-up: [SM01a](../done/SM01a.md), [SM01b](../done/SM01b.md) and [SM01c](../done/SM01c.md) (check-smoke hardening, done; SM01 merged in PR #11). Next carry: [SM01d](SM01d.md) (todo).
Nothing enabled until Sven yes; Actions billing blocked today.
Gate (split check 2026-10-26): the rows of [SM08](SM08-cursor-findings.md) (the 8 open Cursor findings on PR #5) live in the build PBIs SM01, SM04a, SM05a, SM05b, SM05c and SM07a. SM08 closes once those have merged.
Where things live: the API repo `svennijhuis/<api repo>` (the app repo that copies the infra release template, placeholder, named in SM07) holds the live runner workflow, the GitHub environments `smoke-tst` and `smoke-acc`, the federated subject and the `smoke/<feature>/` scenarios. This catalog holds the authoring copies (`smoke/`, `workflows/smoke-writer.md`), the checks and the fixtures.
```mermaid
flowchart LR
  PR[Feature PR] -->|SM02 writes| SC[smoke/feature/scenarios.yml]
  SC -->|SM01 check| V[verify]
  PR --> M[merge] --> REL[release Action tst/acc]
  REL -->|workflow_call last job, SM05 allows| RUN[SM03 runner]
  RUN -->|SM04 OIDC app token| APIM[APIM validate-jwt, party, roles] --> API[API tst/acc]
  RUN --> REP[SM06 report + issue]
```

Parts: [SM07a](../done/SM07a-setup-check.md) (`smoke/SETUP.md` and `scripts/check-smoke-setup.sh`) is done; SM07b (Sven runs the setup steps and says yes) is todo, no PR.
