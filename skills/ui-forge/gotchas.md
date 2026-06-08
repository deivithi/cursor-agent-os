# UI Forge — Gotchas

## 1. browser-use em SPAs (React/Vue/Angular)
**Problema:** Screenshot captura tela em branco porque SPA ainda não renderizou.
**Solução:** Usar `browser-use wait --visible 1 --timeout 5000` antes de screenshot.

## 2. Tailwind CDN vs Build
**Problema:** `cdn.tailwindcss.com` não suporta `tailwind.config.js` customizado (cores custom, plugins).
**Solução:** Se projeto tem tailwind.config → gerar componente TSX (não HTML standalone). Se HTML standalone → usar apenas classes padrão do Tailwind + custom CSS inline.

## 3. MagicUI em HTML standalone
**Problema:** MagicUI é biblioteca React. Não funciona em HTML puro.
**Solução:** Reimplementar efeitos em CSS/JS puro. A skill `frontend-design` tem exemplos prontos (Shimmer Button, Gradient Text, Number Ticker, Marquee, Scroll Reveal).

## 4. Screenshots quebram cache do Claude
**Problema:** Cada screenshot invalida o prompt cache (12.5x mais caro).
**Solução:** Fazer 3-4 ajustes de código antes de tirar screenshot de validação. Não tirar screenshot a cada micro-mudança.

## 5. Clone mode e conteúdo dinâmico
**Problema:** Sites com conteúdo carregado via JS (infinite scroll, lazy load) podem não ser capturados completamente.
**Solução:** Scroll até o conteúdo desejado antes de capturar. Usar `browser-use scroll --y 2000` + `wait`.

## 6. CORS em fontes Google Fonts
**Problema:** Algumas fontes não carregam em `file://` (HTML aberto local).
**Solução:** Usar `python -m http.server 3000` ou dev server para preview. Ou incluir fonts como base64 inline (último recurso).

## 7. Acessibilidade esquecida
**Problema:** Geração focada em visual pode ignorar a11y.
**Solução:** Sempre incluir: `alt` em imagens, contraste WCAG AA, `aria-label` em botões icon-only, landmarks semânticos (`main`, `nav`, `footer`).
