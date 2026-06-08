# ⚠️ Gotchas — Mermaid Diagrams

> Problemas conhecidos encontrados durante o uso desta skill. Construído iterativamente a partir de falhas reais.
> **Consulte este arquivo quando algo falhar ou produzir resultado inesperado.**

---

## rgba() em classDef quebra o parser Mermaid

- **Sintoma:** "Syntax error in text" ao usar `classDef` com `fill:rgba(8,51,68,0.4)`
- **Causa raiz:** Mermaid usa vírgula como separador de propriedades no `classDef`. As vírgulas dentro de `rgba()` conflitam e o parser interpreta incorretamente
- **Solução:** Usar cores hex sólidas em vez de rgba. Ex: `fill:#083344` em vez de `fill:rgba(8,51,68,0.4)`
- **Prevenção:** Nunca usar `rgba()`, `rgb()`, `hsl()` em `classDef`. Sempre hex
- **Descoberto em:** 2026-04-14

---

## Indentação dentro de pre.mermaid causa syntax error

- **Sintoma:** "Syntax error in text" mesmo com código Mermaid correto
- **Causa raiz:** O `<pre>` preserva whitespace literalmente. Se estiver indentado dentro do HTML (ex: 6 espaços), o Mermaid recebe esses espaços como parte do código e não consegue parsear
- **Solução:** O conteúdo do `<pre class="mermaid">` deve começar na coluna 0 (flush-left), mesmo que quebre a indentação do HTML
- **Prevenção:** No template dark (Seção 7 do SKILL.md), o `<pre>` já está posicionado na coluna 0
- **Descoberto em:** 2026-04-14

---

## Caracteres especiais quebram a renderização

- **Sintoma:** Diagrama não renderiza ou mostra erro de parser
- **Causa raiz:** Parênteses, chaves, colchetes, aspas dentro de labels de nós conflitam com a sintaxe Mermaid
- **Solução:** Envolver labels com aspas duplas: `A["Texto com (parênteses)"]`
- **Prevenção:** Sempre usar aspas em labels que contenham caracteres especiais
- **Descoberto em:** 2026-03-23

---

## Mermaid CDN bloqueado por CSP

- **Sintoma:** Diagrama não aparece em HTML servido por servidor com Content Security Policy
- **Causa raiz:** CSP bloqueia scripts de CDN externo (jsdelivr)
- **Solução:** Usar Mermaid CLI (`mmdc`) para gerar SVG estático, ou adicionar `cdn.jsdelivr.net` ao CSP
- **Prevenção:** Para outputs embarcados em sistemas com CSP, sempre gerar SVG estático
- **Descoberto em:** 2026-03-23

---

<!--
INSTRUÇÕES PARA MANUTENÇÃO:
1. Adicione novos gotchas NO TOPO (mais recentes primeiro)
2. Use o formato acima para consistência
3. Se um gotcha for resolvido permanentemente, mova para ## Resolvidos no final
4. Gotchas devem ser específicos e acionáveis — não genéricos
5. Inclua o sintoma exato para facilitar busca futura
-->
