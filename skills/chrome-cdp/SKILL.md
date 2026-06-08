---
name: chrome-cdp
description: >
  Interact with local Chrome browser session for debug, testing, performance profiling,
  network inspection, Lighthouse audits, and automation. Três abordagens: Claude in Chrome
  (extensão nativa), Chrome DevTools MCP (DevTools F12 completo), agent-browser + CDP (fallback).
domain: browser-automation
subdomain: chrome-integration
version: 3.0.0
author: deivithi
tags:
  - chrome
  - browser
  - cdp
  - debugging
  - testing
  - scraping
  - automation
  - performance
  - lighthouse
  - network
  - emulation
  - devtools
---

# 🌐 Chrome CDP — Integração com Chrome Local

> Acesso direto ao Chrome do usuário para debug, testes, performance, network inspection e automação autenticada.

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Auto-Routing abaixo.
- `gotchas.md` — ⚠️ Problemas conhecidos e soluções.

## 🧠 Auto-Routing de Abordagens

| Cenário | Abordagem | Como ativar |
|---------|-----------|-------------|
| Debug live (console errors, DOM) | **Claude in Chrome** 🟢 | `claude --chrome` ou `/chrome` |
| Verificação visual de UI | **Claude in Chrome** 🟢 | `/chrome` na sessão |
| Navegação autenticada (Google, X, Notion) | **Claude in Chrome** 🟢 | Usa logins do Chrome principal |
| Extração de dados de páginas | **Claude in Chrome** 🟢 | Pedir para navegar e extrair |
| Testes E2E de forms/fluxos | **Claude in Chrome** 🟢 | Navegar + interagir |
| **Performance profiling (LCP/INP/CLS)** | **Chrome DevTools MCP** 🟣 | `performance_start_trace` |
| **Network requests debug** | **Chrome DevTools MCP** 🟣 | `list_network_requests` |
| **Lighthouse audit (a11y/SEO)** | **Chrome DevTools MCP** 🟣 | `lighthouse_audit` |
| **Emulação device/rede/geo** | **Chrome DevTools MCP** 🟣 | `emulate` |
| **Memory leak investigation** | **Chrome DevTools MCP** 🟣 | `take_memory_snapshot` |
| **Console com source maps** | **Chrome DevTools MCP** 🟣 | `list_console_messages` |
| **Gestão de extensões Chrome** | **Chrome DevTools MCP** 🟣 | `list_extensions` |
| Automação headless/batch | **agent-browser + CDP** 🔵 | Setup manual (ver abaixo) |
| Quando extensão não disponível | **agent-browser + CDP** 🔵 | Fallback |

## 🟢 Abordagem Primária: Claude in Chrome (Extensão Nativa)

### Requisitos
- Google Chrome ou Microsoft Edge
- Extensão "Claude in Chrome" v1.0.36+ instalada
- Claude Code v2.0.73+ (CLI)
- Plano Anthropic direto (Pro/Max/Teams/Enterprise)

### Ativação
```bash
# Iniciar sessão com Chrome habilitado
claude --chrome

# Ou ativar dentro de sessão existente
/chrome
```

### Capabilities (MCP server `claude-in-chrome`)
- **Navigate** — abrir URLs, navegar entre páginas
- **Click** — clicar em elementos por seletor ou texto
- **Type** — digitar em inputs e formulários
- **Read DOM** — ler estrutura e conteúdo da página
- **Console** — ler erros e logs do console
- **GIFs** — gravar interações como GIF
- **Tabs** — criar e gerenciar abas
- **Dialogs** — lidar com alerts e modais

### Permissões de Sites
- Controladas na extensão Chrome (não no Claude Code)
- Configurar quais sites Claude pode acessar via ícone da extensão

### Troubleshooting
| Problema | Solução |
|----------|---------|
| Extensão não detectada | Verificar em `chrome://extensions`, reinstalar, `/chrome` → "Reconnect" |
| Browser não responde | Fechar modais/alerts, criar nova aba, reiniciar extensão |
| Conexão cai em sessões longas | `/chrome` → "Reconnect extension" (service worker idle) |
| EADDRINUSE (Windows) | Reiniciar Claude Code, fechar outras sessões usando Chrome |
| Native messaging errors | Reinstalar Claude Code para regenerar config |

## 🟣 Chrome DevTools MCP (DevTools F12 Completo)

> **29 tools** que expõem as Chrome DevTools completas como MCP. Performance profiling, network inspection, Lighthouse, emulação, heap snapshots — o que nenhuma outra ferramenta do ecossistema oferece.

### Requisitos
- `chrome-devtools-mcp` v0.21.0+ instalado globalmente (`npm i -g chrome-devtools-mcp`)
- Node.js ^20.19.0 || ^22.12.0 || >=23
- Chrome com auto-connect habilitado: `chrome://inspect/#remote-debugging` (uma vez)
- Configurado em `.mcp.json` com `--autoConnect`

### Conexão
Auto-conecta ao Chrome rodando (Chrome 135+). Sem necessidade de matar/reiniciar Chrome.

### Tools por Categoria

#### ⚡ Performance (EXCLUSIVO)
| Tool | O que faz |
|------|-----------|
| `performance_start_trace` | Inicia trace de performance — encontra CWV: LCP, INP, CLS |
| `performance_stop_trace` | Para gravação do trace |
| `performance_analyze_insight` | Deep-dive em insight específico (LCPBreakdown, DocumentLatency, INP, CLS) |
| `take_memory_snapshot` | Captura heap snapshot JS para investigar memory leaks |

#### 🌐 Network (EXCLUSIVO)
| Tool | O que faz |
|------|-----------|
| `list_network_requests` | Lista todas as requests desde última navegação (filtrável por tipo) |
| `get_network_request` | Detalhes de request específica (headers, body, timing) |

#### 🔍 Lighthouse (EXCLUSIVO)
| Tool | O que faz |
|------|-----------|
| `lighthouse_audit` | Audit de acessibilidade, SEO e best-practices (mode: navigation/snapshot, device: desktop/mobile) |

#### 📱 Emulation (EXCLUSIVO)
| Tool | O que faz |
|------|-----------|
| `emulate` | Throttling CPU/rede, geolocation, user agent, dark/light mode, viewport |
| `resize_page` | Ajustar viewport/window |

#### 🖥️ Console (UPGRADE)
| Tool | O que faz |
|------|-----------|
| `list_console_messages` | Lista console messages com source maps e filtragem por tipo |
| `get_console_message` | Detalhes de mensagem específica |

#### 🧩 Extensions (EXCLUSIVO)
| Tool | O que faz |
|------|-----------|
| `install_extension` | Instalar extensão unpacked |
| `uninstall_extension` | Remover extensão por ID |
| `list_extensions` | Listar extensões (nome, ID, versão, status) |
| `reload_extension` | Recarregar extensão unpacked |
| `trigger_extension_action` | Disparar browser action de extensão |

#### 🎯 Input Avançado
| Tool | O que faz |
|------|-----------|
| `fill_form` | Preencher múltiplos campos de formulário de uma vez |
| `drag` | Drag-and-drop entre elementos |
| `upload_file` | Upload de arquivo via file input |
| `click` / `hover` / `fill` / `type_text` / `press_key` | Interação padrão com UIDs |

#### 🔧 Debugging
| Tool | O que faz |
|------|-----------|
| `take_snapshot` | A11y-tree snapshot com UIDs para interação precisa |
| `take_screenshot` | Screenshot (página, elemento, fullPage) |
| `evaluate_script` | Executar JavaScript no contexto da página |
| `list_pages` / `select_page` / `new_page` / `close_page` | Gestão de tabs |
| `navigate_page` / `wait_for` | Navegação com wait conditions |

#### 🔌 In-Page Tools
| Tool | O que faz |
|------|-----------|
| `list_in_page_tools` | Lista tools expostas pela página via `window.__dtmcp` |
| `execute_in_page_tool` | Executa tool in-page |

### Exemplos de Uso

```
# Performance audit
"Faça um trace de performance da página e me diga os Core Web Vitals"
"Analise o LCP breakdown desse trace"

# Network debug
"Liste todas as requests XHR dessa página"
"Me mostre headers e body da request para /api/users"

# Lighthouse
"Rode um Lighthouse audit de acessibilidade nessa página (mobile)"

# Emulation
"Emule um Moto G4 com 3G lento e tire screenshot"
"Ative dark mode e viewport 375x667"

# Memory
"Capture um heap snapshot para investigar memory leak"
```

## 🔵 Fallback: agent-browser + CDP (Porta 9222)

> Usar quando: extensão não disponível, automação headless, ou batch processing.

### Perfil Dedicado
Perfil Chrome em `$LOCALAPPDATA/agent-browser-profile/` com logins permanentes em X, Google, LinkedIn.

### Setup
```bash
# 1. Matar Chrome e reabrir com debug
taskkill //F //IM chrome.exe 2>/dev/null
sleep 2
"C:/Program Files/Google/Chrome/Application/chrome.exe" \
  --remote-debugging-port=9222 \
  --user-data-dir="$LOCALAPPDATA/agent-browser-profile" \
  --no-first-run &disown 2>/dev/null

# 2. Verificar porta ativa
curl -s http://localhost:9222/json/version

# 3. Criar nova tab via CDP
curl -s -X PUT "http://localhost:9222/json/new?https://URL_AQUI"

# 4. Conectar agent-browser na tab via WebSocket
agent-browser connect "ws://localhost:9222/devtools/page/TAB_ID"
```

### ⚠️ Regras do CDP
- Fechar TODAS as instâncias do Chrome antes de abrir com debug
- `agent-browser connect 9222` sozinho NÃO funciona — conectar via WebSocket da tab
- User-data-dir NÃO pode ser o mesmo do Chrome padrão
- Google bloqueia login em browsers automatizados — usar email/senha, não "Login com Google"

## 🔗 Related Skills
- `product-verification` — Smoke tests e verificação E2E (usa browser-use como primário)
- `webapp-testing` — Testes com Playwright para apps locais
- `runbook` — Investigação estruturada quando verificação revela falhas

---

## 📋 Exemplos de Uso

### Debug de Console Errors (Claude in Chrome)
```
# Na sessão com --chrome ativo:
"Abra localhost:3000 e me diga se há erros no console"
"Navegue até a página de login e teste com credenciais inválidas"
```

### Extração de Dados (Claude in Chrome)
```
"Vá até [site], extraia a tabela de preços como CSV"
"Acesse meu Gmail e liste os últimos 5 emails não lidos"
```

### Verificação Visual (Claude in Chrome)
```
"Compare a página atual com este mockup Figma"
"Verifique se o formulário exibe mensagens de erro corretas"
```
