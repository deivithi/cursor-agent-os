---
name: context-engineering
description: >
  Orquestração inteligente de múltiplas fontes de contexto (RAG, memória, tools, web)
  com token budget, hierarquia de fontes, evaluator e synthesizer.
  Keywords: context engineering, multi-source, context assembly, token budget, context window.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, Agent
metadata:
  author: deivithi
  version: "1.0"
  source: "patchy631/ai-engineering-hub (context-engineering-pipeline + context-engineering-workflow)"
---

# Context Engineering — Orquestração Multi-Fonte de Contexto

Pipeline estruturado para montar contexto inteligente a partir de múltiplas fontes (RAG, memória, tools, web), com budget de tokens, avaliação de relevância e síntese coerente. Inspirado no conceito de Context Engineering — o foco não é no modelo, mas no **contexto que chega ao modelo**.

## Quando Usar

- Perguntas que exigem cruzamento de múltiplas fontes (docs + memória + web)
- Agentes que precisam decidir **quais fontes consultar** para cada query
- Pipelines onde o contexto total excede o token window e precisa de sumarização
- Qualquer cenário onde "jogar tudo no prompt" não funciona — precisa de curadoria

## Quando NÃO Usar (→ Handoff)

- Query simples resolvível com uma única fonte → usar `gbrain` ou `web-research` diretamente
- Pesquisa profunda iterativa com budget de passos → usar `deep-research-workspace`
- Apenas memória conversacional → usar Memory MCP diretamente

## Workflow

### Fase 1 — Classificação da Query

```
Query do usuário
    ↓
Classificar: quais fontes são relevantes?
    □ RAG (documentos indexados)
    □ Memória (histórico, preferências, fatos)
    □ Web Search (informação recente/externa)
    □ Tools/APIs (dados estruturados, cálculos)
    □ Knowledge Graph (relações entre entidades)
```

**Regra:** Não ativar TODAS as fontes para TODA query. Routing inteligente economiza tokens.

### Fase 2 — Coleta Paralela de Contexto

Executar **em paralelo** os agentes das fontes selecionadas:

```
┌─────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  RAG Agent   │  │ Memory Agent │  │  Web Agent   │  │  Tool Agent  │
│ (docs/chunks)│  │ (histórico)  │  │ (busca web)  │  │ (APIs/MCP)   │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │                 │
       └────────────┬────┴────────────┬────┘                 │
                    │                 │                       │
                    ▼                 ▼                       ▼
              ┌──────────────────────────────────────────────────┐
              │            Context Collection Pool               │
              └──────────────────────┬───────────────────────────┘
                                     ▼
```

**Implementação no Claude Code:**
```
Agent(subagent_type="Explore", prompt="RAG: buscar em GBrain/docs...")  ← paralelo
Agent(subagent_type="Explore", prompt="Memory: buscar em KG/Memory...")  ← paralelo
WebSearch(query="...")                                                    ← paralelo
```

### Fase 3 — Avaliação de Relevância (Evaluator)

Antes de sintetizar, **filtrar e rankear** o contexto coletado:

```
Para cada chunk/resultado:
    1. Relevância (0-1): quão diretamente responde à query?
    2. Freshness: informação recente > antiga
    3. Source Authority: docs oficiais > web genérica > memória antiga
    4. Redundância: remover chunks que dizem a mesma coisa

Descartar: relevância < 0.3
Sumarizar: chunks muito longos mas relevantes
Manter íntegro: chunks de alta relevância (> 0.7)
```

**Hierarquia de fontes (padrão):**
1. 🥇 Tool outputs (dados estruturados, cálculos) — mais confiáveis
2. 🥈 RAG (documentos indexados) — verificáveis com citação
3. 🥉 Web search (informação recente) — útil mas menos controlável
4. 🏅 Memória (histórico/preferências) — contextualiza mas pode estar desatualizada

### Fase 4 — Token Budget Management

```
TOKEN_BUDGET = context_window - system_prompt - expected_output - safety_margin

Distribuição sugerida:
    - System prompt + instructions: ~15%
    - Context assembly: ~60%
    - Expected output: ~20%
    - Safety margin: ~5%

SE total_context > budget:
    1. Remover chunks de menor relevância
    2. Sumarizar chunks médios (0.3-0.6 relevância)
    3. Manter íntegros chunks altos (> 0.7)
    4. SE ainda > budget: sumarizar TUDO em briefing condensado
```

### Fase 5 — Síntese (Synthesizer)

Gerar resposta final com:

```
Context Assembly:
    [SOURCE: RAG] chunk_1 (relevância: 0.9)
    [SOURCE: Web] chunk_2 (relevância: 0.8)
    [SOURCE: Memory] user_preference_1
    [SOURCE: Tool] calculation_result

Instructions para Synthesizer:
    1. Priorizar fontes pela hierarquia definida
    2. Citar fonte de cada afirmação: [RAG: doc.pdf p.12], [Web: url]
    3. Se fontes conflitam: reportar conflito, não escolher silenciosamente
    4. Se contexto insuficiente: declarar explicitamente o que falta
    5. Confidence score (0-1) na resposta final
```

## Progressive Disclosure

| Complexidade | Comportamento |
|-------------|---------------|
| **Simples** | 1-2 fontes, sem budget management, síntese direta |
| **Médio** | 3+ fontes paralelas, evaluator filtra, citações |
| **Complexo** | Todas as fontes, token budget ativo, sumarização, conflito entre fontes reportado |

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Query precisa de pesquisa iterativa profunda | `deep-research-workspace` | Budget > 5 passos de pesquisa |
| Query é sobre relações entre entidades do código | `graphify` | Dependências, impacto de mudança |
| Query precisa de retrieval puro sem orquestração | `gbrain` | Busca simples em knowledge base |
| Resposta precisa de verificação factual | `corrective-rag` | Auto-correção + web fallback |

## Gotchas

1. **Over-fetching mata performance** → Classificar query ANTES de ativar fontes. Não ativar 5 fontes para "qual o horário?"
2. **Memória desatualizada** → Sempre verificar freshness. Memória de 30 dias atrás pode conflitar com docs atuais
3. **Token budget ignorado** → Se não calcular budget, o contexto estoura silenciosamente e o modelo trunca. Sempre calcular
4. **Hierarquia de fontes não é absoluta** → Para queries sobre preferências do usuário, memória > RAG. Adaptar por tipo de query

## Referências

- `patchy631/ai-engineering-hub/context-engineering-pipeline` — Pixeltable + Pixelagent (token budget + memory management)
- `patchy631/ai-engineering-hub/context-engineering-workflow` — CrewAI Flow (6 agents paralelos: RAG + Memory + Web + Tool + Evaluator + Synthesizer)
- Conceito: Context Engineering > Prompt Engineering — o diferencial está no contexto, não no prompt
