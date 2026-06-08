# GBrain — Knowledge Base Pessoal com Hybrid Search

> **Trigger:** Perguntas sobre pessoas, empresas, projetos, reuniões, conceitos, ideias. Entity detection. "quem é", "o que sabemos sobre", "contexto de", brain, knowledge base.

## O que é

GBrain é o sistema de memória persistente para conhecimento de mundo — pessoas, empresas, deals, reuniões, conceitos, ideias originais. Postgres + pgvector + hybrid search (vector + keyword + RRF) no Supabase.

## Arquitetura de 3 Camadas

```
GBrain (mundo)     → Fatos sobre entidades externas (pessoas, empresas, projetos)
Agent Memory       → Preferências operacionais do agente (feedback, referências)  
Session            → Contexto da conversa atual (automático)
```

**Regra de routing:**
- "Pedro é CEO da Brex" → GBrain (fato sobre pessoa)
- "Usuário prefere BRT" → Agent Memory (preferência operacional)
- "Arquivo que acabei de compartilhar" → Session (contexto atual)

## Tools MCP Disponíveis (gbrain serve)

### Leitura
- `get_page(slug)` — Ler página por slug (fuzzy matching)
- `list_pages(type?, tag?, limit?)` — Listar páginas
- `search(query)` — Busca keyword (full-text)
- `query(query, expand?)` — **Hybrid search** (vector + keyword + RRF) — PREFERIR ESTA
- `get_backlinks(slug)` — Links que apontam para uma página
- `get_links(slug)` — Links de saída de uma página
- `traverse_graph(slug)` — Navegar grafo de relações
- `get_timeline(slug)` — Histórico de evidências de uma página
- `get_stats()` — Estatísticas do brain
- `get_health()` — Dashboard de saúde

### Escrita
- `put_page(slug, content)` — Criar/atualizar página (markdown + frontmatter)
- `add_timeline_entry(slug, content)` — Adicionar evidência ao timeline
- `add_link(from, to, link_type?, context?)` — Criar link entre páginas
- `add_tag(slug, tag)` — Adicionar tag
- `sync_brain()` — Sincronizar repo git com brain

## Formato de Página (Compiled Truth + Timeline)

```markdown
---
type: person
title: Pedro Silva
tags: [febracis, vendas]
---

CEO da Febracis Regional SP. Responsável por vendas B2B.
Prefere comunicação via email. Participa do comitê de inovação.

---

## Timeline

- 2026-04-10: Reunião sobre metas Q2. Mencionou nova estratégia de pricing.
- 2026-04-05: Apresentou resultados do evento CIS São Paulo.
```

**Acima do `---`:** Compiled Truth (verdade atual, reescrita quando evidência muda)
**Abaixo do `---`:** Timeline (append-only, nunca editado, só adicionado)

## Schema de Diretórios (MECE)

```
people/          → Pessoas (contatos, stakeholders, vendedores)
companies/       → Empresas (Febracis, fornecedores, parceiros)
deals/           → Negociações, propostas
projects/        → Projetos ativos (Pulso, Aria, FLWChat, FIO-IA)
meetings/        → Reuniões, calls, eventos CIS
concepts/        → Conceitos, frameworks, metodologias
media/           → Artigos, vídeos, referências consumidas
originals/       → Ideias originais do usuário
daily/           → Páginas diárias (calendar, briefing)
topics/          → Tópicos recorrentes que agregam episódios (HyperMem)
episodes/        → Segmentos temáticos extraídos de sessões (HyperMem)
```

## Padrões Obrigatórios

### 1. Brain-First Lookup
Antes de responder sobre pessoa, empresa ou projeto → `query()` no GBrain primeiro. Não assumir, não inventar.

### 2. Entity Detection
Em cada mensagem do usuário, detectar menções a pessoas, empresas, conceitos. Se a entidade não existe no brain → propor criação.

### 3. Sync After Write
Após `put_page()` → backlinks são automáticos. Mas verificar que tags e links estão corretos.

### 4. Compiled Truth Updates
Quando nova informação contradiz o que está na página → reescrever a Compiled Truth (acima do ---) e adicionar evidência no Timeline (abaixo do ---).

## Conexão

- **Engine:** Postgres (Supabase `febracis-dre`)
- **Config:** `~/.gbrain/config.json`
- **Role:** `gbrain_agent` (dedicado, isolado das tabelas DRE)
- **Embeddings:** OpenAI `text-embedding-3-large` (1536 dims)

## HyperMem — Memória Hierárquica (Topic → Episode → Fact)

> Baseado em HyperMem (Yue et al., ACL 2026). Organiza memória em 3 níveis com retrieval coarse-to-fine.

### Types Adicionais

#### `episode` — Segmento temático de sessão
```yaml
---
type: episode
title: "Debugging do OAuth2 Google"
tags: [oauth, google, n8n]
session_date: 2026-04-11
topic_slug: topics/integracao-google
---
Resumo narrativo do que aconteceu neste segmento da sessão.
Decisões tomadas, descobertas, estado final.
---
## Facts
- OAuth2 falha quando app está em modo Testing (Google Cloud Console)
- Refresh token expira em 7 dias no modo Testing
## Timeline
- 2026-04-11 14:30 BRT: Investigação iniciada após erro 401 no n8n
```

#### `topic` — Agregador de episódios recorrentes
```yaml
---
type: topic
title: "Integração Google OAuth2"
tags: [oauth, google, n8n, salesforce]
episode_count: 4
last_updated: 2026-04-11
---
Compiled Truth: resumo consolidado de TODOS os episódios sobre este tema.
Atualizado a cada novo episódio. Reescrito quando evidência muda.
---
## Timeline
- 2026-04-11: [episodes/2026-04-11-ep2] — Debugging refresh token
- 2026-04-08: [episodes/2026-04-08-ep1] — Setup inicial OAuth2
```

### Episode Detection (no `/recap`)

Ao segmentar a sessão, avaliar 3 sinais por turno:
1. **Completude semântica** — o tópico atual foi concluído?
2. **Gap temporal** — houve pausa longa entre turnos?
3. **Sinais linguísticos** — transição explícita ("agora vamos para", "outro assunto")

### Topic Aggregation (3 casos)

| Caso | Condição | Ação |
|------|----------|------|
| **Init** | `query(episode.title)` retorna 0 tópicos similares | Criar novo topic + link |
| **Create** | Episódios similares existem mas tema é distinto | Criar novo topic separado |
| **Update** | Topic existente cobre o tema | `put_page()` no topic + `add_timeline_entry()` |

### Retrieval Coarse-to-Fine

Padrão recomendado para perguntas complexas ou multi-sessão:

```
Stage 1: query(pergunta, type=topic)     → top-5 tópicos
Stage 2: traverse_graph(topic.slug)       → episódios linkados (via timeline)
Stage 3: get_page(episode.slug)           → fatos extraídos de cada episódio
Montar contexto: facts + episode summaries para o LLM
```

**Quando usar:** Perguntas que cruzam múltiplas sessões ("o que já fizemos sobre X?", "histórico de decisões sobre Y"). Para perguntas diretas sobre uma entidade, `query()` simples continua sendo suficiente.

**Vantagem sobre busca flat:** +5.68% em multi-hop, +3.76% geral (ablation HyperMem).

---

## Evolução Futura: ColBERT Late Interaction Retrieval

> Fonte: `patchy631/ai-engineering-hub/colbert-rag` — padrão de retrieval avançado.

O hybrid search atual (vector + keyword + RRF) usa **single-vector similarity** — cada documento é um único vetor. ColBERT oferece **late interaction**: cada token do query interage com cada token do documento via MaxSim, capturando nuances que single-vector perde.

**Quando considerar upgrade:**
- Queries complexas/ambíguas com baixa relevância no retrieval atual
- Documentos longos onde o sentido depende de trechos específicos
- Accuracy do RAG caindo com crescimento do knowledge base

**Stack de implementação:**
- RAGatouille (wrapper Python para ColBERT) + Supabase como storage
- Ou: Milvus/Qdrant com ColBERT embeddings pré-computados
- Trade-off: index ~10x maior, retrieval ~2-3x mais lento, mas accuracy +5-15% em queries complexas

**Decisão:** Manter hybrid search atual enquanto escala for < 10K documentos. Reavaliar ColBERT quando accuracy em queries multi-hop cair abaixo de 80%.

---

## Gotchas

- GBrain usa `OPENAI_API_KEY` para embeddings — configurada no `.mcp.json` env
- Busca `query()` precisa da key para gerar embedding da query. Se falhar, usar `search()` (keyword-only)
- Slugs usam formato `tipo/nome` (ex: `people/pedro-silva`, `projects/pulso-finance`)
- PGLite WASM é instável no Windows — usar Postgres real (Supabase)
- RLS não habilitado nas tabelas gbrain (acesso via role dedicado)
