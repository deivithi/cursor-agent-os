---
name: app-store-connect
description: >
  CLI completa para App Store Connect API. Builds, TestFlight, submissions, signing,
  metadata, ASO, screenshots, Xcode Cloud. JSON-first, zero interativo. Keywords:
  app store, testflight, build, submit, publish, ios, macos, visionos, ipa, signing,
  certificate, provisioning, metadata, aso, screenshots, xcode cloud, review status,
  app store connect, asc, apple, release, beta, tester, crash, keyword, localization.
domain: mobile
subdomain: app-publishing
version: 1.0.0
allowed-tools: Bash, Read, Write, Glob, Grep, Agent
metadata:
  author: deivithi
  source: https://github.com/rudrankriyam/App-Store-Connect-CLI
  upstream-version: "1.2.2"
  license: MIT
  stars: "3900+"
---

# App Store Connect CLI — Pipeline Completo de Publicação

> **Source:** [rudrankriyam/App-Store-Connect-CLI](https://github.com/rudrankriyam/App-Store-Connect-CLI) (3.9K stars, MIT)
> **Version:** 1.2.2
> **Binary:** `~/.local/bin/asc.exe`

CLI Go que dá acesso completo à API do App Store Connect — builds, TestFlight, submissions, signing, metadata, ASO, screenshots, Xcode Cloud. JSON-first, zero prompts interativos, automação total.

## File Structure

- `SKILL.md` — Você está aqui. Workflow completo.
- `gotchas.md` — Problemas conhecidos (Windows, auth, API quirks).
- `references/auth-setup.md` — Guia de autenticação detalhado.
- `references/workflows.md` — Workflows multi-step (release, TestFlight, ASO, crash triage).
- `references/env-vars.md` — Variáveis de ambiente completas.

## Related Skills

- `cicd` — Pipeline de deploy. `asc` alimenta a etapa de publicação
- `ads` — Promoção pós-publish (App Store Ads via claude-ads)
- `product-verification` — Smoke test pós-deploy via browser
- `vibe-deploy-guard` — Security checks pré-submit
- `strix` — Pentesting dinâmico da app antes de publicar

## Quando Usar

| Cenário | Ação |
|---------|------|
| Listar apps, builds, status | `asc apps list`, `asc builds list` |
| Distribuir build para TestFlight | `asc publish testflight` |
| Submeter para App Store | `asc publish appstore` (com --dry-run primeiro) |
| Auditar keywords/ASO | `asc metadata keywords audit` |
| Monitorar review status | `asc review status` + `asc review doctor` |
| Gerenciar certificados/profiles | `asc certificates list`, `asc profiles list` |
| Analisar crashes TestFlight | `asc testflight crashes list` |
| Sincronizar metadata | `asc metadata pull` / `asc metadata apply` |
| Automatizar release completo | `asc release run` (ver references/workflows.md) |

## Quando NÃO Usar (Handoff)

- Build de IPA/PKG → requer Xcode no macOS (não disponível no Windows)
- Screenshots via simulador → requer simulador iOS no macOS
- Análise de código → `vibe-deploy-guard`, `strix`, `security-audit`
- Métricas de ads → `ads-live`, `ads-apple`
- Automação web no App Store Connect → `chrome-cdp` ou `browser-use`

---

## Setup

### Verificação

```bash
# Binário instalado
asc version
# Esperado: 1.2.2 (commit: e35ef65, date: 2026-04-14T09:21:43Z)

# Auth configurada
asc auth status --validate
```

### Instalação (se necessário)

```bash
# Windows (binário direto)
curl -fsSL -o ~/.local/bin/asc.exe \
  "https://github.com/rudrankriyam/App-Store-Connect-CLI/releases/download/1.2.2/asc_1.2.2_windows_amd64.exe"

# macOS (Homebrew)
brew install asc
```

### Autenticação

Ver `references/auth-setup.md` para guia completo. Resumo:

```bash
# Login com API Key
asc auth login --key-id KEY_ID --issuer-id ISSUER_ID --private-key-path /path/to.p8

# Windows: usar env vars (sem Keychain)
export ASC_BYPASS_KEYCHAIN=1
export ASC_KEY_ID="YOUR_KEY_ID"
export ASC_ISSUER_ID="YOUR_ISSUER_ID"
export ASC_PRIVATE_KEY_PATH="/path/to/AuthKey.p8"

# Validar
asc auth status --validate
asc auth doctor
```

---

## Core Commands

### Discovery

```bash
# Listar apps
asc apps list --output json

# Info detalhada de um app
asc apps info view --app "APP_ID" --output json

# Buscar app por nome (filtro local)
asc apps list --output json | jq '.[] | select(.name | contains("MeuApp"))'
```

### Build & Upload

```bash
# Listar builds
asc builds list --app "APP_ID" --output json

# Próximo build number
asc builds next-build-number --app "APP_ID" --platform IOS

# Upload IPA (requer IPA local — build no macOS)
asc builds upload --file ./build/MeuApp.ipa --app "APP_ID"
```

### TestFlight

```bash
# Listar grupos de testers
asc testflight groups list --app "APP_ID" --output json

# Feedback dos testers
asc testflight feedback list --app "APP_ID" --output json

# Crashes recentes
asc testflight crashes list --app "APP_ID" --output json

# Log de crash específico
asc testflight crashes log --crash-id "CRASH_ID"

# Distribuir build para TestFlight
asc publish testflight --app "APP_ID" --build "BUILD_ID" --groups "Beta Testers"

# Exportar config TestFlight
asc testflight config export --app "APP_ID" --output "./testflight.yaml"
```

### Publish & Release

```bash
# Dry-run primeiro (SEMPRE)
asc release run --app "APP_ID" --version "1.2.3" --dry-run --output table

# Staging (prepara sem submeter)
asc release stage --app "APP_ID" --version "1.2.3" --build "BUILD_ID" \
  --metadata-dir "./metadata/version/1.2.3" --confirm

# Preflight check
asc submit preflight --app "APP_ID" --version "1.2.3" --platform IOS

# Validação profunda
asc validate --app "APP_ID" --version "1.2.3" --platform IOS --output table

# Submit real
asc publish appstore --app "APP_ID" --version "1.2.3" --confirm

# Monitorar review
asc submit status --app "APP_ID" --output json
asc status --watch  # Real-time monitoring
```

### Metadata & ASO

```bash
# Pull metadata local
asc metadata pull --app "APP_ID" --output-dir ./metadata

# Sync metadata para App Store Connect
asc metadata apply --app "APP_ID" --metadata-dir ./metadata --confirm

# Audit de keywords (ASO)
asc metadata keywords audit --app "APP_ID" --output table

# Listar localizações
asc localizations list --app "APP_ID" --output json
```

### Signing & Certificates

```bash
# Certificados
asc certificates list --output json

# Provisioning profiles
asc profiles list --output json

# Bundle IDs
asc bundle-ids list --output json
```

### Review & Status

```bash
# Status do review
asc review status --app "APP_ID" --output json

# Diagnóstico de blockers
asc review doctor --app "APP_ID" --output table

# Monitoramento real-time
asc status --watch
```

### Xcode Cloud

```bash
# Trigger workflow
asc xcode-cloud run --workflow "WORKFLOW_ID"

# Status do build
asc xcode-cloud build-runs get --build-run-id "RUN_ID" --output json
```

### Workflow Automation

```bash
# Validar workflow config
asc workflow validate --config .asc/workflow.json

# Executar workflow definido
asc workflow run --config .asc/workflow.json --confirm
```

---

## Output & Flags

| Flag | Efeito |
|------|--------|
| `--output json` | JSON (padrão em pipes/CI) |
| `--output table` | Tabela legível (padrão em TTY) |
| `--output markdown` | Markdown |
| `--pretty` | JSON formatado (só com --output json) |
| `--paginate` | Buscar todas as páginas automaticamente |
| `--confirm` | Obrigatório para operações destrutivas |
| `--dry-run` | Preview sem executar |

**Variável:** `ASC_DEFAULT_OUTPUT=json` força JSON sempre.

---

## Constraints

- **Windows:** Sem macOS Keychain → usar `ASC_BYPASS_KEYCHAIN=1` + env vars
- **Windows:** Sem build de IPA (requer Xcode) — só gerenciamento remoto
- **Windows:** Sem simulador iOS — screenshots devem ser uploadadas prontas
- **Dry-run first:** SEMPRE rodar `--dry-run` antes de operações de publish/release
- **Rate limits:** 30 req/min (analytics), 600 req/min (outros endpoints)
- **Data lag:** Dados de crash podem levar 24-48h para aparecer
- **Auth:** API Key precisa de role Admin para operações de escrita

## Complementary Tools

- **23 skills comunitárias:** [app-store-connect-cli-skills](https://github.com/rudrankriyam/app-store-connect-cli-skills) — ASO, localization, RevenueCat sync, notarization
- **Fastlane:** Alternativa Ruby para CI/CD iOS (mais pesado, mais features de build)
- **Xcode:** Build local de IPA/PKG (macOS only)
- **sosumi.ai:** Mirror offline da API Reference da Apple
