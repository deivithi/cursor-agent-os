---
name: last30
version: "1.0.0"
description: >
  Inteligência de tendências dos últimos 30 dias sem custo algum.
  Cruza Reddit (posts + comentários grátis), Hacker News, GitHub, YouTube,
  web e X/Twitter. Sintetiza relatório narrativo com citações reais e scoring
  por engajamento. Suporta modo comparativo "X vs Y".
argument-hint: 'last30 Salesforce automation, last30 n8n vs Make'
allowed-tools: Bash, WebSearch, Read
domain: research
subdomain: trends-intelligence
author: deivithi
tags:
  - research
  - trends
  - reddit
  - hackernews
  - github
  - youtube
  - free
  - no-api-key
user-invocable: true
---

# /last30 — Inteligência de Tendências 30 Dias (Custo Zero)

> Pesquisa qualquer tópico cruzando Reddit, HN, GitHub, YouTube, web e X —
> sem pagar nenhuma API. Relatório narrativo com fontes citadas.

---

## Passo 0 — Detectar modo comparativo

Inspecione o argumento fornecido pelo usuário.

- Se contiver ` vs ` ou ` versus ` (case-insensitive): **modo comparativo** → siga Passo 0-C
- Caso contrário: **modo padrão** → siga Passo 1

### Modo Comparativo (Passo 0-C)

Separe os dois lados: `TOPIC_A` e `TOPIC_B`.
Execute o Passo 1 e Passo 2 **duas vezes em paralelo** (uma para cada lado).
Ao final, gere o relatório do Passo 3 em formato comparativo com tabela side-by-side.

---

## Passo 1 — Coleta estruturada (Reddit + HN + GitHub)

Calcule o caminho absoluto do script:
```
SKILL_DIR = diretório onde este SKILL.md está localizado
SCRIPT = {SKILL_DIR}/scripts/last30_collect.py
```

Execute:
```bash
python3 "{SCRIPT}" "{TOPIC}"
```

O script retorna JSON com:
```json
{
  "topic": "...",
  "collected_at": "...",
  "since": "YYYY-MM-DD",
  "reddit": [ { "title", "url", "score", "comments", "subreddit", "snippet", "top_comments", "date" } ],
  "hackernews": [ { "title", "url", "score", "comments", "date" } ],
  "github": [ { "title", "url", "score", "description", "date" } ]
}
```

**Se o script falhar** (python3 não encontrado, timeout, etc.): anote o erro, continue
com Passo 2 e indique no relatório que esta fonte falhou.

---

## Passo 2 — Coleta via WebSearch

Execute as 3 buscas abaixo. Extraia título, URL, snippet e data de cada resultado.

**2a. Web geral / Notícias:**
```
"{TOPIC}" trends 2026 site:substack.com OR site:medium.com OR site:techcrunch.com OR inurl:blog
```

**2b. YouTube:**
```
site:youtube.com "{TOPIC}" 2026
```

**2c. X / Twitter (posts públicos):**
```
site:x.com OR site:twitter.com "{TOPIC}" after:{SINCE_DATE}
```

> `{SINCE_DATE}` = data de 30 dias atrás no formato `YYYY-MM-DD`

---

## Passo 3 — Scoring, Deduplicação e Síntese

### 3a. Scoring de engajamento

Ordene todos os itens coletados por:
```
engagement_score = score_upvotes + (comments * 2)
```
Para GitHub: `engagement_score = stars * 3`
Para WebSearch: ordene por posição nos resultados (1º = mais relevante).

### 3b. Deduplicação

Remova duplicatas por URL exata. Se o mesmo conteúdo aparecer em fontes
diferentes, mantenha o da fonte com maior engajamento.

### 3c. Síntese narrativa

Gere o relatório no formato abaixo. Use **português do Brasil**.
Cite as fontes inline com formato `([Título](URL))`.

---

## Formato do Relatório

```markdown
# 📊 Last30: {TOPIC}
> Pesquisa dos últimos 30 dias · {DATA_ATUAL} · Fontes: Reddit, HN, GitHub, YouTube, Web

---

## 🔍 Resumo Executivo
[3-4 frases: o que está acontecendo com este tópico agora, tom geral da comunidade,
 maior insight encontrado]

---

## 🔥 O que está em alta

[Top 5 conteúdos por engajamento, cada um em 2-3 linhas explicando por que importa.
 Inclua fonte, score/upvotes, e o que a comunidade está dizendo]

---

## 💬 Voz da Comunidade

[O que as pessoas estão realmente dizendo — extraia das top_comments do Reddit
 e comentários do HN. Cite 4-6 comentários representativos com atribuição ao subreddit/HN.
 Identifique: consensos, debates, frustrações, entusiasmos]

---

## 📈 Tendências detectadas

[3-5 bullets de tendências concretas com evidências dos dados coletados.
 Formato: "🟢 Crescendo: ...", "🔴 Declinando: ...", "⚡ Emergindo: ..."]

---

## 🔗 Todas as fontes ({N} total)

### Reddit ({N} posts)
| Post | Score | Subreddit |
|------|-------|-----------|
[tabela com todos os posts, ordenados por score]

### Hacker News ({N} stories)
| Story | Pontos | Comentários |
|-------|--------|------------|
[tabela]

### GitHub ({N} repos)
| Repo | Stars | Descrição |
|------|-------|-----------|
[tabela]

### Web / YouTube / X
[lista com bullet points — título, URL, fonte]

---

*Gerado por /last30 v1.0 · Dados: Reddit JSON API + HN Algolia + GitHub CLI + WebSearch · Custo: $0*
```

---

## Modo Comparativo — Formato adicional

Após os dois relatórios individuais, adicione:

```markdown
---

## ⚔️ {TOPIC_A} vs {TOPIC_B} — Side-by-Side

| Dimensão | {TOPIC_A} | {TOPIC_B} |
|----------|-----------|-----------|
| Volume de discussão (Reddit posts) | N | N |
| Engajamento médio | X pts | Y pts |
| Sentimento da comunidade | 😊/😐/😤 | 😊/😐/😤 |
| Trending no HN | ✅/❌ | ✅/❌ |
| Atividade GitHub (repos ativos) | N | N |
| Principal caso de uso citado | "..." | "..." |
| Principal crítica citada | "..." | "..." |

## 🏆 Veredicto baseado em dados

[2-3 parágrafos: qual ganhou em volume, qual em qualidade de discussão,
 para qual contexto cada um é mais indicado — baseado nos dados coletados,
 não em opinião]
```

---

## Exemplos de uso

```
/last30 Salesforce CPQ 2026
/last30 automação comercial CRM
/last30 Claude Code
/last30 método CIS coaching
/last30 n8n vs Make
/last30 Claude Code vs Cursor
/last30 geração de leads inteligência artificial
```

---

## Notas técnicas

- **Reddit**: JSON API pública (`reddit.com/search.json`) — sem auth, sem custo
- **HN**: Algolia API oficial (`hn.algolia.com/api/v1/search`) — sem auth, sem custo
- **GitHub**: `gh search repos` — já autenticado via gh CLI
- **Web/YouTube/X**: WebSearch MCP — já configurado
- **Comentários Reddit**: coletados via `{permalink}.json` — sem auth, sem custo
- **Rate limits**: Reddit ~60 req/min sem auth; HN sem limite documentado; GitHub 1000 req/h
