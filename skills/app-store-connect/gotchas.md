# Gotchas — App Store Connect CLI

## Windows-Specific

### G-01: Sem macOS Keychain
**Problema:** `asc auth login` tenta usar Keychain, que não existe no Windows.
**Fix:** Sempre usar `ASC_BYPASS_KEYCHAIN=1` e configurar auth via env vars.
```bash
export ASC_BYPASS_KEYCHAIN=1
export ASC_KEY_ID="KEY_ID"
export ASC_ISSUER_ID="ISSUER_ID"
export ASC_PRIVATE_KEY_PATH="/path/to/AuthKey.p8"
```

### G-02: Build de IPA impossível
**Problema:** `asc builds upload` requer IPA/PKG local. Xcode só roda no macOS.
**Workaround:** Usar Xcode Cloud para build remoto, ou CI no macOS (GitHub Actions com macOS runner). No Windows, só gerenciamento remoto (metadata, review, TestFlight).

### G-03: Screenshots via simulador indisponíveis
**Problema:** Skills como `asc-shots-pipeline` requerem simulador iOS.
**Workaround:** Capturar screenshots manualmente ou via CI macOS, depois fazer upload com `asc screenshots apply`.

## Auth & Credentials

### G-04: API Key role insuficiente
**Problema:** Operações de escrita falham com 403.
**Fix:** API Key precisa de role **Admin** ou **App Manager** no App Store Connect.

### G-05: Token JWT expirado
**Problema:** Requests falham após ~20 minutos de sessão longa.
**Fix:** O `asc` renova automaticamente. Se persistir, verificar clock do sistema (JWT valida timestamps).

### G-06: Multi-source credentials
**Problema:** Credentials em keychain E env vars podem conflitar.
**Fix:** Usar `ASC_STRICT_AUTH=1` para falhar se múltiplas fontes detectadas.

## API Quirks

### G-07: Rate limiting
**Problema:** API retorna 429 em uso intensivo.
**Limites:** 30 req/min (analytics), 600 req/min (outros).
**Fix:** Usar `--paginate` com cuidado em endpoints analytics. Espaçar requests em scripts batch.

### G-08: Metadata sync sobrescreve edits manuais
**Problema:** `asc metadata apply` sobrescreve qualquer edit feito diretamente no App Store Connect.
**Fix:** Sempre fazer `asc metadata pull` antes de editar localmente. Tratar o diretório local como source of truth.

### G-09: Data lag em crashes
**Problema:** Crashes recentes não aparecem imediatamente.
**Realidade:** App Store Connect processa crashes com 24-48h de delay.
**Fix:** Não assumir ausência de crashes = app estável. Verificar novamente após 48h.

### G-10: First-time submission blockers
**Problema:** Primeira submissão de um app tem requisitos extras que a API não resolve sozinha.
**Blockers comuns:**
- App Availability precisa ser configurada via web session
- Subscriptions requerem attachment manual na primeira review
- In-App Purchases precisam de seleção manual na UI
**Fix:** Ver `references/workflows.md` seção "First-Time Submission Blockers".

### G-11: --confirm obrigatório para operações destrutivas
**Problema:** Comandos como `publish`, `release run`, `builds remove-groups` falham silenciosamente sem `--confirm`.
**Fix:** Sempre incluir `--confirm` em comandos de escrita. Usar `--dry-run` antes.
