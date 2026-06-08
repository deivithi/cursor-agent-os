---
description: "App Store Connect CLI — builds, TestFlight, submissions, metadata, ASO, signing"
---

# App Store Connect CLI Router

O usuário solicitou: **$ARGUMENTS**

## Instrução

1. Leia a skill `.claude/skills/app-store-connect/SKILL.md`
2. Verifique se `asc` está instalado: `asc version`
3. Se não instalado, siga o setup da skill
4. Identifique o workflow adequado ao pedido do usuário
5. Execute usando `--output json` para parsing estruturado
6. Para operações destrutivas, usar `--dry-run` primeiro e pedir confirmação

## Roteamento Rápido

| Intenção | Comando |
|----------|---------|
| listar apps | `asc apps list` |
| info de um app | `asc apps info view --app "APP_ID"` |
| status do review | `asc review status` + `asc review doctor` |
| builds | `asc builds list --app "APP_ID"` |
| upload build | `asc builds upload --file ./path.ipa --app "APP_ID"` |
| testflight | `asc publish testflight --app "APP_ID"` |
| grupos de testers | `asc testflight groups list --app "APP_ID"` |
| feedback testers | `asc testflight feedback list --app "APP_ID"` |
| crashes | `asc testflight crashes list --app "APP_ID"` |
| metadata, sync | `asc metadata pull` / `asc metadata apply` |
| aso, keywords | `asc metadata keywords audit --app "APP_ID"` |
| submeter, publicar | `asc publish appstore` (com --dry-run primeiro) |
| release pipeline | `asc release run --dry-run` → `asc release run --confirm` |
| certificados | `asc certificates list` |
| profiles | `asc profiles list` |
| signing | `asc bundle-ids list` + `asc profiles list` |
| xcode cloud | `asc xcode-cloud run --workflow "ID"` |
| monitorar | `asc status --watch` |
| auth status | `asc auth status --validate` |
| diagnóstico | `asc auth doctor` / `asc review doctor` |

## Regras

- **SEMPRE** `--dry-run` antes de publish/release/submit
- **SEMPRE** `--confirm` para operações destrutivas
- **SEMPRE** `--output json` para parsing programático
- **Windows:** `ASC_BYPASS_KEYCHAIN=1` obrigatório
- Se auth não configurada, direcionar para `references/auth-setup.md`
- Consultar `gotchas.md` se algo falhar

## Workflows Completos

Para operações multi-step (release completo, TestFlight distribution, ASO audit), consultar `references/workflows.md`.
