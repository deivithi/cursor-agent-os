---
name: corrective-rag
description: >
  RAG com auto-correção: relevance grading, web fallback, self-correction loop
  e citation enforcement. Overlay para qualquer pipeline RAG existente.
  Keywords: corrective rag, CRAG, self-correcting, relevance check, web fallback, citations, hallucination.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, Agent
metadata:
  author: deivithi
  version: "1.0"
  source: "patchy631/ai-engineering-hub (corrective-rag, trustworthy-rag, firecrawl-agent)"
---

# Corrective RAG — RAG com Auto-Correção

Pipeline RAG que adiciona camadas de verificação e correção automática: relevance grading dos chunks, web fallback quando contexto é insuficiente, self-correction loop contra alucinações, e citation enforcement obrigatório. Funciona como **overlay** sobre qualquer RAG existente (GBrain, Supabase, Milvus).

## Quando Usar

- RAG que precisa de respostas verificáveis com citações
- Queries onde retrieval pode retornar chunks irrelevantes (ruído no índice)
- Cenários onde alucinação é inaceitável (compliance, auditoria, Febracis)
- Quando a knowledge base pode estar incompleta e precisa de web fallback

## Quando NÃO Usar (→ Handoff)

- Retrieval simples sem necessidade de verificação → usar `gbrain` direto
- Pesquisa multi-fonte com orquestração completa → usar `context-engineering`
- Apenas busca na web sem RAG → usar `web-research`

## Workflow

### Fase 1 — Retrieval (padrão)

```
Query → Embedding → Vector Search → Top-K chunks
```

Nada muda aqui. Use o retriever que já tem (GBrain, Supabase pgvector, Milvus).

### Fase 2 — Relevance Grading ⭐

**Este é o diferencial.** Antes de gerar, classificar CADA chunk:

```
Para cada chunk retornado:
    Pergunta: "Este chunk contém informação relevante para responder: '{query}'?"

    Classificação:
    ┌─────────────┬─────────────────────────────────────────────────┐
    │ RELEVANT    │ Chunk responde diretamente à query              │
    │ PARTIAL     │ Chunk tem informação útil mas incompleta        │
    │ IRRELEVANT  │ Chunk não ajuda a responder                     │
    └─────────────┴─────────────────────────────────────────────────┘

    Score de confiança do retrieval:
    - Se >70% chunks RELEVANT → ✅ Contexto suficiente → Fase 4
    - Se 30-70% RELEVANT → ⚠️ Contexto parcial → Fase 3 (web fallback)
    - Se <30% RELEVANT → 🚨 Contexto insuficiente → Fase 3 obrigatório
```

**Implementação prática (Claude Code):**
```
Prompt para grading: "Avalie se o seguinte trecho responde à pergunta '{query}'.
Responda APENAS: RELEVANT, PARTIAL ou IRRELEVANT.
Trecho: {chunk}"
```

### Fase 3 — Web Fallback (condicional)

Ativado quando contexto do RAG é insuficiente:

```
SE contexto_insuficiente:
    1. Reformular query para busca web
    2. WebSearch(query_reformulada)
    3. Filtrar resultados web com mesmo relevance grading
    4. Combinar: chunks_relevantes_RAG + resultados_web_relevantes
    5. Re-rankear por relevância combinada
```

**Regra:** Web fallback é COMPLEMENTO, não substituição. Chunks RAG relevantes sempre têm prioridade sobre resultados web.

### Fase 4 — Geração com Citation Enforcement

```
Instruções para geração:
    1. TODA afirmação factual DEVE ter citação: [Fonte: nome_doc, p.X] ou [Web: URL]
    2. Se não há fonte para uma afirmação → NÃO incluir na resposta
    3. Se fontes conflitam → reportar: "Fonte A diz X, Fonte B diz Y"
    4. Se query não pode ser respondida com o contexto → declarar explicitamente

Formato de citação:
    - RAG: [📄 documento.pdf, p.12]
    - Web: [🌐 dominio.com/artigo]
    - Memória: [🧠 sessão anterior, DD/MM/YYYY]
```

### Fase 5 — Self-Correction Loop ⭐

Após gerar, verificar a resposta:

```
Verification Checklist:
    □ Toda afirmação tem citação? (citation coverage)
    □ Citações apontam para chunks reais? (citation accuracy)
    □ Resposta não contém informação ausente nos chunks? (faithfulness)
    □ Resposta é completa em relação à query? (completeness)

SE algum check falha:
    → Identificar trecho problemático
    → Re-gerar APENAS o trecho com contexto corrigido
    → Max 2 iterações de correção (adaptive-depth: I(t) < 0.05 → EXIT)
```

## Progressive Disclosure

| Complexidade | Comportamento |
|-------------|---------------|
| **Simples** | Retrieval + relevance grading + geração com citações. Sem web fallback, sem self-correction |
| **Médio** | + Web fallback quando contexto <70%. + Citation enforcement strict |
| **Complexo** | + Self-correction loop (max 2 iterações). + Conflito entre fontes reportado. + Confidence score |

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Precisa de múltiplas fontes orquestradas | `context-engineering` | Query multi-fonte |
| Knowledge base precisa ser alimentada | `gbrain` | Ingestão de documentos |
| Resposta precisa de pesquisa profunda | `deep-research-workspace` | Web fallback insuficiente |
| Issues de segurança na resposta | `guardrails` | Output validation |

## Gotchas

1. **Relevance grading consome tokens** → Para queries triviais, skip grading. Usar apenas quando accuracy importa
2. **Web fallback pode trazer ruído** → Sempre aplicar relevance grading nos resultados web também
3. **Self-correction loop infinito** → Max 2 iterações. Se não corrigiu em 2, reportar e parar (adaptive-depth)
4. **Citation enforcement muito rígido** → Para perguntas de opinião/análise, permitir síntese sem citação por trecho, mas com citações gerais
5. **Não substituir GBrain** → Este é um overlay. O retrieval continua sendo do GBrain/Supabase. Corrective RAG adiciona verificação em cima

## Referências

- `patchy631/ai-engineering-hub/corrective-rag` — CRAG pattern (LangGraph)
- `patchy631/ai-engineering-hub/trustworthy-rag` — RAG over complex documents com citações
- `patchy631/ai-engineering-hub/firecrawl-agent` — Corrective RAG com web search fallback
- Paper: "Corrective Retrieval Augmented Generation" (Yan et al., 2024) — CRAG framework original
