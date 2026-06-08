---
name: ui-forge
description: >
  Geração de UI production-grade a partir de prompts ou URLs de referência.
  Orquestra frontend-design, browser-use e webapp-testing num fluxo único.
  Modos: prompt puro, clone, enhance, inspire. Output: TSX real ou HTML standalone.
  Keywords: gerar UI, criar interface, clonar site, design de tela, componente visual,
  ui-forge, forjar UI, criar página, prototipar, mockup, wireframe.
domain: frontend
subdomain: design-orchestration
version: 1.0.0
author: deivithi
tags:
  - frontend
  - design
  - UI
  - generation
  - clone
  - prototype
  - React
  - Tailwind
  - MagicUI
---

# 🔨 UI Forge — Geração de UI Orquestrada

> **Alternativa gratuita e superior ao AIDesigner.ai ($25/mês).**
> Gera componentes TSX reais (não HTML morto), com design system integrado,
> 150+ componentes animados, e verificação visual — sem créditos, sem vendor lock-in.

## 📁 File Structure
- `SKILL.md` — Você está aqui. Workflow completo de geração.
- `gotchas.md` — Problemas conhecidos e edge cases.

## 🔗 Related Skills
- `frontend-design` — Engine de geração (paletas, tipografia, MagicUI, anti-AI-slop)
- `web-artifacts-builder` — Bundle React → HTML standalone (artifacts)
- `webapp-testing` — Verificação funcional de UIs geradas
- `chrome-cdp` — Screenshots e inspeção avançada via DevTools

---

## Quando Usar

- Criar interface/componente/página a partir de descrição textual
- Clonar visual de um site existente (URL → componente)
- Melhorar UI existente com referência de outro site
- Usar site como inspiração de estilo para nova UI
- Prototipar rapidamente com componentes profissionais
- Qualquer pedido que envolva "gerar UI", "criar tela", "forjar interface"

## Quando NÃO Usar (→ Handoff)

- Gráficos/charts de dados → `data-charts`
- Apresentações/slides → `markdown-slides` ou `frontend-slides`
- PDF/PPTX/DOCX → `artifact-factory`
- Design no Figma/Canva → usar Figma MCP ou Canva MCP direto

---

## Workflow

```
PROMPT DO USUÁRIO
    │
    ├─ [1] DETECT ── Auto-detectar contexto do projeto
    │
    ├─ [2] MODE ──── Classificar modo (prompt / clone / enhance / inspire)
    │
    ├─ [3] DESIGN ── Gerar UI via frontend-design engine
    │
    ├─ [4] OUTPUT ── Salvar componente (TSX ou HTML standalone)
    │
    └─ [5] VERIFY ── Preview + feedback loop
```

### Fase 1: DETECT — Contexto do Projeto

Ler automaticamente o projeto para adaptar o output:

```
Detectar:
  ├─ Framework  → package.json (next, react, vue, svelte, astro, none)
  ├─ Styling    → tailwind.config, postcss.config, styled-components
  ├─ Components → shadcn (components.json), Radix, MUI, Chakra
  ├─ Tokens     → CSS variables, design tokens, theme config
  └─ Paths      → src/components/, app/, pages/
```

**Se nenhum projeto detectado** → output HTML standalone (Tailwind CDN).

### Fase 2: MODE — Classificar Intenção

| Modo | Trigger | Comportamento |
|------|---------|---------------|
| **Prompt** | Sem URL, descrição textual | Gerar do zero usando `frontend-design` |
| **Clone** | URL + "clonar/copiar/replicar" | Capturar visual da URL → reproduzir fielmente |
| **Enhance** | URL + "melhorar/modernizar/refazer" | Capturar URL → gerar versão melhorada |
| **Inspire** | URL + "inspirar/estilo de/como o" | Extrair estilo da URL → aplicar em design novo |

#### Reference Mode (Clone/Enhance/Inspire)

Quando URL fornecida, capturar referência via browser-use:

```bash
# 1. Abrir e capturar
browser-use open "<URL>"
browser-use screenshot ./output/reference.png
browser-use eval "JSON.stringify({
  title: document.title,
  colors: getComputedStyle(document.body).backgroundColor,
  fonts: getComputedStyle(document.body).fontFamily,
  meta: document.querySelector('meta[name=description]')?.content
})"
browser-use get html  # Para clone mode (extrair estrutura)
browser-use close

# 2. Analisar screenshot + dados extraídos
# 3. Usar como contexto para geração
```

### Fase 3: DESIGN — Geração via frontend-design

Aplicar TODOS os princípios da skill `frontend-design`:

1. **Anti-AI-Slop** — Zero gradientes genéricos, zero "Welcome to...", zero cards uniformes
2. **Paleta derivada** — Cores do conteúdo/marca, não de template (21 paletas disponíveis)
3. **Tipografia com personalidade** — Combo serif + sans-serif (10 combos disponíveis)
4. **MagicUI components** — 150+ componentes animados quando relevante
5. **Motion Primitives** — Scroll reveal, stagger, hover lift, parallax
6. **Hierarquia visual** — O olho sabe para onde ir primeiro
7. **Responsivo** — Mobile-first (Tailwind `sm:` → `md:` → `lg:`)

### Fase 4: OUTPUT — Salvar Resultado

#### Se projeto React/Next.js detectado:
```
Salvar em: src/components/<ComponentName>.tsx
  - Componente TSX real com props tipadas
  - Imports do design system do projeto (shadcn, Radix)
  - MagicUI como CSS puro inline (sem dependência extra)
  - Responsive, acessível (WCAG AA)
```

#### Se nenhum projeto (HTML standalone):
```
Salvar em: output/<descritivo>.html
  - HTML completo com Tailwind CDN
  - Google Fonts via CDN
  - Animações em CSS/JS puro
  - Abre direto no browser
```

### Fase 5: VERIFY — Preview e Refinamento

```
1. Se dev server disponível → abrir no browser, fazer screenshot
2. Se HTML standalone → abrir arquivo direto
3. Mostrar preview ao usuário
4. Se feedback → refinar (loop até aprovação)
5. Se reference mode → comparar com original (visual-verdict)
```

---

## Progressive Disclosure

| Complexidade | Comportamento |
|-------------|---------------|
| **Simples** | "Cria um card de pricing" → Gerar direto, 1 componente, sem reference mode |
| **Médio** | "Cria uma landing page para SaaS de IA" → Múltiplas seções, paleta + tipografia, MagicUI |
| **Complexo** | "Clona o visual do Stripe.com e adapta para nosso produto" → Reference mode + geração + verificação visual |

---

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Precisa virar artifact claude.ai | `web-artifacts-builder` | Bundle React → HTML único |
| Precisa de gráficos de dados | `data-charts` | Charts interativos |
| Precisa testar E2E | `webapp-testing` | Playwright/browser verification |
| Precisa de slides | `frontend-slides` | Apresentação animada |
| Design já existe no Figma | Figma MCP | `get_design_context` direto |
| Precisa gerar PDF da UI | `minimax-pdf` | Export visual |

---

## Gotchas

⚠️ Consulte `gotchas.md` para lista completa. Principais:

1. **browser-use pode falhar em SPAs pesados** → Usar `wait --visible` antes de screenshot
2. **Tailwind CDN não suporta customização** → Para custom config, usar projeto com build
3. **MagicUI é React-only** → Em HTML standalone, reimplementar efeitos em CSS/JS puro (exemplos em `frontend-design`)
4. **Screenshots grandes** → Quebram cache do Claude. Fazer 3-4 ajustes antes de capturar

---

## Referências

- `frontend-design` skill — Catálogo MagicUI, paletas, tipografia, anti-patterns
- `web-artifacts-builder` skill — Bundle para artifacts
- `browser-use` MCP — Automação web para reference mode
- AIDesigner.ai — Referência do que superar ($25/mês, 100 créditos, HTML estático)
