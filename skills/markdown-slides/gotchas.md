# ⚠️ Gotchas — Markdown Slides (Marp)

> Problemas conhecidos. Consulte quando algo falhar.

---

## `marp: true` ausente no front-matter

- **Sintoma:** Markdown renderiza como documento normal, sem separação de slides
- **Causa raiz:** Marp ignora arquivos sem a directive `marp: true`
- **Solução:** Sempre incluir `marp: true` no YAML front-matter
- **Descoberto em:** 2026-03-23

---

## PDF: fontes custom não embarcadas

- **Sintoma:** PDF mostra fonte fallback em vez da fonte definida no tema
- **Causa raiz:** Marp CLI usa Chromium interno que pode não ter a fonte instalada
- **Solução:** Usar `@import url('https://fonts.googleapis.com/css2?family=Inter')` no CSS do tema, ou usar fontes system-safe
- **Descoberto em:** 2026-03-23

---

## PPTX: estilos CSS perdidos

- **Sintoma:** Slides no PowerPoint não mantêm toda a formatação CSS
- **Causa raiz:** Conversão PPTX do Marp tem limitações — CSS complexo não é totalmente convertido
- **Solução:** Para PPTX com formatação perfeita, usar skill `pptx-generator`. Marp PPTX é melhor para rascunhos editáveis
- **Descoberto em:** 2026-03-23

---

## Separador de slides: `---` conflita com front-matter

- **Sintoma:** Primeiro slide desaparece ou front-matter aparece como conteúdo
- **Causa raiz:** O primeiro `---` fecha o front-matter YAML; o segundo `---` inicia o segundo slide
- **Solução:** Sempre ter conteúdo entre o front-matter e o primeiro `---` separador de slide
- **Descoberto em:** 2026-03-23

---

<!--
INSTRUÇÕES PARA MANUTENÇÃO:
1. Adicione novos gotchas NO TOPO
2. Use o formato acima
3. Se resolvido, mova para ## Resolvidos
-->
