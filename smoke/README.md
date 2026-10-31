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
| `id` | required, not empty, unique in the file and across all files in one `check-smoke.sh` call; non-empty `!!str` with no whitespace |
| `env` | exactly `tst` or `acc` (allowlist). Empty, `prd`, `prod`, `production` or any other value exits 1 |
| `method` | required. Only exactly `GET` and `HEAD` are reads; every other value is a write (`PURGE` and `post` included) |
| `path` | relative: starts with exactly one `/`, no scheme, no host. `//host/a` exits 1 (a URL join reads it as a new host). The host comes only from `SMOKE_BASE_URL` (SM03). No `#` fragment (raw or after one percent-decode on the whole path); a path that still holds `%` after that one decode exits 1. Query and matrix keys (after `?`, `&` or `;`) allowlist: `limit` only; each key is percent-decoded exactly once before the allowlist, and a key that still holds `%` after that decode exits 1 |
| `auth` | required, exactly `none` or `smoke-jwt`; a missing key exits 1 |
| `test_data_only` | must be `true` (a YAML boolean) on every write |
| `headers` | optional map. Names allowlist, any case: `Accept`, `Content-Type`, `If-None-Match`, `X-Request-Id`. Any other name exits 1 (`Authorization`, `Proxy-Authorization`, `Cookie`, `Set-Cookie`, `X-Key`); auth goes only through `auth:` |
| `expect.status` | required plain decimal HTTP status, 100 to 599 (no `0x`, `0o`, `0b`, `+n` or `n_m` forms) |
| `expect.json` | optional list of `{path: $..., equals: value}` or `{path: $..., exists: true}` (`exists` must be boolean `true`, not a string) |

No secrets in scenario files. Each of these exits 1, on any scalar anywhere in the file (keys, ids, path,
query and headers included):
- three dot-separated segments of 10 or more `[A-Za-z0-9_-]` chars (JWT shape)
- a value starting with `Bearer `, `Basic ` or `Token ` (any case), or those scheme words followed by a space and a token-like run anywhere in the scalar
- a secret prefix at a word start: `gh[pousr]_`, `github_pat_`, `glpat-`, `sk_live_`, `sk_test_`, `rk_live_`, `rk_test_`, `xox[abpr]-`, `xoxe-`, `AKIA` plus 16 `[0-9A-Z]`, or `sk-` plus 20 or more `[A-Za-z0-9]`
- a query key in `path` after `?`, `&` or `;` that is not `limit` (any case, after one percent-decode on the key)

A duplicate key in any map exits 1 (yq keeps the last one, so `env: prd` then `env: tst` would read as tst).
`check-smoke.sh --help` prints usage and exits 0.

## Check

```
bash scripts/check-smoke.sh smoke/<feature>/scenarios.yml
```

One `file:line SMOKE message` line per hit. Exit 0 ok, 1 a hit or a file that does not parse (fail closed),
2 `yq` missing. `scripts/verify.sh` runs it on `test/fixtures/smoke/`: `good*.yml` exit 0, every `bad-*.yml` and `bad-*.yaml` exits exactly 1; `bad-dup-id-cross/a.yml` and `b.yml` together exit 1.
