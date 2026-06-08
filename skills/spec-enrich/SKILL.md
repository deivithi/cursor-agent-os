---
name: spec-enrich
description: >
  Enriquece specs aprovadas com edge cases, contradições e gaps não cobertos.
  Contexto limpo obrigatório: lê spec + PRD sem histórico de conversa.
  Encontra contradições diretas, gaps na spec, gaps em ambos os documentos.
  Altera a spec diretamente e gera diff visível. Max 2 rodadas.
  Inspirado no Spec Enricher do LionLab (Breno Vieira).
  Palavras-chave: enriquecer spec, edge cases, contradições, gaps, spec enricher,
  completar spec, caminhos alternativos, estados de UI.
domain: spec-driven-development
subdomain: enrichment
version: 1.0.0
author: deivithi
tags:
  - spec-driven
  - enrichment
  - edge-cases
  - contradictions
  - gaps
  - clean-context
---

# 🔬 Spec Enrich — Enriquecimento com Contexto Limpo

> **"Esse cara ele é extremamente crítico. Ele fica fazendo perguntas que às vezes o agente que tá desenvolvendo a spec ou mesmo você não pensa."**
> — Breno, LionLab

> **Princípio:** Validador não modifica, Enricher não julga. Esta skill CRIA conteúdo novo (edge cases, contradições resolvidas). A qualidade já foi julgada por `spec-evaluate`.

## File Structure
- `SKILL.md` — Você está aqui. Protocolo completo.
- `gotchas.md` — Problemas conhecidos. Consulte quando algo falhar.

## Related Skills
- `spec-evaluate` — Gate pré-enrich (score >= 80 para chegar aqui)
- `spec-epic` — Gera o PRD e Brief que esta skill compara
- `spec-planner` — Gera a spec técnica que esta skill enriquece
- `spec-phases` — Consome a spec enriched para gerar sprints
- `spec-driven-core` — Orquestrador que roteia para cá após evaluate

---

## Insight Central

> **spec-evaluate ≠ spec-enrich.**
> - `spec-evaluate` = juiz. Pontua, aprova ou reprova. Não modifica.
> - `spec-enrich` = investigador. Encontra o que ninguém viu e corrige.
>
> **Por que contexto limpo?**
> O agente que gerou a spec já tem viés de confirmação — ele acha que cobriu tudo.
> Um agente novo, lendo apenas spec + PRD sem histórico, detecta contradições
> que o primeiro agente nunca veria.

---

## 1. Gatilhos de Ativação

Ativar **automaticamente** quando:

- `spec-evaluate` aprova spec com score >= 80 (passo seguinte no pipeline)
- `spec-driven-core` roteia para pipeline greenfield (fase 6)
- Usuário pede: "enriquecer spec", "encontrar gaps", "edge cases", "contradições"

**Não ativar** quando:
- Spec ainda não passou por `spec-evaluate` (enviar para evaluate primeiro)
- Bug fix pontual ou protótipo descartável
- Spec já passou por enrich nesta sessão (sem mudanças no PRD/spec)

---

## 2. Input (Contexto Limpo Obrigatório)

| Campo | Obrigatório | Fonte |
|-------|-------------|-------|
| **Spec técnica** | Sim | Output de `spec-planner` ou spec manual |
| **PRD completo** | Sim | Output de `spec-epic` Cmd 4.5 ou PRD manual |
| **User Stories** | Recomendado | Do Epic Brief (Cmd 2) |

**Regra inviolável:** Ler APENAS estes documentos. Não herdar histórico de conversa, não ler código, não ler chats anteriores. Contexto limpo = zero viés.

---

## 3. Workflow — 3 Steps

### Step 1: Análise Crítica

Ler spec + PRD com olhar cético. Organizar achados em 3 categorias:

#### Categoria A: Contradições Diretas
Spec diz X, PRD diz Y — qual é o correto?

```markdown
### Contradição [N]
- **Spec diz:** [trecho exato]
- **PRD diz:** [trecho exato]
- **Impacto:** [o que quebra se não resolver]
- **Sugestão:**
  - Opção A: [seguir spec — justificativa]
  - Opção B: [seguir PRD — justificativa]
  - Opção C: [solução alternativa — justificativa]
```

#### Categoria B: Gaps na Spec
Presente no PRD, ausente na Spec — esqueceram de especificar.

```markdown
### Gap [N]
- **No PRD:** [trecho exato que menciona a funcionalidade]
- **Na Spec:** [ausente / mencionado mas sem detalhe]
- **Impacto:** [o que o desenvolvedor vai inventar sem essa spec]
- **Sugestão:** [especificação concreta para adicionar]
```

#### Categoria C: Gaps em Ambos
Edge cases não cobertos por nenhum documento.

```markdown
### Edge Case [N]
- **Cenário:** [situação concreta — ex: "E se o usuário enviar formulário com campos vazios?"]
- **Comportamento esperado:** [o que deveria acontecer]
- **Onde adicionar:** [qual seção da spec]
- **Prioridade:** Must / Should / Could
```

**Regras da análise:**
- Mínimo 5 itens, máximo 40 (se menos de 5, a spec já está excelente)
- Priorizar: Contradições > Gaps na Spec > Gaps em ambos
- Para cada item: cenário CONCRETO, nunca genérico
  - Errado: "E se der erro?"
  - Certo: "E se o Stripe retornar erro 402 durante checkout?"

### Step 2: Apresentação + Conversa

Apresentar todos os achados organizados por categoria:

```markdown
# 🔬 Spec Enrich Report

## Spec: [título]
## Data: [DD/MM/YYYY HH:MM BRT]

## Resumo
Encontrados **[N]** itens que precisam de atenção:
- **[X]** contradições diretas entre Spec e PRD
- **[Y]** gaps na Spec (presente no PRD, ausente na Spec)
- **[Z]** gaps em ambos (edge cases não cobertos)

## Categoria A: Contradições Diretas
[itens...]

## Categoria B: Gaps na Spec
[itens...]

## Categoria C: Gaps em Ambos (Edge Cases)
[itens...]
```

**Conversa:**
- Para cada item com opções (A/B/C): aguardar decisão do usuário
- Para itens com sugestão única: apresentar e pedir confirmação
- Se o usuário concordar com tudo de uma vez: aceitar bulk approval
- **Max 2 rodadas** de conversa (evitar loop infinito)

### Step 3: Aplicar Mudanças + Diff

Após decisões do usuário:

1. **Alterar a spec diretamente** com as decisões tomadas
2. **Gerar diff visível:**

```markdown
## Spec Enrich — Changelog

### Contradições Resolvidas
| # | Decisão | Seção Alterada |
|---|---------|---------------|
| 1 | Seguir PRD (opção B) | Seção 3.2 — Auth |
| 2 | Solução alternativa | Seção 4.1 — Payments |

### Gaps Preenchidos
| # | Adição | Seção |
|---|--------|-------|
| 1 | Validação de e-mail no signup | Seção 2.1 — User Stories |
| 2 | Tratamento de erro Stripe 402 | Seção 5.3 — Payments |

### Edge Cases Adicionados
| # | Cenário | Seção |
|---|---------|-------|
| 1 | Formulário com campos vazios | Seção 2.3 — Forms |
```

3. **Output:** Spec enriched pronta para `spec-phases`

---

## 4. Regras

| Regra | Descrição |
|-------|-----------|
| **Contexto limpo** | Ler APENAS spec + PRD + user stories. Zero histórico. |
| **Não julgar qualidade** | spec-evaluate já fez isso. Focar em completude e coerência. |
| **Max 2 rodadas** | Se após 2 rodadas ainda há ambiguidade, registrar como "A definir pelo dev" e seguir. |
| **Cenários concretos** | Nunca perguntar "e se der erro?" — sempre "e se [situação específica]?" |
| **Diff obrigatório** | Toda mudança na spec deve ter registro do que mudou e por quê. |
| **Não expandir escopo** | Enriquecer ≠ adicionar features. Edge cases SIM, features novas NÃO. |

---

## 5. Integração com Pipeline

```
spec-epic (PRD) → spec-planner (Spec) → spec-evaluate (Gate >= 80)
                                              |
                                              v
                                    >>> spec-enrich <<< (VOCÊ ESTÁ AQUI)
                                              |
                                              v
                                    spec-phases (Sprints)
```

---

## 6. Progressive Disclosure

| Complexidade da Spec | Comportamento |
|---------------------|---------------|
| **Pequena** (< 50 linhas) | Análise inline, sem relatório formal |
| **Média** (50-300 linhas) | Relatório completo com 3 categorias |
| **Grande** (300+ linhas) | Relatório + sugerir divisão da análise por módulo |

---

## 7. Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Spec enriched pronta | `spec-phases` | Decomposição em sprints |
| Contradição não resolvível | `spec-epic` (Cmd 1-4) | Voltar para elicitação |
| Spec precisa de pesquisa técnica | `deep-research-workspace` | Domínio desconhecido |
| Enrich concluído + automação | `spec-yolo` | Pipeline completo autônomo |

---

## 8. Gotchas

1. **Falsos positivos em contradições** — Diferença de terminologia não é contradição (ex: "user" vs "usuário")
2. **Enriquecer demais** — 40+ itens sobrecarrega o usuário. Priorizar os mais críticos
3. **Inventar features** — Edge case ≠ feature nova. "E se tivesse dark mode?" NÃO é edge case
4. **Contexto contaminado** — Se o agente leu o chat anterior, o enrich perde valor. SEMPRE contexto limpo
5. **Spec sem PRD** — Se não há PRD para comparar, só Categoria C (edge cases) é possível
