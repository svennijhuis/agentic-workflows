# smoke/

Post-deploy API smoke scenarios for tst and acc (SM01). The writer (SM02) and the runner (SM03) share this
one format. This folder is the authoring copy; the API repo holds the real `smoke/<feature>/scenarios.yml`
files.

## Layout

```
smoke/
  README.md          this file
  _schema.yml        the field list, annotated
  <feature>/
    scenarios.yml    one file per feature
```

## Format

```yaml
scenarios:
  - id: orders-list
    env: tst
    method: GET
    path: /api/orders?limit=1
    auth: smoke-jwt
    expect:
      status: 200
      json:
        - path: $.items
          exists: true
  - id: order-create
    env: tst
    method: POST
    path: /api/orders
    auth: smoke-jwt
    test_data_only: true
    expect:
      status: 201
      json:
        - path: $.status
          equals: created
```

| Field | Rule |
|---|---|
| `id` | required, not empty |
| `env` | exactly `tst` or `acc` (allowlist). Empty, `prd`, `prod`, `production` or any other value exits 1 |
| `method` | required. Only exactly `GET` and `HEAD` are reads; every other value is a write (`PURGE` and `post` included) |
| `path` | relative: starts with exactly one `/`, no scheme, no host. `//host/a` exits 1 (a URL join reads it as a new host). The host comes only from `SMOKE_BASE_URL` (SM03) |
| `auth` | required, exactly `none` or `smoke-jwt`; a missing key exits 1 |
| `test_data_only` | must be `true` (a YAML boolean) on every write |
| `headers` | optional map |
| `expect.status` | required HTTP status, 100 to 599 |
| `expect.json` | optional list of `{path: $..., equals: value}` or `{path: $..., exists: true}` |

No tokens in scenario files: any scalar anywhere in the file (keys, ids and headers included) with three
dot-separated segments of 10 or more `[A-Za-z0-9_-]` chars, or that starts with `Bearer `, exits 1.

## Check

```
bash scripts/check-smoke.sh smoke/<feature>/scenarios.yml
```

One `file:line SMOKE message` line per hit. Exit 0 ok, 1 a hit or a file that does not parse (fail closed),
2 `yq` missing. `scripts/verify.sh` runs it on `test/fixtures/smoke/`: `good.yml` and `good-dotted.yml`
exit 0, every `bad-*.yml` exits 1.
