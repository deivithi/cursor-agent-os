---
name: frontend-design
description: >
  Cria interfaces web production-grade com alto design. Inclui catálogo de componentes
  animados MagicUI (150+) e Motion Primitives. Anti-AI-slop: sem estética genérica.
  HTML standalone, React/Tailwind, landing pages, dashboards, componentes.
domain: frontend
subdomain: design
version: 2.0.0
author: deivithi
sources:
  - magicuidesign/magicui (21K⭐)
  - ibelick/motion-primitives (5K⭐)
tags:
  - frontend
  - design
  - UI
  - animation
  - MagicUI
  - motion
  - landing-page
  - dashboard
  - React
  - Tailwind
---

# 🎨 Frontend Design — UI Production-Grade Anti-AI-Slop

> **"Se parece que foi feito por IA, não está bom o suficiente."**
> Interfaces web com identidade visual forte, animações profissionais e design que impressiona.

## 📁 File Structure
- `SKILL.md` — Você está aqui. Referência + catálogo de componentes animados.
- `gotchas.md` — ⚠️ Problemas conhecidos.

## 🔗 Related Skills
- `landing-page-generator` — Landing pages high-converting com CRO (PAS, AIDA, BAB)
- `data-charts` — Gráficos interativos para embarcamento em dashboards
- `mermaid-diagrams` — Diagramas para documentação embarcada em UIs
- `markdown-slides` — Apresentações; para slides HTML animation-rich use `frontend-slides`

---

## 1. Princípios de Design Anti-AI-Slop

### O que evitar (sinais de "feito por IA")
- Gradientes roxo-azul genéricos
- Emojis como decoração principal
- Cards brancos com sombra leve e border-radius 16px sem variação
- Hero com "Welcome to..." e botão azul
- Grid perfeita sem hierarquia visual
- Cores saturadas demais ou paletas sem relação com o conteúdo

### O que buscar
- **Hierarquia clara:** O olho sabe para onde ir primeiro
- **Respiração:** Espaço negativo intencional (não "vazio")
- **Tipografia com personalidade:** Não use só Inter — explore serif + sans-serif combos
- **Cores derivadas do conteúdo:** A paleta vem do tema, não de um template
- **Micro-interações:** Hover, scroll, entrance — feedback visual sutil
- **Assimetria controlada:** Layouts que não são grid perfeita

---

## 2. Stack Técnica

### HTML Standalone (sem build)
Para outputs rápidos que abrem direto no browser:
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{TITLE}}</title>
  <!-- Tailwind CDN -->
  <script src="https://cdn.tailwindcss.com"></script>
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
  <style>
    /* Custom CSS aqui */
  </style>
</head>
<body>
  <!-- Conteúdo -->
</body>
</html>
```

### React + Tailwind (com build)
Para componentes em projetos existentes:
```bash
npx create-next-app@latest my-app --tailwind --typescript
cd my-app
npx shadcn@latest init
npx magicui@latest init
```

---

## 3. Catálogo MagicUI — Componentes Animados

> **Fonte:** [magicui.design](https://magicui.design) — 150+ componentes, MIT, React + Tailwind + Motion

### 🔥 Top 20 Componentes (mais impactantes para UIs)

#### Text & Typography
| Componente | O que faz | Quando usar |
|------------|-----------|-------------|
| **Animated Gradient Text** | Texto com gradiente animado | Headlines, CTAs |
| **Animated Shiny Text** | Brilho que percorre o texto | Badges, labels premium |
| **Aurora Text** | Efeito aurora boreal no texto | Hero sections |
| **Sparkles Text** | Faíscas ao redor do texto | Destaque de preço, CTA |
| **Typing Animation** | Efeito de digitação | Demos, chatbots |
| **Text Reveal** | Texto aparece progressivamente | Scroll sections |
| **Morphing Text** | Transição entre palavras | Headlines dinâmicas |
| **Word Rotate** | Rotação entre palavras | Hero "We build {X}" |
| **Number Ticker** | Contagem animada de números | Métricas, KPIs, stats |

#### Layouts & Containers
| Componente | O que faz | Quando usar |
|------------|-----------|-------------|
| **Bento Grid** | Layout bento estilo Apple | Feature showcase |
| **Magic Card** | Card com efeito de luz acompanhando mouse | Product cards |
| **Neon Gradient Card** | Card com borda neon animada | Pricing destaque |
| **Dock** | Dock estilo macOS | Navigation, app bar |

#### Buttons & Interactions
| Componente | O que faz | Quando usar |
|------------|-----------|-------------|
| **Shimmer Button** | Botão com shimmer na borda | CTA principal |
| **Pulsating Button** | Botão que pulsa | CTA urgente |
| **Rainbow Button** | Botão com rainbow border | CTA premium |
| **Interactive Hover Button** | Efeito hover sofisticado | Nav buttons |

#### Backgrounds & Effects
| Componente | O que faz | Quando usar |
|------------|-----------|-------------|
| **Particles** | Partículas flutuantes | Hero background |
| **Globe** | Globo 3D interativo | SaaS, startups globais |
| **Animated Grid Pattern** | Grid animada de fundo | Tech, developer tools |
| **Meteors** | Meteoros caindo | Background dramático |
| **Confetti** | Confete animado | Success states |
| **Marquee** | Scroll horizontal infinito | Logos de clientes, testimonials |
| **Border Beam** | Feixe de luz na borda | Cards, destaque |
| **Ripple** | Efeito ripple de água | Backgrounds |

### Implementação (HTML standalone com CDN)

Para usar MagicUI sem React/build, implementar os efeitos em CSS/JS puro:

```html
<!-- Shimmer Button (CSS puro) -->
<style>
  .shimmer-btn {
    position: relative;
    padding: 12px 32px;
    background: #1a1a2e;
    color: white;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    overflow: hidden;
  }
  .shimmer-btn::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: linear-gradient(
      90deg,
      transparent,
      rgba(255,255,255,0.1),
      transparent
    );
    animation: shimmer 2s infinite;
  }
  @keyframes shimmer {
    0% { transform: translateX(-100%); }
    100% { transform: translateX(100%); }
  }
</style>
<button class="shimmer-btn">Get Started</button>
```

```html
<!-- Animated Gradient Text (CSS puro) -->
<style>
  .gradient-text {
    background: linear-gradient(90deg, #4e79a7, #e15759, #76b7b2, #4e79a7);
    background-size: 300% 100%;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    animation: gradient-shift 4s ease infinite;
    font-size: 3rem;
    font-weight: 700;
  }
  @keyframes gradient-shift {
    0%, 100% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
  }
</style>
<h1 class="gradient-text">Welcome to the Future</h1>
```

```html
<!-- Number Ticker (JS) -->
<style>
  .ticker { font-size: 3rem; font-weight: 700; font-variant-numeric: tabular-nums; }
</style>
<span class="ticker" data-target="1450">0</span>
<script>
  document.querySelectorAll('.ticker').forEach(el => {
    const target = parseInt(el.dataset.target);
    const duration = 2000;
    const start = performance.now();
    const tick = (now) => {
      const progress = Math.min((now - start) / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      el.textContent = Math.floor(target * eased).toLocaleString('pt-BR');
      if (progress < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  });
</script>
```

```html
<!-- Marquee (CSS puro) -->
<style>
  .marquee { overflow: hidden; white-space: nowrap; }
  .marquee-content {
    display: inline-flex;
    gap: 3rem;
    animation: marquee 20s linear infinite;
  }
  @keyframes marquee {
    0% { transform: translateX(0); }
    100% { transform: translateX(-50%); }
  }
</style>
<div class="marquee">
  <div class="marquee-content">
    <span>Google</span><span>Apple</span><span>Meta</span><span>Amazon</span>
    <!-- Duplicar para loop contínuo -->
    <span>Google</span><span>Apple</span><span>Meta</span><span>Amazon</span>
  </div>
</div>
```

---

## 4. Motion Primitives — Patterns de Animação

> **Fonte:** [motion-primitives.com](https://motion-primitives.com) — Framer Motion + Tailwind

### Patterns Essenciais

| Pattern | CSS/JS | Quando usar |
|---------|--------|-------------|
| **Fade In Up** | `opacity: 0 → 1` + `translateY: 20px → 0` | Entrance de seções |
| **Scale In** | `scale: 0.95 → 1` + `opacity: 0 → 1` | Cards, modais |
| **Slide In** | `translateX: -100% → 0` | Sidebars, drawers |
| **Stagger** | Delay incremental entre children | Lists, grids |
| **Hover Lift** | `translateY: -4px` + `shadow: larger` | Cards interativos |
| **Scroll Reveal** | IntersectionObserver + fade | Qualquer seção |
| **Parallax** | `translateY: scroll * factor` | Hero backgrounds |

### Implementação CSS/JS Pura

```html
<!-- Scroll Reveal (IntersectionObserver) -->
<style>
  .reveal {
    opacity: 0;
    transform: translateY(30px);
    transition: opacity 0.6s ease, transform 0.6s ease;
  }
  .reveal.visible {
    opacity: 1;
    transform: translateY(0);
  }
</style>
<script>
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  }, { threshold: 0.1 });
  document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
</script>
```

```html
<!-- Stagger Children -->
<style>
  .stagger > * {
    opacity: 0;
    transform: translateY(20px);
    transition: opacity 0.5s ease, transform 0.5s ease;
  }
  .stagger.visible > *:nth-child(1) { transition-delay: 0.1s; }
  .stagger.visible > *:nth-child(2) { transition-delay: 0.2s; }
  .stagger.visible > *:nth-child(3) { transition-delay: 0.3s; }
  .stagger.visible > *:nth-child(4) { transition-delay: 0.4s; }
  .stagger.visible > * { opacity: 1; transform: translateY(0); }
</style>
```

```html
<!-- Hover Lift Card -->
<style>
  .lift-card {
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    cursor: pointer;
  }
  .lift-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 24px rgba(0,0,0,0.12);
  }
</style>
```

---

## 5. Paletas de Cores

### 21 Paletas Profissionais

| # | Nome | Primary | Secondary | Accent | Background | Quando usar |
|---|------|---------|-----------|--------|------------|-------------|
| 1 | Midnight Navy | `#1a1a2e` | `#16213e` | `#0f3460` | `#0a0a0f` | SaaS, tech premium |
| 2 | Forest | `#1b4332` | `#2d6a4f` | `#40916c` | `#081c15` | Sustainability, nature |
| 3 | Warm Slate | `#334155` | `#475569` | `#f59e0b` | `#f8fafc` | Corporate, dashboards |
| 4 | Ocean | `#0c4a6e` | `#0369a1` | `#38bdf8` | `#f0f9ff` | Finance, SaaS |
| 5 | Rose | `#881337` | `#be123c` | `#fb7185` | `#fff1f2` | Beauty, lifestyle |
| 6 | Purple Haze | `#3b0764` | `#6b21a8` | `#c084fc` | `#faf5ff` | Creative, AI |
| 7 | Monochrome | `#09090b` | `#27272a` | `#a1a1aa` | `#fafafa` | Minimal, editorial |
| 8 | Terracotta | `#7c2d12` | `#c2410c` | `#fb923c` | `#fff7ed` | Food, craft |
| 9 | Teal | `#134e4a` | `#0d9488` | `#2dd4bf` | `#f0fdfa` | Health, wellness |
| 10 | Indigo | `#312e81` | `#4338ca` | `#818cf8` | `#eef2ff` | Developer tools |
| 11 | Emerald Dark | `#064e3b` | `#059669` | `#34d399` | `#0a0a0a` | Fintech dark |
| 12 | Amber | `#78350f` | `#d97706` | `#fbbf24` | `#fffbeb` | Marketplace |
| 13 | Steel | `#1e293b` | `#334155` | `#94a3b8` | `#f1f5f9` | Enterprise |
| 14 | Crimson | `#7f1d1d` | `#dc2626` | `#f87171` | `#fef2f2` | Urgency, sales |
| 15 | Sage | `#365314` | `#65a30d` | `#a3e635` | `#f7fee7` | Organic, eco |
| 16 | Cobalt | `#1e3a5f` | `#2563eb` | `#60a5fa` | `#eff6ff` | Trust, B2B |
| 17 | Charcoal Gold | `#1c1917` | `#44403c` | `#d4a373` | `#fafaf9` | Luxury |
| 18 | Electric | `#020617` | `#7c3aed` | `#a78bfa` | `#020617` | Gaming, neon |
| 19 | Blush | `#500724` | `#be185d` | `#f472b6` | `#fdf2f8` | Fashion |
| 20 | Graphite | `#171717` | `#404040` | `#737373` | `#fafafa` | Portfolio, minimal |
| 21 | Febracis | `#1a3a5c` | `#2d5f8a` | `#e74c3c` | `#f8f9fa` | Febracis branding |

---

## 6. Tipografia (combos serif + sans-serif)

| # | Combo | Heading | Body | Vibe |
|---|-------|---------|------|------|
| 1 | Classic | Playfair Display | Inter | Elegante, editorial |
| 2 | Modern | Space Grotesk | DM Sans | Tech, clean |
| 3 | Bold | Syne | Work Sans | Criativo, agency |
| 4 | Academic | EB Garamond | Source Sans 3 | Sério, research |
| 5 | Startup | Outfit | Inter | Amigável, SaaS |
| 6 | Luxury | Cormorant Garamond | Lato | Premium, high-end |
| 7 | Developer | JetBrains Mono | Inter | Tech, code-heavy |
| 8 | Impactful | Bebas Neue | Roboto | Poster, marketing |
| 9 | Minimal | DM Serif Display | DM Sans | Clean, portfolio |
| 10 | Warm | Fraunces | Nunito | Friendly, wellness |

### Google Fonts Import
```html
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
```

---

## 7. Workflow

```
1. ENTENDER o propósito (landing page, dashboard, componente, poster?)
2. ESCOLHER paleta (derivada do conteúdo, não genérica)
3. ESCOLHER tipografia (combo serif + sans-serif que match o mood)
4. DEFINIR layout (assimétrico > grid perfeita quando possível)
5. ADICIONAR micro-interações (scroll reveal, hover lift, stagger)
6. ADICIONAR componentes animados (MagicUI patterns, se relevante)
7. GERAR HTML standalone em output/
8. VALIDAR: abre no browser? Responsivo? Visual coerente?
```

### Convenções de Output
- **Arquivo:** `output/{descritivo}.html`
- **Responsivo:** Sempre mobile-first (Tailwind `sm:` → `md:` → `lg:`)
- **Fontes:** Sempre via Google Fonts CDN
- **Animações:** CSS puro quando possível (sem dependências JS pesadas)
- **Acessibilidade:** `alt` em imagens, contraste mínimo WCAG AA, `aria-label` em botões icon-only

---

## 8. Anti-Patterns

| ❌ Evitar | ✅ Fazer |
|----------|---------|
| Gradiente roxo-azul genérico | Paleta derivada do conteúdo |
| `border-radius: 9999px` em tudo | Radius variado por hierarquia (4px/8px/12px/16px) |
| Animação em tudo simultaneamente | Stagger + scroll reveal seletivo |
| Hero com texto + botão + nada mais | Hero com visual forte (imagem, gradiente, tipografia bold) |
| Cards todos iguais | Bento grid com tamanhos variados |
| Sombras genéricas `shadow-lg` | Sombras customizadas com cor: `0 8px 24px rgba(26,58,92,0.12)` |
| Background branco liso | Texturas sutis: grid, dots, noise, gradient radial |
| Fonte única (Inter everywhere) | Combo serif heading + sans body |
