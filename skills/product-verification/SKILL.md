---
name: product-verification
description: >
  Verificação automatizada de produtos com teste adversarial. browser-use CLI (principal) e agent-browser (fallback).
  Smoke tests, E2E, visual regression, API health + adversarial testing (XSS, double-submit, a11y, responsive).
  Planejamento 3 rodadas, Step Markers, relatórios HTML standalone e workflow diff-driven.
domain: quality-assurance
subdomain: e2e-testing
version: 3.0.0
author: deivithi
tags:
  - testing
  - verification
  - e2e
  - smoke-test
  - browser-use
  - agent-browser
  - screenshot
  - assertion
  - quality
---

# 🧪 Product Verification — Verificação Automatizada de Produtos

> **"Vale investir 1 semana de engenheiro só para tornar suas skills de verificação excelentes."** — Thariq, Anthropic

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Workflow abaixo.
- `scripts/verify-aria.sh` — Smoke test completo do Aria (login, dashboard, API).
- `scripts/verify-landing.sh` — Teste da landing page (form, QR, responsividade).
- `scripts/screenshot-diff.sh` — Comparação visual antes/depois de mudanças.
- `scripts/generate-report.sh` — 📊 Gera relatório HTML a partir de Step Markers.
- `references/browser-use-patterns.md` — 🟢 Patterns do browser-use CLI (PRINCIPAL).
- `references/agent-browser-patterns.md` — 🔵 Patterns do agent-browser (fallback).
- `references/assertion-patterns.md` — Como escrever assertions robustas + Step Markers.
- `references/test-planning.md` — 📋 Estratégia 3 rodadas + budgets + diff-driven.
- `references/adversarial-patterns.md` — ⚔️ Catálogo de patterns adversariais por categoria.
- `references/report-template.html` — 📊 Template HTML standalone para relatórios.
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.

## 🧠 Auto-Routing de Ferramentas
| Cenário | Ferramenta | Razão |
|---------|-----------|-------|
| Smoke test, scraping, verificação rápida | **browser-use** | Daemon ~50ms, JSON output |
| Verificações paralelas | **browser-use** | Named sessions |
| Chrome logado (Salesforce, X, Google) | **Claude in Chrome** 🟢 | `claude --chrome` ou `/chrome` |
| Chrome logado (headless/batch) | **agent-browser + CDP** 🔵 | Perfil com login (fallback) |
| Upload de arquivo em form | **agent-browser** | `upload @eN` nativo |

## 🔗 Related Skills
- `runbook` — Use se a verificação revelar um padrão de falha conhecido
- `cicd` — Use para re-deploy após correção de bug encontrado
- `scaffolding` — Use para gerar fixtures de teste ausentes
- `webapp-testing` — Playwright para testes locais (complementar ao browser-use)
- `security-audit` — Use quando adversarial testing revelar vulnerabilidades reais

---

## 1. Conceito

Product Verification skills descrevem **como testar e verificar** que o código está funcionando. São pareadas com ferramentas externas (agent-browser, Playwright, tmux) para realizar a verificação.

### Princípios
1. **Snapshot antes de interagir** — Nunca clicar/preencher sem ter os refs do agent-browser
2. **Assertions programáticas** — Não confiar apenas em verificação visual; assertar estado em cada step
3. **Evidência documentada** — Capturar screenshots como prova de funcionamento
4. **Re-snapshot após ações** — A página muda, os refs mudam
5. **Sessões para fluxos multi-step** — `--session nome` mantém estado no agent-browser

---

## 2. Workflow de Verificação

### Passo 1 — Definir Escopo
Antes de verificar, definir claramente:
- **O que será testado** (URL, fluxo, componente)
- **Critérios de sucesso** (o que "funcionar" significa)
- **Assertions obrigatórias** (estado esperado em cada step)

### Passo 1.5 — Planejar Testes (Modo Adversarial)
> Para verificações profundas, além do happy path. Detalhes em `references/test-planning.md`.

Planejar em **3 rodadas** antes de executar:
1. **Funcional** — fluxos core: ação → resultado esperado
2. **Adversarial** — tentar quebrar: XSS, empty, overflow, double-submit, race conditions
3. **Cobertura** — gaps: accessibility, responsive, console errors

Deduplicar em lista numerada (T01..Tnn) e atribuir a subagentes com **budgets de steps** (~25/~40/~75).
Para PRs, usar **workflow diff-driven**: `git diff` → mapear files → URLs → test plan focado.

### Passo 2 — Executar Verificação
```bash
# Abrir a URL do produto
agent-browser open "<url>" --session verificacao

# Capturar estado interativo
agent-browser snapshot -i

# Interagir (preencher form, clicar botões)
agent-browser click @e1
agent-browser type @e2 "texto de teste"

# Re-snapshot para verificar resultado
agent-browser snapshot -i

# Screenshot como evidência
agent-browser screenshot ./evidencias/teste-$(date +%Y%m%d-%H%M).png
```

### Passo 3 — Assertar e Documentar

**Step Markers** — usar formato estruturado para cada teste:
```
STEP_PASS|T01|document.title === "Dashboard"
STEP_FAIL|T02|botão "Salvar" visível → não encontrado|./screenshots/T02.png
STEP_SKIP|T03|Budget esgotado
```

**Hierarquia de Rigor** (preferir os de cima):
1. 🟢 `browser-use eval` determinístico (mais forte)
2. 🟡 Element match via `browser-use --json state`
3. 🟠 Before/after comparison (state → ação → state)
4. 🔴 Screenshot visual (mais fraco — só quando tree não captura)

Para cada step, verificar:
- [ ] Elemento esperado está presente na página?
- [ ] Texto/valor correto está sendo exibido?
- [ ] Nenhum erro visível no console ou na UI?
- [ ] Navegação levou ao destino correto?

### Passo 4 — Fechar e Reportar
```bash
agent-browser close
```

Gerar relatório:
```markdown
## Relatório de Verificação — [Produto] — [Data]
- **URL testada:** ...
- **Fluxo:** ...
- **Resultado:** ✅ PASS / ❌ FAIL
- **Screenshots:** ./evidencias/...
- **Findings:** ...
```

---

## 3. Tipos de Verificação

### 3.1 Smoke Test (Rápido)
Verifica que o produto **carrega e funciona no nível básico**:
- Página carrega sem erro 500
- Elementos críticos estão visíveis
- Nenhum JS error no console

### 3.2 Fluxo Crítico (E2E)
Testa um **fluxo completo** de ponta a ponta:
- Signup → Email → Onboarding
- Login → Dashboard → Ação → Resultado
- Form → Submit → Confirmação

### 3.5 Teste Adversarial
Testa tentando **quebrar** features, não apenas verificar happy path:
- Forms: XSS, double-submit, overflow, campos vazios
- Modals: Escape, focus trap, click outside
- Responsive: viewports 375px/768px, touch targets ≥44px
- Accessibility: keyboard-only nav, ARIA labels, axe-core

> Catálogo completo com comandos browser-use em `references/adversarial-patterns.md`

### 3.3 Regression Visual
Compara **screenshots antes/depois** de uma mudança:
- Captura screenshot da versão atual
- Aplica mudança
- Captura screenshot da nova versão
- Compara visualmente (ou via diff de pixels)

### 3.4 API Health Check
Verifica que **endpoints retornam dados corretos**:
```bash
# Via curl dentro do agent-browser ou direto
curl -s "https://api.example.com/health" | jq '.status'
```

---

## 4. Projetos Configurados

### Aria (SaaS — Vercel)
- **URL:** Verificar deploy ativo via `vercel ls`
- **Fluxo crítico:** Login → Dashboard → Chat com agente → Resposta válida
- **Script:** `scripts/verify-aria.sh`

### Landing Page (Eventos Febracis — Netlify)
- **URL:** Verificar deploy ativo via Netlify
- **Fluxo crítico:** Form preenchido → Submit → QR Code gerado → Lead registrado
- **Script:** `scripts/verify-landing.sh`

### FIO-IA (Thread Generator)
- **Verificação:** Checar que threads foram postadas no horário via Task Scheduler
- **Sem UI** — verificação via logs e API do X

---

## 5. Boas Práticas (Thariq/Anthropic)

1. **Grave vídeo do output do Claude** para ver exatamente o que foi testado
2. **Enforce assertions programáticas** em cada step — não apenas "parece ok"
3. **Inclua scripts na skill** — dê ao Claude ferramentas, não apenas instruções
4. **Use hooks para rodar verificação automaticamente** após deploy (PostToolUse em Bash com matcher de deploy)
5. **Itere nos gotchas** — cada falha de verificação deve virar um gotcha documentado
