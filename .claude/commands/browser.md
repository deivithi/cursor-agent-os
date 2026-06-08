# Browser — Automação Web Unificada (Auto-Routing)

Tarefa solicitada: **$ARGUMENTS**

## 🧠 Auto-Routing — Escalation Ladder

> Começar pelo **mais leve** que resolve o problema. Escalar **só quando falha** ou quando o cenário exige.

```
WebSearch/WebFetch → browser-use MCP → chrome-devtools-mcp → agent-browser+CDP → CDP direto
   mais leve            automação         DevTools F12          Chrome logado       manual
   ~500 tokens          ~50ms/cmd         29 tools              perfil auth         máx peso
```

### Nível 1: 🔍 WebSearch + WebFetch (sem browser)
**Quando:** Ler conteúdo público, extrair dados de páginas estáticas, pesquisar
**Escalar se:** Conteúdo vazio, 403, CAPTCHA, SPA sem SSR, precisa interagir

### Nível 2: 🟢 browser-use MCP (PREFERIR para automação)
**Vantagens:** Daemon persistente (~50ms/comando), modo MCP nativo, named sessions paralelas, JS eval direto, cookie import/export, Python scripting
**Quando:**
- Navegação rápida, scraping, extração de dados
- Operações em lote (múltiplas páginas/sessões)
- JavaScript eval direto na página
- Cookie management programático
- Qualquer tarefa que se beneficie de baixa latência
**Escalar se:** Precisa de performance profiling, network inspection, Lighthouse, emulação avançada, ou Chrome real logado

### Nível 3: 🟣 chrome-devtools-mcp (DevTools F12)
**Vantagens:** 29 tools Chrome DevTools completas — performance traces, network requests, Lighthouse, emulação device/rede, heap snapshots, gestão de extensões
**Quando:**
- Performance profiling — Core Web Vitals (LCP, INP, CLS)
- Network inspection — requests/responses com headers, body, timing
- Lighthouse audit — acessibilidade, SEO, best-practices
- Emulação — throttling CPU/rede, geolocation, dark mode, viewport device
- Memory leak investigation — heap snapshots
- Console com source maps — filtragem por tipo
- Gestão de extensões Chrome — install/uninstall/reload
- Drag-and-drop, form fill em lote
**Escalar se:** Precisa de login existente (Salesforce, X) ou upload via perfil autenticado

### Nível 4: 🔵 agent-browser (Vercel Labs) — Fallback robusto
**Vantagens:** Maturo, estável, refs @eN para elementos, sessões auth encriptadas, Chrome debug profile
**Quando:**
- Chrome pessoal logado via CDP porta 9222 (Salesforce, Google, X/Twitter)
- Fluxos que dependem de `@eN` refs do snapshot de acessibilidade
- Upload de arquivos (`agent-browser upload`)
- Quando browser-use não estiver disponível

### Nível 5: 🟡 Chrome CDP Direto — Perfil logado
**Quando:**
- Precisa acessar sites com login existente (X, Google, LinkedIn, Salesforce)
- Conectar via: `--browser real --profile "$LOCALAPPDATA/agent-browser-profile"`
**Nota:** Máximo peso — usar só quando níveis anteriores não resolvem

---

## 📋 Referência Rápida — browser-use CLI

### Navegação
```bash
browser-use open "<url>"                    # Abrir página
browser-use open "<url>" --session sessao1         # Sessão nomeada
browser-use back                            # Voltar
browser-use scroll --y 500                  # Scroll
browser-use close                           # Fechar sessão
```

### Inspeção
```bash
browser-use state                           # Estado (elementos clicáveis com índices)
browser-use --json state                    # Estado como JSON
browser-use screenshot ./output.png         # Screenshot
browser-use get title                       # Título da página
browser-use get url                         # URL atual
browser-use get text                        # Texto da página
browser-use get html                        # HTML completo
```

### Interação
```bash
browser-use click 5                         # Clicar elemento por índice
browser-use click 100 200                   # Clicar por coordenadas (x y)
browser-use type "texto"                    # Digitar no foco atual
browser-use input 5 "texto"                 # Digitar em elemento específico
browser-use select 5 "opcao"               # Dropdown
browser-use hover 5                         # Mouse over
browser-use dblclick 5                      # Double-click
browser-use rightclick 5                    # Right-click
browser-use keys "Enter"                    # Enviar tecla
```

### Cookies
```bash
browser-use cookies get                     # Listar cookies
browser-use cookies set '{"name":"x","value":"y","domain":".site.com"}'
browser-use cookies clear                   # Limpar cookies
browser-use cookies export ./cookies.json   # Exportar
browser-use cookies import ./cookies.json   # Importar
```

### Espera
```bash
browser-use wait --visible 5                # Esperar elemento visível
browser-use wait --hidden 5                 # Esperar elemento sumir
browser-use wait --timeout 10000            # Timeout customizado
```

### JavaScript & Python
```bash
browser-use eval "document.title"           # Executar JS
browser-use eval "document.querySelectorAll('.price').length"
browser-use python "print(1+1)"             # Python com variáveis persistentes
```

### Tabs
```bash
browser-use switch 0                        # Mudar para tab 0
browser-use close-tab                       # Fechar tab atual
```

### Sessões
```bash
browser-use sessions                        # Listar sessões ativas
browser-use --sessionminha_sessao open "<url>"    # Sessão nomeada
browser-use --sessionminha_sessao close           # Fechar sessão específica
```

### Browser Modes
```bash
browser-use open "<url>"                    # Headless (padrão)
browser-use --headed open "<url>"           # Com janela visível
browser-use -b real open "<url>"            # Chrome real (perfil padrão)
browser-use -b real --profile NOME open "<url>"  # Chrome real com perfil
browser-use -b remote open "<url>"          # Browser cloud
```

---

## 📋 Referência Rápida — chrome-devtools-mcp

### Performance
```
# Via MCP tools (ToolSearch "chrome-devtools" para carregar schemas):
performance_start_trace    — Inicia trace (CWV: LCP, INP, CLS)
performance_stop_trace     — Para gravação
performance_analyze_insight — Deep-dive em insight (LCPBreakdown, DocumentLatency, INP, CLS)
take_memory_snapshot       — Heap snapshot para memory leaks
```

### Network
```
list_network_requests — Lista requests (filtrável: XHR, Fetch, Script, Stylesheet, Image...)
get_network_request   — Detalhes: headers, body, timing de request específica
```

### Lighthouse
```
lighthouse_audit — Audit a11y/SEO/best-practices (mode: navigation|snapshot, device: desktop|mobile)
```

### Emulation
```
emulate     — Throttling CPU/rede, geolocation, user agent, dark/light mode, viewport
resize_page — Ajustar viewport/window (width, height)
```

### Console
```
list_console_messages — Console com source maps e filtragem por tipo
get_console_message   — Detalhes de mensagem específica
```

### Extensions
```
list_extensions / install_extension / uninstall_extension / reload_extension / trigger_extension_action
```

### Input Avançado
```
fill_form    — Preencher múltiplos campos [{uid, value}, ...] de uma vez
drag         — Drag-and-drop (from_uid → to_uid)
upload_file  — Upload via file input (uid, filePath)
```

---

## 📋 Referência Rápida — agent-browser (Fallback)

### Navegação
```bash
agent-browser open "<url>"
agent-browser open "<url>" --session s1
agent-browser close
agent-browser reload
agent-browser back / forward
```

### Inspeção
```bash
agent-browser snapshot -i               # Elementos interativos (compacto)
agent-browser snapshot                   # Árvore completa
agent-browser screenshot ./output.png
agent-browser get text @e1
agent-browser get url
```

### Interação
```bash
agent-browser click @e1
agent-browser fill @e1 "texto"
agent-browser type "texto"
agent-browser select @e1 "opcao"
agent-browser hover @e1
agent-browser upload @e1 ./arquivo.pdf
```

### Chrome CDP (Perfil Logado)
```bash
# 1. Abrir Chrome com debug
taskkill //F //IM chrome.exe 2>/dev/null; sleep 2
"C:/Program Files/Google/Chrome/Application/chrome.exe" \
  --remote-debugging-port=9222 \
  --user-data-dir="$LOCALAPPDATA/agent-browser-profile" \
  --no-first-run &disown 2>/dev/null

# 2. Conectar agent-browser
curl -s http://localhost:9222/json/version
curl -s -X PUT "http://localhost:9222/json/new?https://URL_AQUI"
agent-browser connect "ws://localhost:9222/devtools/page/TAB_ID"
```

---

## ⚡ Protocolo de Uso

### 1. Sempre comece com estado
```bash
# browser-use
browser-use open "<url>"
browser-use state                # Elementos com índices numéricos

# agent-browser
agent-browser open "<url>"
agent-browser snapshot -i        # Elementos com refs @eN
```

### 2. Interaja por referência
```bash
# browser-use: índice numérico
browser-use click 5
browser-use input 3 "email@test.com"

# agent-browser: @eN refs
agent-browser click @e5
agent-browser fill @e3 "email@test.com"

# chrome-devtools-mcp: UIDs do take_snapshot
# click(uid="...", includeSnapshot=true)
```

### 3. Re-inspecione após cada ação que muda a página
### 4. Capture evidência com screenshot
### 5. SEMPRE feche ao terminar

## 🔒 Segurança
- NUNCA passe senhas diretamente — use variáveis de ambiente ou auth salvo
- Use sessões para isolar contextos
- browser-use cookies são exportáveis — não commitar cookies.json
- Credenciais agent-browser ficam encriptadas em `~/.agent-browser/`

## 🎯 Cenários Práticos

| Cenário | Ferramenta | Razão |
|---------|-----------|-------|
| Scraping rápido de dados | browser-use | Daemon persistente, JS eval |
| Testar Aria E2E | browser-use | Sessões paralelas, baixa latência |
| Testar landing page | browser-use | Screenshot + state rápido |
| **Performance audit (CWV)** | **chrome-devtools-mcp** 🟣 | Trace + insights |
| **Network debug (API calls)** | **chrome-devtools-mcp** 🟣 | Request/response detail |
| **Lighthouse (a11y/SEO)** | **chrome-devtools-mcp** 🟣 | Audit integrado |
| **Emular mobile + 3G** | **chrome-devtools-mcp** 🟣 | Device emulation |
| **Memory leak hunt** | **chrome-devtools-mcp** 🟣 | Heap snapshots |
| Acessar Salesforce logado | agent-browser + CDP | Precisa perfil Chrome logado |
| Postar no X/Twitter | agent-browser + CDP | Precisa login @opanteranegra77 |
| Preencher forms complexos | browser-use | input por índice + JS validation |
| Verificação visual (diff) | browser-use | Screenshot + eval JS comparativo |
| Upload de arquivo | agent-browser | `upload @eN` nativo |
| Monitoramento concorrente | browser-use | Named sessions paralelas |

## ⚙️ Infraestrutura

| Item | Detalhe |
|------|---------|
| **browser-use venv** | `C:/Users/PC/.browser-use-env/` (Python 3.12) |
| **browser-use MCP** | Configurado em `.mcp.json` via `browser-use-mcp.sh` |
| **chrome-devtools-mcp** | `npm i -g chrome-devtools-mcp` v0.21.0, MCP em `.mcp.json` com `--autoConnect` |
| **agent-browser** | Rust nativo, Chrome em `~/.agent-browser/browsers/` |
| **Chrome CDP profile** | `$LOCALAPPDATA/agent-browser-profile/` (porta 9222) |
| **Daemon socket** | `~/.browser-use/` (TCP no Windows) |
