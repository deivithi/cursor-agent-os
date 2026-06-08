# Frontend Grading Rubric

> Fonte: [Anthropic Engineering — Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) (2026-03-24)
> "The wording of the criteria steered the generator in ways I didn't fully anticipate."

## 4 Critérios Oficiais

### 1. Design Quality (30%)

**Pergunta central:** O design parece um todo coerente ou uma coleção de partes?

| Score | Descrição |
|-------|-----------|
| 9-10 | Identidade visual distinta. Mood e personalidade claros. Cada elemento contribui para a narrativa. |
| 7-8 | Coerente e agradável. Palette e tipografia consistentes. Falta personalidade marcante. |
| 5-6 | Funcional mas genérico. Templates reconhecíveis. Sem identidade própria. |
| 3-4 | Inconsistente. Estilos misturados. Elementos que não combinam entre si. |
| 1-2 | Caótico. Sem sistema visual. Parece montado às pressas. |

### 2. Originality (25%)

**Pergunta central:** Há evidência de decisões customizadas ou é tudo template?

| Score | Descrição |
|-------|-----------|
| 9-10 | Surpreendente. Abordagem inesperada que funciona. Nenhum template reconhecível. |
| 7-8 | Decisões originais em layout, interação ou estética. Poucos clichês. |
| 5-6 | Mistura de original e template. Algumas decisões próprias, mas estrutura previsível. |
| 3-4 | Claramente derivado de templates. Poucas decisões customizadas. |
| 1-2 | **AI Slop total.** Purple gradients, white cards, generic hero with stock text. |

**🚫 Anti-AI-Slop Checklist (penaliza -2 por item):**
- [ ] Purple/blue gradient backgrounds genéricos
- [ ] Cards brancos com sombra sobre fundo claro
- [ ] Hero section com "Welcome to [Product]" e CTA genérico
- [ ] Ícones de placeholder (emoji como ícone de feature)
- [ ] Tipografia padrão sem hierarquia intencional
- [ ] Layout three-column feature grid idêntico a todo SaaS template
- [ ] Glassmorphism sem propósito funcional

### 3. Craft (25%)

**Pergunta central:** A execução técnica demonstra competência visual?

| Score | Descrição |
|-------|-----------|
| 9-10 | Tipografia com ritmo e hierarquia impecáveis. Spacing consistente. Cores harmoniosas com contraste acessível. |
| 7-8 | Boa hierarquia. Spacing mostly consistente. Palette funcional. Minor issues. |
| 5-6 | Tipografia ok mas sem refinamento. Spacing irregular em alguns pontos. Cores funcionam mas não impressionam. |
| 3-4 | Hierarquia confusa. Spacing inconsistente. Cores que colidem ou são monótonas. |
| 1-2 | Sem hierarquia tipográfica. Spacing aleatório. Cores arbitrárias. |

**Checklist de Craft:**
- [ ] Contraste mínimo 4.5:1 (AA) em todo texto
- [ ] Máximo 2-3 fontes no design
- [ ] Spacing baseado em sistema (4px/8px grid)
- [ ] Hover/focus states em todos os interativos
- [ ] Responsivo (mobile → desktop)
- [ ] Loading states para conteúdo assíncrono

### 4. Functionality (20%)

**Pergunta central:** Usuários conseguem entender e usar a interface sem adivinhar?

| Score | Descrição |
|-------|-----------|
| 9-10 | Intuitivo. Ações primárias óbvias. Feedback imediato. Zero adivinhação. |
| 7-8 | Usável sem documentação. Hierarquia de ações clara. Feedback presente. |
| 5-6 | Funciona mas requer exploração. Algumas ações não são óbvias. |
| 3-4 | Confuso. Ações primárias difíceis de encontrar. Feedback ausente. |
| 1-2 | Inutilizável. Não é possível completar tarefas básicas. |

## Cálculo do Score Final

```
Score = (Design × 0.30) + (Originality × 0.25) + (Craft × 0.25) + (Functionality × 0.20)
```

| Score Final | Verdict |
|------------|---------|
| ≥ 8.0 | 🟢 **Excelente** — Ship it |
| 7.0-7.9 | 🟢 **Bom** — Minor polish needed |
| 5.0-6.9 | 🟡 **Aceitável** — Needs iteration |
| 3.0-4.9 | 🔴 **Insuficiente** — Major rework |
| < 3.0 | 🔴 **Rejeitar** — Start over |

## Cuidado com Wording

> "Including phrases like 'the best designs are museum quality' pushed designs toward a particular visual convergence."

O wording dos critérios **influencia diretamente** o output do Generator. Usar com intenção:
- "Museum quality" → empurra para elegância minimalista
- "Feels alive" → empurra para animação e interatividade
- "Spatial experience" → empurra para layouts 3D/imersivos
- "Editorial" → empurra para tipografia forte e grids editoriais

**Escolha o framing ANTES de iniciar o loop, de acordo com o projeto.**
