---
steps: 8
---
# Smoke setup: the steps only Sven does

This checklist is for Sven. Bots never sign in to Azure, never edit Entra and never change GitHub settings. Every step has a `verify:` line Sven can run. `scripts/check-smoke-setup.sh` checks this file in `./scripts/verify.sh` (SM07a). Sven runs steps 1 to 7 and says yes in the room (SM07b). Nothing here is switched on before that yes.

Auth is SM04 option b: app-only through GitHub OIDC. No client secret, no certificate, no test user password. `<api repo>` is a placeholder until Sven names the API repo (`svennijhuis/<api repo>`). Values (client ids, tenant id, URLs) live only in GitHub environment variables, never in a file or in chat.

## Steps

1. **Actions billing unblocked** (blocks everything).
   - verify: GitHub > Settings > Billing and plans shows no Actions spending block, and a manual `workflow_dispatch` run in the API repo starts instead of failing on billing.
2. **One smoke app registration per env**: `Platform smoke (tst)` and `Platform smoke (acc)`. No client secret, no certificate, public client flows off.
   - verify: Entra admin center > App registrations > each smoke app: Certificates and secrets shows 0 secrets and 0 certificates; Authentication shows "Allow public client flows" set to No.
3. **One federated credential per app**: issuer `https://token.actions.githubusercontent.com`, audience `api://AzureADTokenExchange`, subject `repo:svennijhuis/<api repo>:environment:smoke-tst` (and `smoke-acc` on the acc app). No prd, prod, branch or pull-request subject.
   - verify: Entra admin center > each smoke app > Certificates and secrets > Federated credentials lists exactly one credential, with that issuer, audience and the `environment:smoke-<env>` subject.
4. **Role assignment through the infra repo**: an `app-smoke.<env>.clientconfig.json` with the smoke app service principal `objectId`, `apiAccess` read role only, and `tenant` set to the test company slug so reconcile adds `party.<slug>` (never `party.*`). Sven runs `platform entra reconcile` himself.
   - verify: Entra admin center > Enterprise applications > each smoke app > Permissions shows only the read role and the `party.<slug>` role; the clientconfig file is merged on the infra repo main branch.
5. **API audience check**: decode one smoke token and confirm `aud` matches the APIM `<api>-audience` named value (v2 tokens carry the client id). If it does not match, Sven fixes the APIM audience in the infra repo first.
   - verify: Azure portal > API Management > Named values > `<api>-audience` equals the `aud` claim of the decoded smoke token.
6. **GitHub environments `smoke-tst` and `smoke-acc`** in the API repo with vars `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `SMOKE_API_SCOPE`, `SMOKE_BASE_URL`, `SMOKE_PARTY`, `SMOKE_READ_ROLE` (values only in GitHub). Separate from `nonprod`, never reuse it. Deployment branch rule: main only. Required reviewers off for `smoke-tst`, on for `smoke-acc`.
   - verify: these two commands each list the six vars and no secrets:

     ```bash
     gh variable list --env smoke-tst --repo svennijhuis/<api repo>
     gh variable list --env smoke-acc --repo svennijhuis/<api repo>
     ```

7. **Optional: Conditional Access for workload identities** on the smoke apps (location block outside the GitHub runner ranges). Needs Workload ID Premium.
   - verify: Entra admin center > Conditional Access > Policies shows the workload identity policy scoped to the two smoke apps, or Sven notes "step 7 skipped" in the room.
8. **Not set up, on purpose**: no test user, no ROPC, no TOTP seed, no Conditional Access exclusions.
   - verify: Entra admin center > Users has no smoke test user; `gh secret list --env smoke-tst --repo svennijhuis/<api repo>` shows no password or TOTP secret; Conditional Access policies list no smoke exclusion.

## Rollback

Sven deletes the federated credentials and the smoke apps, removes the clientconfig and reconciles.
