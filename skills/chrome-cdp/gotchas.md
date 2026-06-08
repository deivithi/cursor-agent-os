# ⚠️ Gotchas — Chrome CDP

## Claude in Chrome (Extensão Nativa)

### 1. Não funciona no WSL
- **Sintoma:** Extensão não detectada
- **Causa:** WSL não tem acesso ao Chrome do Windows
- **Fix:** Usar Claude Code nativo no Windows (não WSL)

### 2. Service worker idle em sessões longas
- **Sintoma:** Comandos param de funcionar após ~5min de inatividade
- **Causa:** Chrome desativa service workers inativos
- **Fix:** `/chrome` → "Reconnect extension"

### 3. EADDRINUSE no Windows
- **Sintoma:** Erro ao iniciar conexão com Chrome
- **Causa:** Outra sessão Claude Code já está conectada ao Chrome
- **Fix:** Fechar outras sessões Claude Code, reiniciar

### 4. Contexto inflado com Chrome always-on
- **Sintoma:** Sessões ficam lentas, contexto comprime cedo
- **Causa:** Chrome habilitado por padrão injeta dados do browser no contexto
- **Fix:** Não habilitar "Enabled by default" — usar `--chrome` ou `/chrome` sob demanda

### 5. Modais bloqueiam comandos
- **Sintoma:** Browser não responde a navegação/clicks
- **Causa:** Alert/confirm/prompt modal aberto bloqueia interação
- **Fix:** Fechar o modal manualmente, depois continuar

### 6. Brave/Arc não suportados
- **Sintoma:** Extensão instala mas não conecta
- **Causa:** Apenas Chrome e Edge são suportados oficialmente
- **Fix:** Usar Google Chrome ou Microsoft Edge

## agent-browser + CDP (Fallback)

### 7. `agent-browser connect 9222` perde sessão
- **Sintoma:** Conecta mas perde cookies/login
- **Causa:** Conectar pela porta sem especificar tab perde contexto
- **Fix:** Conectar via WebSocket da tab: `agent-browser connect "ws://localhost:9222/devtools/page/TAB_ID"`

### 8. Chrome principal bloqueia debug
- **Sintoma:** Chrome não inicia com `--remote-debugging-port`
- **Causa:** Outra instância Chrome usando o mesmo user-data-dir
- **Fix:** `taskkill //F //IM chrome.exe` antes de abrir com debug

### 9. Cookies DPAPI não transferem
- **Sintoma:** Copiar arquivo Cookies não preserva login
- **Causa:** Chrome encripta cookies com DPAPI (chave por máquina/user)
- **Fix:** Login manual necessário no perfil de debug

### 10. Google bloqueia login em automação
- **Sintoma:** "This browser or app may not be secure" ao logar
- **Causa:** Google detecta flags de automação
- **Fix:** Usar email/senha direto, não "Login com Google"

## Chrome DevTools MCP

### 11. autoConnect não detecta Chrome
- **Sintoma:** `chrome-devtools-mcp` inicia mas não conecta ao Chrome rodando
- **Causa:** Chrome precisa ter auto-connect habilitado manualmente (uma vez)
- **Fix:** Abrir `chrome://inspect/#remote-debugging` no Chrome e habilitar. Requer Chrome 135+

### 12. Node.js incompatível
- **Sintoma:** Erro ao iniciar `chrome-devtools-mcp`
- **Causa:** Requer Node.js ^20.19.0 || ^22.12.0 || >=23
- **Fix:** `node --version` — atualizar se necessário. Node 21.x não suportado

### 13. Conflito de porta com agent-browser CDP
- **Sintoma:** chrome-devtools-mcp e agent-browser tentam usar mesma porta
- **Causa:** Ambos usam CDP mas por caminhos diferentes
- **Fix:** chrome-devtools-mcp com `--autoConnect` NÃO usa porta — usa pipe nativo. Só conflita se usar `--browserUrl` na mesma porta 9222. Manter `--autoConnect` (padrão)

### 14. Performance trace não inicia
- **Sintoma:** `performance_start_trace` retorna erro
- **Causa:** Já existe um trace ativo ou página não carregou
- **Fix:** Chamar `performance_stop_trace` primeiro, depois re-iniciar. Garantir página carregada

### 15. Lighthouse timeout em páginas pesadas
- **Sintoma:** `lighthouse_audit` demora muito ou falha
- **Causa:** Páginas com muitos recursos levam tempo no Lighthouse
- **Fix:** Usar `mode: "snapshot"` em vez de `"navigation"` para páginas já carregadas

### 16. Telemetria habilitada por padrão
- **Sintoma:** chrome-devtools-mcp envia usage statistics
- **Causa:** Telemetria opt-out, não opt-in
- **Fix:** Adicionar `--no-usage-statistics` nos args do `.mcp.json` se desejado

### 17. Puppeteer Chrome vs Chrome instalado
- **Sintoma:** chrome-devtools-mcp usa Chromium do Puppeteer em vez do Chrome real
- **Causa:** Sem `--autoConnect` ou `--browserUrl`, ele lança Chrome próprio
- **Fix:** Sempre usar `--autoConnect` para conectar ao Chrome real (com logins, extensões)
