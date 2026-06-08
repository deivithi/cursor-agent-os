# ⚠️ Gotchas — Product Verification

> Problemas conhecidos ao executar verificações automatizadas. Consulte quando algo falhar.

---

## 1. agent-browser refs mudam após qualquer interação na página

- **Sintoma:** `agent-browser click @e5` clica no elemento errado — o ref `@e5` agora aponta para outro elemento
- **Causa raiz:** Após qualquer ação (click, type, scroll), o DOM muda e os refs são recalculados. O `@e5` de antes do click pode ser `@e8` depois
- **Solução:** SEMPRE rodar `agent-browser snapshot -i` após cada ação antes de interagir novamente
- **Prevenção:** Tratar snapshots como "imutáveis" — cada snapshot é válido apenas até a próxima ação
- **Descoberto em:** 2026-03-18

---

## 2. Screenshots em Windows salvam com path incorreto quando usa barras mistas

- **Sintoma:** `agent-browser screenshot ./evidencias/teste.png` falha com "path not found" no Windows
- **Causa raiz:** Git Bash converte paths com `/` para paths Windows, mas agent-browser pode não lidar bem com paths que contêm espaços ou caracteres especiais
- **Solução:** Usar paths absolutos sem espaços: `agent-browser screenshot "C:/temp/teste.png"` e depois mover o arquivo
- **Prevenção:** Criar diretório de screenshots em path sem espaços antes de executar
- **Descoberto em:** 2026-03-18

---

## 3. SPAs com lazy loading não mostram conteúdo no primeiro snapshot

- **Sintoma:** Snapshot captura página em branco ou com spinner — o conteúdo real ainda está carregando
- **Causa raiz:** SPAs (React, Vue, Next.js) fazem render assíncrono. O agent-browser captura o DOM antes do JS terminar de renderizar
- **Solução:** Aguardar antes do snapshot: `sleep 2 && agent-browser snapshot -i`. Para apps mais pesadas, verificar se um elemento específico existe antes de prosseguir. Com browser-use: `browser-use wait --visible INDICE`
- **Prevenção:** No script de verificação, incluir `wait_for_element` como primeira assertion antes de qualquer interação
- **Descoberto em:** 2026-03-18

---

## 4. browser-use requer Python 3.12 (incompatível com 3.14)

- **Sintoma:** `RuntimeError: There is no current event loop` ou `Pydantic V1 incompatible with Python 3.14`
- **Causa raiz:** `asyncio.get_event_loop()` removido no Python 3.14, e Pydantic V1 não suporta 3.14
- **Solução:** SEMPRE usar o venv dedicado: `C:/Users/PC/.browser-use-env/Scripts/python.exe -m browser_use.skill_cli.main`
- **Prevenção:** O wrapper `browser-use-mcp.sh` e o MCP server já usam o venv correto. Nunca rodar `browser-use` direto com Python 3.14
- **Descoberto em:** 2026-03-22

---

## 5. browser-use --json deve vir ANTES do subcomando

- **Sintoma:** `unrecognized arguments: --json` ao rodar `browser-use state --json`
- **Causa raiz:** Flags globais (`--json`, `--session`, `--browser`) devem preceder o subcomando
- **Solução:** `browser-use --json state` (não `browser-use state --json`)
- **Prevenção:** Sempre colocar flags globais antes do subcomando
- **Descoberto em:** 2026-03-22

---

## 6. browser-use daemon primeiro comando lento (~2s)

- **Sintoma:** Primeiro `browser-use open` demora 2-3 segundos, os seguintes são instantâneos
- **Causa raiz:** O daemon multi-session inicia em background no primeiro comando. Subsequentes usam daemon existente (~50ms)
- **Solução:** Aceitar a latência do primeiro comando — é normal. Para scripts batch, fazer um `browser-use open about:blank` como warmup
- **Prevenção:** Não interpretar a latência inicial como erro
- **Descoberto em:** 2026-03-22

---

## 7. browser-use usa `--session` por extenso, não `-s`

- **Sintoma:** `unrecognized arguments: -s nome` ao tentar usar abreviação
- **Causa raiz:** O parser do browser-use aceita `--session` mas não registra `-s` como alias
- **Solução:** Sempre usar `browser-use --session nome open "<url>"` (por extenso)
- **Prevenção:** Na documentação e skills, usar apenas `--session` (nunca `-s`)
- **Descoberto em:** 2026-03-22

---

## 8. XSS payloads em `browser-use eval` podem causar erro de parsing

- **Sintoma:** `browser-use eval "document.querySelector('<script>')"` falha com syntax error
- **Causa raiz:** O shell interpreta `<`, `>`, `'`, `"` antes de passar ao browser-use. Aspas aninhadas conflitam
- **Solução:** Escapar aspas internas ou usar strings sem caracteres especiais do shell:
  ```bash
  # Errado
  browser-use eval "document.querySelector('<script>')"
  # Correto
  browser-use eval 'document.querySelectorAll("script").length'
  ```
- **Prevenção:** Em patterns adversariais, usar `browser-use input` para injetar o payload no campo e `browser-use eval` apenas para verificar se foi sanitizado
- **Descoberto em:** 2026-04-03

---

## 9. Viewport resize via eval não funciona em headless

- **Sintoma:** `browser-use eval "window.resizeTo(375, 812)"` executa sem erro mas viewport não muda
- **Causa raiz:** `window.resizeTo()` é bloqueado em contextos headless e em janelas que não foram abertas via `window.open()`
- **Solução:** Para verificar responsividade, usar eval apenas para LEITURA (`window.innerWidth`). Verificar CSS responsivo via media query checks:
  ```bash
  browser-use eval "window.matchMedia('(max-width: 768px)').matches"
  ```
- **Prevenção:** Não tentar resize — verificar CSS responsivo via media queries e computed styles
- **Descoberto em:** 2026-04-03

---

## 10. Race conditions não são testáveis via comandos CLI sequenciais

- **Sintoma:** Teste de double-click via `browser-use click 5 && browser-use click 5` não simula race condition real — há ~50ms gap entre comandos
- **Causa raiz:** Cada comando CLI é uma chamada HTTP ao daemon. O gap entre chamadas é maior que um double-click real
- **Solução:** Usar `browser-use eval` para simular interações simultâneas:
  ```bash
  browser-use eval "const btn = document.querySelector('button[type=submit]'); btn.click(); btn.click();"
  ```
- **Prevenção:** Qualquer teste de race condition, spam de clicks ou interações rápidas deve usar eval, não comandos sequenciais
- **Descoberto em:** 2026-04-03

---
