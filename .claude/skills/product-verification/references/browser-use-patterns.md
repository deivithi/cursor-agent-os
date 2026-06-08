# 🌐 Browser-Use CLI Patterns

> Referência rápida de patterns do browser-use CLI para verificação de produtos.
> **Preferir browser-use sobre agent-browser** para a maioria dos cenários de verificação.

## Por Que Preferir browser-use

| Vantagem | Impacto |
|----------|---------|
| Daemon persistente | ~50ms/comando vs startup a cada sessão |
| Named sessions | Verificações paralelas (Aria + landing simultâneo) |
| JSON output nativo | `--json` para assertions programáticas |
| JS eval direto | `eval` para validações in-page |
| Cookie import/export | Reutilizar sessões auth |

## Comandos Essenciais

```bash
# Navegação
browser-use open "<url>"                    # Abrir URL
browser-use open "<url>" --sessionverificacao     # Sessão nomeada
browser-use back                            # Voltar

# Observação
browser-use state                           # Elementos clicáveis com índices
browser-use --json state                    # JSON (para parsing/assertions)
browser-use screenshot ./path/file.png      # Screenshot
browser-use get text                        # Texto da página inteira
browser-use get title                       # Título
browser-use get url                         # URL atual

# Interação (sempre por índice numérico do state)
browser-use click 5                         # Clicar por índice
browser-use input 3 "texto"                 # Digitar em elemento específico
browser-use type "texto"                    # Digitar no foco atual
browser-use select 5 "opcao"               # Dropdown
browser-use keys "Enter"                    # Tecla

# Espera
browser-use wait --visible 5               # Esperar elemento visível
browser-use wait --hidden 5                # Esperar elemento sumir

# JavaScript (validação in-page)
browser-use eval "document.title"
browser-use eval "document.querySelectorAll('.error').length"
browser-use eval "window.location.href"

# Sessão
browser-use sessions                        # Listar ativas
browser-use close                           # Fechar sessão
browser-use --sessionnome close                   # Fechar sessão específica
```

## Regras de Ouro

1. **SEMPRE `state` antes de interagir** — Índices só existem após state
2. **SEMPRE re-state após ação** — DOM mudou, índices podem mudar
3. **Use `--json` para assertions** — Parsing limpo, sem ambiguidade
4. **Use `-s nome` para multi-step** — Sessão mantém estado
5. **Use `eval` para validar** — JS direto na página, sem parsing de text
6. **Fechar ao terminar** — `browser-use close`

## Pattern: Smoke Test Rápido

```bash
browser-use open "https://app.example.com" --sessionsmoke
browser-use --json state
# Verificar título e elementos críticos
browser-use eval "document.title"
browser-use eval "document.querySelectorAll('form').length > 0"
browser-use screenshot ./evidencias/smoke-$(date +%Y%m%d-%H%M).png
browser-use --sessionsmoke close
```

## Pattern: Fluxo de Login

```bash
browser-use open "https://app.example.com/login" --sessionlogin-test
browser-use state                           # Capturar form
browser-use input 3 "user@test.com"         # Email (índice do state)
browser-use input 5 "password123"           # Senha
browser-use click 7                         # Botão login
browser-use wait --visible 10               # Esperar dashboard carregar
browser-use --json state                    # Verificar estado pós-login
browser-use screenshot ./evidencias/login-ok.png
browser-use --sessionlogin-test close
```

## Pattern: Verificar Elemento com JSON

```bash
# State como JSON e verificar programaticamente
STATE=$(browser-use --json state 2>/dev/null)
if echo "$STATE" | python -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if 'Dashboard' in d['data']['_raw_text'] else 1)"; then
    echo "✅ Dashboard carregado"
else
    echo "❌ Dashboard não encontrado"
fi
```

## Pattern: Sessões Paralelas

```bash
# Verificar múltiplos produtos simultaneamente
browser-use open "https://aria.app" --sessionaria &
browser-use open "https://landing.febracis.com" --sessionlanding &
wait

# Verificar cada um
browser-use --sessionaria state
browser-use --sessionaria screenshot ./evidencias/aria.png

browser-use --sessionlanding state
browser-use --sessionlanding screenshot ./evidencias/landing.png

# Fechar ambos
browser-use --sessionaria close
browser-use --sessionlanding close
```

## Pattern: Validação JS In-Page

```bash
# Verificar que não há erros de console
browser-use eval "window.__consoleErrors?.length || 0"

# Verificar que form tem campos obrigatórios
browser-use eval "document.querySelectorAll('[required]').length"

# Verificar que API respondeu
browser-use eval "fetch('/api/health').then(r => r.json()).then(d => JSON.stringify(d))"
```

## Gotchas Específicos

- **Daemon startup:** Primeiro comando pode demorar ~2s (inicia daemon). Subsequentes ~50ms
- **Índices mudam:** Após qualquer ação que muda DOM, re-executar `state`
- **Python 3.14 incompatível:** Usar venv dedicado Python 3.12 em `C:/Users/PC/.browser-use-env/`
- **--json antes do subcomando:** `browser-use --json state` (não `browser-use state --json`)
- **Windows TCP:** Daemon usa TCP em vez de Unix sockets — funciona igual
- **SPA delay:** Esperar 1-2s ou usar `wait` após navegação em React/Next apps
