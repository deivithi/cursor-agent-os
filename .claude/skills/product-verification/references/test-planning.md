# 📋 Planejamento de Testes — Estratégia 3 Rodadas

> Metodologia adversarial: **encontrar bugs, não provar que funciona.**
> Absorvido de browserbase/ui-test, adaptado para browser-use CLI.

---

## 1. Estratégia de 3 Rodadas

Antes de executar qualquer teste, planejar em 3 rodadas sequenciais:

### Rodada 1 — Funcional
Mapear cada fluxo core do produto:
- Ação do usuário → resultado esperado
- Apenas happy path, sem edge cases ainda

**Exemplo:**
```
T01: Abrir /login → form com email e senha visíveis
T02: Preencher credenciais válidas → redireciona para /dashboard
T03: Dashboard carrega → sidebar, header, cards visíveis
```

### Rodada 2 — Adversarial
Re-examinar CADA item da Rodada 1 e adicionar:
- Paths de erro (credenciais inválidas, campos vazios)
- Edge cases (500+ caracteres, caracteres especiais, XSS)
- Race conditions (double-submit, click rápido)
- Empty states (sem dados, primeira vez)
- Tipos de usuário diferentes (admin, viewer, anônimo)

**Exemplo:**
```
T04: Login com email vazio → mensagem de erro, não submete
T05: Login com XSS no email (<script>alert(1)</script>) → sanitizado
T06: Double-click no botão login → apenas 1 request enviado
T07: Login com senha de 500 chars → não quebra layout
```

### Rodada 3 — Cobertura
Gaps que as 2 primeiras rodadas não cobriram:
- **Accessibility:** navegação por teclado (Tab/Shift+Tab), ARIA labels
- **Responsive:** viewports 375px (mobile), 768px (tablet)
- **Console errors:** zero erros JS no console
- **Consistência visual:** elementos alinhados, sem overflow

**Exemplo:**
```
T08: Tab navega pelos campos do form login em ordem lógica
T09: Em viewport 375px, form login é usável sem scroll horizontal
T10: Nenhum erro JS no console durante fluxo de login
```

### Deduplicação
Após as 3 rodadas:
1. Remover testes duplicados
2. Numerar sequencialmente: T01, T02, ..., Tnn
3. Agrupar por página/feature para atribuir a subagentes

---

## 2. Budgets de Steps para Subagentes

Cada subagente recebe um limite explícito de comandos browser-use:

| Escopo | Budget | Quando usar |
|--------|--------|-------------|
| ~25 steps | Checks focados | 3-5 testes em 1 componente |
| ~40 steps | Página completa | Funcional + adversarial + a11y de 1 página |
| ~75 steps | Multi-página | Fluxo E2E cruzando várias rotas |

**Incluir no prompt do subagente:**
> "Você tem um budget de N comandos browser-use. Conte conforme avança. Ao atingir N, pare e reporte STEP_PASS/STEP_FAIL para testes concluídos e STEP_SKIP para não cobertos."

Subagentes NÃO retentam após esgotar budget. O agente principal aceita resultados parciais.

---

## 3. Workflow Diff-Driven

Para verificar apenas o que mudou (ideal para PRs):

### Passo 1 — Analisar diff
```bash
git diff --name-only HEAD~1
```
Categorizar cada arquivo: component, route, style, form, interactive, navigation, non-UI.

### Passo 2 — Mapear files → URLs
| Framework | Regra | Exemplo |
|-----------|-------|---------|
| Next.js App Router | `app/[rota]/page.tsx` → `/[rota]` | `app/dashboard/page.tsx` → `/dashboard` |
| Next.js Pages | `pages/[rota].tsx` → `/[rota]` | `pages/settings.tsx` → `/settings` |
| Vite/React | Router manual — buscar em routes config | `src/pages/Dashboard.tsx` → verificar router |
| Nuxt | `pages/[rota].vue` → `/[rota]` | `pages/profile.vue` → `/profile` |

### Passo 3 — Verificar ambiente
```bash
git branch --show-current          # Branch correto?
browser-use open "http://localhost:3000"
browser-use eval "document.title"  # App respondendo?
```

### Passo 4 — Gerar test plan focado
Para cada área alterada, aplicar as 3 rodadas (funcional + adversarial + cobertura) apenas nos fluxos impactados.

### Passo 5 — Executar e reportar
Usar Step Markers (ver `assertion-patterns.md`) e gerar relatório HTML (ver `scripts/generate-report.sh`).

---

## 4. Template de Plano de Testes

```markdown
## Plano de Testes — [Produto] — [Data BRT]

**URL:** http://localhost:3000
**Branch:** feature/xyz
**Escopo:** [diff-driven | full | smoke]

### Testes
| ID | Tipo | Descrição | Budget |
|----|------|-----------|--------|
| T01 | Funcional | Login com credenciais válidas | — |
| T02 | Funcional | Dashboard carrega com dados | — |
| T03 | Adversarial | Login com XSS no email | — |
| T04 | Adversarial | Double-submit do form | — |
| T05 | Cobertura | Keyboard nav no form login | — |
| T06 | Cobertura | Viewport 375px responsivo | — |

### Subagentes
| Agente | Testes | Budget |
|--------|--------|--------|
| Agent 1 — Login | T01, T03, T04, T05 | 25 steps |
| Agent 2 — Dashboard | T02, T06 | 25 steps |
```
