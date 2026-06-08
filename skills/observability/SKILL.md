---
name: observability
description: >
  Pipeline E2E de observability para agentes e RAG em produção.
  Tracing, métricas de retrieval, hallucination rate, monitoramento contínuo.
  Keywords: observability, tracing, metrics, monitoring, hallucination, faithfulness, RAG eval, production, opik.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, Agent
metadata:
  author: deivithi
  version: "1.0"
  source: "patchy631/ai-engineering-hub (eval-and-observability)"
---

# Observability — Monitoramento de Agentes e RAG em Produção

Pipeline de observability contínua para agentes IA e pipelines RAG. Vai além de evals pontuais — monitora performance em tempo real, rastreia traces de execução, mede métricas de retrieval e detecta degradação antes que impacte usuários.

## Quando Usar

- Agente ou RAG rodando em produção que precisa de monitoramento contínuo
- Detectar degradação de qualidade ao longo do tempo (drift)
- Medir retrieval quality, faithfulness e hallucination rate sistematicamente
- Debugar por que uma resposta específica foi ruim (trace analysis)
- Dashboard de saúde para stakeholders

## Quando NÃO Usar (→ Handoff)

- Avaliação pontual de output de skill → usar `evals` (OMC)
- Debug de código/erro pontual → usar `runbook` ou `spec-review`
- Monitoramento de infra (uptime, CPU, memory) → fora do escopo

## Métricas Core

### 1. Retrieval Quality
| Métrica | O Que Mede | Target |
|---------|-----------|--------|
| **Relevance Score** | % de chunks retornados que são relevantes para a query | > 70% |
| **Recall@K** | % de chunks relevantes que foram retornados no top-K | > 80% |
| **MRR (Mean Reciprocal Rank)** | Posição média do primeiro chunk relevante | > 0.7 |
| **Context Precision** | Relevância dos chunks usados na geração | > 0.75 |

### 2. Generation Quality
| Métrica | O Que Mede | Target |
|---------|-----------|--------|
| **Faithfulness** | Resposta fundamentada APENAS no contexto fornecido? | > 0.9 |
| **Hallucination Rate** | % de afirmações sem suporte no contexto | < 10% |
| **Answer Relevance** | Resposta realmente responde à pergunta? | > 0.85 |
| **Citation Coverage** | % de afirmações com citação | > 80% |

### 3. Operational
| Métrica | O Que Mede | Target |
|---------|-----------|--------|
| **Latency P50/P95** | Tempo de resposta | P50 < 3s, P95 < 10s |
| **Token Usage** | Custo por query | Monitorar trend |
| **Error Rate** | % de queries que falharam | < 2% |
| **Tool Call Success** | % de tool calls que retornaram resultado válido | > 95% |

## Workflow

### Fase 1 — Instrumentar o Pipeline

```
Cada execução do agente/RAG gera um TRACE:

Trace:
├── span: "query_embedding" (latency: 120ms)
├── span: "vector_search" (latency: 250ms, chunks: 5)
│   └── metadata: {relevance_scores: [0.92, 0.87, 0.71, 0.45, 0.32]}
├── span: "context_assembly" (tokens: 2400)
├── span: "llm_generation" (latency: 1800ms, model: "claude-sonnet-4-6")
│   └── metadata: {input_tokens: 2800, output_tokens: 450}
└── span: "response" (faithfulness: 0.95, citations: 3)
```

**Implementação prática:**
- Log structured (JSON) com campos padronizados
- Cada span tem: `start_time`, `end_time`, `metadata`, `parent_span_id`
- Armazenar em Supabase (tabela `traces`) ou serviço dedicado (Opik, LangSmith)

### Fase 2 — Avaliar Automaticamente

```
Para cada trace (ou sample de N%):

1. Relevance Grading (automático):
   - LLM-as-judge avalia cada chunk retornado
   - Score 0-1 por chunk
   - Média = Relevance Score do trace

2. Faithfulness Check (automático):
   - Extrair afirmações da resposta
   - Verificar: cada afirmação tem suporte no contexto?
   - Ratio = Faithfulness score

3. Hallucination Detection (automático):
   - Afirmações sem suporte no contexto = hallucination
   - Rate = hallucinations / total_claims
```

**Custo-consciente:** Não avaliar 100% das queries. Sample rate:
- Produção estável: 10% das queries
- Após deploy/mudança: 100% por 24h, depois voltar a 10%
- Alert triggered: 100% até resolver

### Fase 3 — Dashboards e Alertas

```
Dashboard (atualizado a cada hora):
┌──────────────────────────────────────────────┐
│ RAG Health Dashboard — Últimas 24h           │
├──────────────────────────────────────────────┤
│ Faithfulness:  ████████████░░ 0.94 (target: 0.9) ✅ │
│ Hallucination: ██░░░░░░░░░░░░ 6%  (target: <10%) ✅ │
│ Relevance:     █████████░░░░░ 0.78 (target: 0.7) ✅ │
│ Latency P95:   ████████████░░ 8.2s (target: <10s) ✅ │
│ Error Rate:    █░░░░░░░░░░░░░ 1.2% (target: <2%)  ✅ │
│ Token Cost:    $12.40 (últimas 24h)                   │
└──────────────────────────────────────────────┘

Alertas:
- Faithfulness < 0.85 por 1h → ⚠️ Warning
- Hallucination > 15% por 1h → 🚨 Critical
- Error rate > 5% por 30min → 🚨 Critical
- Latency P95 > 15s por 1h → ⚠️ Warning
```

### Fase 4 — Root Cause Analysis

Quando alerta dispara:

```
1. Identificar traces com score baixo
2. Comparar com traces saudáveis do mesmo período
3. Isolar: problema é no retrieval ou na geração?
   - Retrieval ruim + geração ruim → problema no índice/embedding
   - Retrieval bom + geração ruim → problema no prompt/modelo
4. Drill-down no span problemático
5. Corrigir e monitorar
```

## Progressive Disclosure

| Complexidade | Comportamento |
|-------------|---------------|
| **Simples** | Definir métricas + instrumentar logs structured. Dashboard manual |
| **Médio** | + LLM-as-judge automático (sample 10%) + alertas básicos |
| **Complexo** | + Pipeline completo com tracing, dashboards, alertas, RCA automático |

## Ferramentas Recomendadas

| Ferramenta | Tipo | Custo | Notas |
|-----------|------|-------|-------|
| **Opik (CometML)** | Tracing + Eval | Free tier | Bom para RAG eval, integra com LlamaIndex |
| **LangSmith** | Tracing + Eval | Free tier | Ecosystem LangChain |
| **Supabase (DIY)** | Storage | Já temos | Tabela `traces` + SQL dashboards. Zero custo extra |
| **n8n** | Alertas | Já temos | Workflow que lê traces e envia alertas Telegram |

**Recomendação:** Começar com Supabase DIY (zero custo) + n8n para alertas. Migrar para Opik quando volume justificar.

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Avaliação pontual de output | `evals` (OMC) | Não é monitoramento contínuo |
| Retrieval ruim detectado | `corrective-rag` | Ativar auto-correção |
| Problema no índice/embedding | `gbrain` | Reindexar ou ajustar |
| Alerta de infra | `runbook` | Investigação estruturada |

## Gotchas

1. **LLM-as-judge é caro** → Sample rate de 10%, não 100%. Custo de avaliação pode superar custo do RAG
2. **Métricas sem baseline são inúteis** → Estabelecer baseline ANTES de monitorar. Primeira semana = apenas coletar
3. **Hallucination ≠ erro** → Modelo pode sintetizar corretamente algo que não está explícito no chunk. Calibrar threshold
4. **Tracing em produção adiciona latência** → Logging assíncrono. Nunca bloquear a resposta para logar
5. **Dashboard sem ação é decoração** → Cada métrica deve ter um runbook: "se X cair abaixo de Y, fazer Z"

## Referências

- `patchy631/ai-engineering-hub/eval-and-observability` — Pipeline E2E com Opik + LlamaIndex
- [CometML Opik](https://github.com/comet-ml/opik) — Tracing + evaluation open-source
- RAGAS framework — Métricas padrão para RAG (faithfulness, relevance, context precision)
- Skill `corrective-rag` — Complemento: observability detecta, corrective-rag corrige
