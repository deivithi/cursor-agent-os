# Workflows — App Store Connect CLI

## 1. TestFlight Distribution

Pipeline completo: build pronto → distribuição para testers.

```
1. Identificar app e build
   asc apps list --output json
   asc builds list --app "APP_ID" --output json

2. Verificar grupos de testers
   asc testflight groups list --app "APP_ID" --output json

3. Exportar config atual (opcional)
   asc testflight config export --app "APP_ID" --output "./testflight.yaml" --include-builds --include-testers

4. Adicionar build ao grupo
   asc builds add-groups --build "BUILD_ID" --groups "GROUP_ID" --confirm

5. Adicionar release notes (What to Test)
   asc testflight localizations create --build "BUILD_ID" --locale "en-US" --whats-new "Test the new checkout flow"

6. Verificar distribuição
   asc testflight groups list --app "APP_ID" --output table
```

### Criar novo grupo de testers

```bash
asc testflight groups create --app "APP_ID" --name "Internal QA" --confirm
asc testflight testers add --group "GROUP_ID" --email "tester@example.com" --confirm
```

### Remover acesso a build

```bash
asc builds remove-groups --build "BUILD_ID" --groups "GROUP_ID" --confirm
```

---

## 2. App Store Submission

Pipeline completo: metadata → validação → submit → monitoramento.

```
1. Pull metadata atual
   asc metadata pull --app "APP_ID" --output-dir ./metadata

2. Editar metadata localmente
   # Editar arquivos em ./metadata/version/X.Y.Z/en-US/
   # - description.txt, keywords.txt, whatsNew.txt, subtitle.txt

3. Apply metadata
   asc metadata apply --app "APP_ID" --metadata-dir ./metadata --confirm

4. Preflight check
   asc submit preflight --app "APP_ID" --version "X.Y.Z" --platform IOS

5. Staging (prepara sem submeter)
   asc release stage --app "APP_ID" --version "X.Y.Z" --build "BUILD_ID" \
     --metadata-dir "./metadata/version/X.Y.Z" --confirm

6. Dry-run do pipeline completo
   asc release run --app "APP_ID" --version "X.Y.Z" --dry-run --output table

7. Validação profunda
   asc validate --app "APP_ID" --version "X.Y.Z" --platform IOS --output table

8. Submit real
   asc publish appstore --app "APP_ID" --version "X.Y.Z" --confirm

9. Monitorar review
   asc submit status --app "APP_ID" --output json
   asc status --watch  # Real-time
   asc review doctor --app "APP_ID"  # Diagnóstico de blockers
```

### Checklist de Readiness

O app está pronto para submit quando:
- Preflight sem issues bloqueantes
- Validation limpo ou warnings entendidos
- Build com status `VALID`
- Metadata, screenshots e localizações completos
- Review details, app availability e privacy policy existem
- IAPs/subscriptions: pricing completo, review artifacts uploadados
- App Privacy resolvido

### First-Time Submission Blockers

| Blocker | Fix |
|---------|-----|
| Missing App Availability | `asc web apps availability create --app "APP_ID" --territory "USA,GBR" --available-in-new-territories true` |
| Subscription sem attachment | `asc web review subscriptions attach-group --app "APP_ID" --group-id "GROUP_ID" --confirm` |
| IAP sem review screenshot | `asc iap review-screenshots create --iap-id "IAP_ID" --file "./review.png"` |
| App Privacy não publicado | `asc web privacy pull` → `plan` → `apply` → `publish` |
| Review details incompletos | `asc review details-create --version-id "VERSION_ID"` com contato e instruções |
| Game Center version | `asc game-center app-versions create --app-store-version-id "VERSION_ID"` |

---

## 3. ASO Audit (App Store Optimization)

Pipeline: auditoria de keywords → otimização de metadata.

```
1. Pull metadata
   asc metadata pull --app "APP_ID" --output-dir ./metadata

2. Audit de keywords
   asc metadata keywords audit --app "APP_ID" --output table

3. Verificações offline
   - Keyword waste: termos no subtitle duplicados em keywords
   - Campos subutilizados: keywords < 90 chars (90% do limite)
   - Campos vazios: subtitle, keywords, description, whatsNew
   - Separadores incorretos: espaços após vírgulas, ponto-e-vírgula
   - Gaps cross-locale: termos idênticos entre locales (localização incompleta)

4. Atualizar keywords
   # Editar ./metadata/version/X.Y.Z/en-US/keywords.txt
   # Formato: term1,term2,term3 (sem espaços, vírgula como separador)

5. Apply metadata atualizado
   asc metadata apply --app "APP_ID" --metadata-dir ./metadata --confirm

6. Verificar localização
   asc localizations list --app "APP_ID" --output table
```

### Boas Práticas ASO

- Keywords: usar todos os 100 caracteres disponíveis
- Não repetir termos que já estão no app name ou subtitle
- Separar keywords apenas com vírgula (sem espaços)
- Localizar keywords para cada mercado (não copiar en-US)
- Subtitle: mínimo 20 caracteres, focado em benefício principal

---

## 4. Crash Triage

Pipeline: identificar crashes → analisar → priorizar.

```
1. Listar crashes recentes
   asc testflight crashes list --app "APP_ID" --output json --paginate

2. Filtrar por build
   asc testflight crashes list --app "APP_ID" --build "BUILD_ID" --output json

3. Log detalhado de crash
   asc testflight crashes log --crash-id "CRASH_ID"

4. Feedback dos testers
   asc testflight feedback list --app "APP_ID" --output json --include-screenshots

5. Diagnósticos de performance
   asc testflight diagnostics --app "APP_ID" --build "BUILD_ID" --type hangs
   asc testflight diagnostics --app "APP_ID" --build "BUILD_ID" --type disk-writes
   asc testflight diagnostics --app "APP_ID" --build "BUILD_ID" --type launch

6. Analisar resultados
   - Agrupar por signature (mesmo crash)
   - Identificar device/OS patterns
   - Priorizar por frequência e impacto
   - Verificar se crash é novo ou recorrente
```

### Notas

- Dados de crash podem ter 24-48h de delay
- Usar `--paginate` para datasets grandes
- Combinar crashes com feedback para contexto completo
- Output JSON para análise programática, table para visual rápido

---

## 5. Signing & Certificates

Pipeline: verificar estado → renovar se necessário.

```
1. Listar certificados
   asc certificates list --output table

2. Listar profiles
   asc profiles list --output table

3. Listar bundle IDs
   asc bundle-ids list --output table

4. Verificar expiração
   asc certificates list --output json | jq '.[] | select(.expirationDate < "2026-06-01")'

5. Sync de signing (se disponível)
   asc signing sync --app "APP_ID"
```
