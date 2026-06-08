# Pulso AI Agent — Benchmark & Roadmap

> Pesquisa comparativa com os melhores agentes IA de finanças pessoais (2025-2026).
> **Ultima atualizacao:** 2026-05-24 (v5.0.0 — Agent Memory v2 pgvector + Multi-Agent). Skill sincronizada via GitHub 2026-06-01.
>
> ⚠️ Vários "gaps" abaixo JÁ FORAM FECHADOS (S3-S13) — marcados inline com ✅ FECHADO. Este doc é histórico de roadmap; o estado atual está no SKILL.md seção 5.

## Estado Atual do Pulso AI Agent

| Dimensao               | Pulso AI                                                                                                     | Status         |
| ---------------------- | ------------------------------------------------------------------------------------------------------------ | -------------- |
| **Framework**          | LangChain + LangGraph (ReAct agent)                                                                          | ✅ World-class |
| **Tools**              | 17+ tools (Multi-Agent: supervisor + 6 specialists + editor + judge)                                         | ✅ Bom         |
| **Memoria**            | threads + messages + MemorySaver + HyperMem (memories/episodes/topics) + pgvector semântico (gte-small 384d) | ✅ Bom         |
| **RAG**                | Tools consultam dados reais do usuario                                                                       | ✅ Funcional   |
| **Tom conversacional** | WhatsApp-like, emojis leves                                                                                  | ✅ Natural     |
| **Fallback**           | LangGraph falha → LLM direto                                                                                 | ✅ Graceful    |
| **UI**                 | Chat panel com threads, suggested actions                                                                    | ✅ Funcional   |

## Benchmark vs Competidores

### Cleo AI (referencia #1 — 12M+ usuarios)

| Feature            | Cleo                     | Pulso                    | Gap                               |
| ------------------ | ------------------------ | ------------------------ | --------------------------------- |
| Personalidade      | Sassy, amigo sincero     | WhatsApp casual          | ⚠️ Falta personalizacao           |
| Two-way Voice      | Voz em tempo real (o3)   | Apenas texto             | ❌ Nao tem                        |
| Long-term Memory   | Lembra metas, habitos    | Threads isoladas         | ⚠️ Memoria entre sessoes limitada |
| Proactive Insights | Push automatico          | Apenas no dashboard load | ⚠️ Nao tem push proativo          |
| Roast Mode         | Humor provocativo        | Nao tem                  | ❌ Diferenciador                  |
| Chain-of-thought   | Reasoning sobre decisoes | ReAct implícito          | ✅ Equivalente                    |

### Copilot Money

| Feature                  | Copilot                  | Pulso                | Gap                   |
| ------------------------ | ------------------------ | -------------------- | --------------------- |
| Per-user ML model        | Categorizacao aprende    | categorias_historico | ✅ Similar            |
| NL transaction search    | "Quanto gastei no Uber?" | Busca no extrato     | ⚠️ Falta no chat      |
| Smart budget suggestions | Baseado em habitos       | Manual               | ⚠️ Falta auto-suggest |

### ChatGPT (referencia de UX)

| Feature             | ChatGPT               | Pulso             | Gap                    |
| ------------------- | --------------------- | ----------------- | ---------------------- |
| Custom Instructions | 2 campos, 1500 chars  | Nao tem           | ❌ **Prioridade alta** |
| Two-layer Memory    | Explicita + implicita | Apenas threads    | ⚠️ Falta               |
| Projects            | Workspace com uploads | Nao tem           | ❌ Nao aplicavel       |
| Canvas              | Edicao side-by-side   | Nao tem           | Futuro                 |
| Suggested replies   | Sim                   | Sim (4 perguntas) | ✅                     |

### Claude (referencia de arquitetura)

| Feature                  | Claude                    | Pulso                | Gap                        |
| ------------------------ | ------------------------- | -------------------- | -------------------------- |
| Per-project instructions | System prompt por projeto | Nao tem              | ❌ **Prioridade alta**     |
| Artifacts                | Outputs standalone        | Nao tem              | Futuro                     |
| Analysis sandbox         | Python para calculos      | Tools fazem calculos | ✅ Equivalente             |
| Memory opt-in            | User-initiated            | Automatica           | ✅ Diferente mas funcional |

## Gaps Prioritarios (Fase 7 — AI Agent Upgrade)

> ✅ **STATUS 2026-05 — quase tudo FECHADO:**
>
> - Gap #1 **Contexto Personalizado** → ✅ FECHADO (`profiles.ai_about_me` + `ai_response_style`, injetados no system prompt)
> - Gap #2 **Memória Cross-Thread** → ✅ FECHADO (S3/S5 HyperMem + S13 **pgvector semântico** `gte-small`)
> - Gap #3 **NL transaction search** → ✅ FECHADO (tool `search_transactions`, #9)
> - Gap #4 **Smart budget suggestions** → ✅ FECHADO (tool `suggest_budget`, #8)
> - Two-way Voice → ✅ parcial (S7 `useVoiceChat` STT/TTS)
> - Proactive Insights → ✅ FECHADO (S2 `agent-supervisor` 3x/dia + push + S5 email digest)
>
> Texto abaixo é histórico. Não tratar como TODO.

### 1. Contexto Personalizado pelo Usuario (CRITICO)

**Inspiracao:** ChatGPT Custom Instructions + Claude Projects
**O que:** Na pagina de Configuracoes, o usuario define:

- Campo 1: "Sobre mim" (renda, dependentes, metas, perfil de risco)
- Campo 2: "Como quero que o Pulso AI responda" (tom, nivel de detalhe)
- Esses campos sao injetados como system prompt adicional em TODA interacao

**Implementacao:**

```sql
-- Adicionar na tabela profiles
ALTER TABLE profiles ADD COLUMN ai_context TEXT DEFAULT '';
ALTER TABLE profiles ADD COLUMN ai_preferences TEXT DEFAULT '';
```

Frontend: 2 textareas na pagina Configuracoes
Backend: injetar no system prompt do LangGraph agent

### 2. Memoria Persistente Cross-Thread (ALTO)

**Inspiracao:** ChatGPT Memory, Cleo Long-term Memory
**O que:** O agente lembra decisoes e fatos entre threads:

- "Meu salario e R$ 10.000"
- "Estou economizando para viagem em dezembro"
- "Nao gosto de investir em renda variavel"

**Implementacao:**

```sql
CREATE TABLE ai_memories (
  id UUID PK, user_id FK, content TEXT,
  source TEXT 'explicit'|'implicit',
  confidence FLOAT DEFAULT 0.9,
  created_at TIMESTAMPTZ
);
```

Nova tool: `manage_memory` — salva/busca memorias
System prompt: injeta top 5 memorias relevantes

### 3. Busca em Linguagem Natural no Chat (MEDIO)

**Inspiracao:** Copilot Money NL search
**O que:** "Quanto gastei no iFood em janeiro?" → agente faz query real
Nova tool: `search_transactions` com filtros por descricao, data, categoria

### 4. Sugestoes Proativas de Orcamento (MEDIO)

**Inspiracao:** Copilot Intelligence
**O que:** Ao criar orcamento, o agente sugere limites baseados no historico real
Nova tool: `suggest_budget` que analisa gastos dos ultimos 3 meses por categoria

## Repos de Referencia

| Repo                                                                         | Stars | Relevancia                                      |
| ---------------------------------------------------------------------------- | ----- | ----------------------------------------------- |
| [open-webui](https://github.com/open-webui/open-webui)                       | 210K+ | RAG, plugins, multi-model                       |
| [LobeChat](https://github.com/lobehub/lobe-chat)                             | 72K+  | UI polida, PWA, knowledge base                  |
| [chatbot-ui](https://github.com/mckaywrigley/chatbot-ui)                     | 28K+  | **Supabase storage** — referencia direta        |
| [assistant-ui](https://github.com/assistant-ui/assistant-ui)                 | —     | Componentes React AI, integra com **LangGraph** |
| [FinRobot](https://github.com/AI4Finance-Foundation/FinRobot)                | 2K+   | Agentes IA para analise financeira              |
| [vercel-ai-chatbot](https://github.com/supabase-community/vercel-ai-chatbot) | ~2K   | Template Vercel + Supabase + AI SDK             |

## RAG Patterns Avancados (2026)

| Pattern                   | Descricao                                                    | Aplicavel?                                  |
| ------------------------- | ------------------------------------------------------------ | ------------------------------------------- |
| **Corrective-RAG (CRAG)** | Self-grading em documentos recuperados + fallback web search | Futuro                                      |
| **Self-RAG**              | Self-grading em geracoes para detectar alucinacoes           | Sim — verificar calculos                    |
| **Adaptive RAG**          | Roteia queries por complexidade                              | Sim — simple vs complex financial questions |
| **3 pilares producao**    | RAG + tool use + memory                                      | Pulso ja tem os 3!                          |

## Arquitetura-Alvo (Fase 7+)

```
┌───────────────────────────────────────┐
│          REACT FRONTEND               │
│  Chat UI (streaming, markdown, voice) │
│  Custom Instructions (Configuracoes)  │
│  Suggested Actions contextuais        │
├──────────────────────────────────────┤
│          SUPABASE EDGE FUNCTION       │
│  LangGraph ReAct Agent                │
│  ┌─────────────────────────────────┐ │
│  │ System Prompt                    │ │
│  │ = base + ai_context + ai_prefs  │ │
│  │ + top 5 ai_memories             │ │
│  ├─────────────────────────────────┤ │
│  │ Tools (9+):                     │ │
│  │ • query_finances (RAG)          │ │
│  │ • analyze_subscriptions         │ │
│  │ • calculate_projection          │ │
│  │ • compare_periods               │ │
│  │ • suggest_savings               │ │
│  │ • debt_freedom_plan             │ │
│  │ • check_budgets                 │ │
│  │ • search_transactions (NOVO)    │ │
│  │ • manage_memory (NOVO)          │ │
│  ├─────────────────────────────────┤ │
│  │ Memory: threads + messages      │ │
│  │ + ai_memories (cross-thread)    │ │
│  │ + MemorySaver (in-session)      │ │
│  └─────────────────────────────────┘ │
├──────────────────────────────────────┤
│          SUPABASE DB + RLS            │
│  25 tabelas + ai_memories.embedding   │
│  (pgvector 384d + HNSW cosine)        │
└───────────────────────────────────────┘
```
