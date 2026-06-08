# ⚠️ Gotchas — Frontend Design

> Problemas conhecidos. Consulte quando algo falhar.

---

## Tailwind CDN: classes custom não funcionam

- **Sintoma:** Classes Tailwind como `bg-[#1a3a5c]` ou `grid-cols-[1fr_2fr]` não aplicam
- **Causa raiz:** CDN do Tailwind não processa JIT classes arbitrárias por padrão
- **Solução:** Adicionar `<script>tailwind.config = { theme: { extend: {} } }</script>` antes do conteúdo, ou usar inline styles para cores custom
- **Descoberto em:** 2026-03-23

---

## Google Fonts: FOUT (Flash of Unstyled Text)

- **Sintoma:** Texto aparece com fonte padrão por ~500ms antes da fonte custom carregar
- **Causa raiz:** Google Fonts carrega assincronamente
- **Solução:** Adicionar `font-display: swap` (já incluído no link padrão) e `<link rel="preconnect" href="https://fonts.googleapis.com">`
- **Descoberto em:** 2026-03-23

---

## Animação CSS pesada em mobile

- **Sintoma:** Jank/stuttering em scroll reveal ou parallax em mobile
- **Causa raiz:** `transform` + `opacity` são composited, mas muitos elementos simultâneos overload GPU mobile
- **Solução:** Usar `will-change: transform` apenas nos elementos animados, limitar stagger a max 6 children, usar `@media (prefers-reduced-motion)` como fallback
- **Descoberto em:** 2026-03-23

---

## IntersectionObserver: elementos já visíveis no load

- **Sintoma:** Elementos que já estão no viewport ao carregar não animam
- **Causa raiz:** Observer só dispara na transição de "fora" para "dentro" do viewport
- **Solução:** Adicionar check inicial: `if (entry.isIntersecting) entry.target.classList.add('visible')`
- **Descoberto em:** 2026-03-23

---

<!--
INSTRUÇÕES PARA MANUTENÇÃO:
1. Adicione novos gotchas NO TOPO
2. Use o formato acima
3. Se resolvido, mova para ## Resolvidos
-->
