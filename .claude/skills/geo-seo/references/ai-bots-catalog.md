# 🤖 AI Bots Catalog

Catálogo de user-agents oficiais de bots IA p/ validação de `robots.txt`.
Fonte: documentação oficial dos provedores (verificar periodicamente).

---

## 🔴 OpenAI (3 bots distintos)

| User-agent | Propósito | Bloquear impede |
|---|---|---|
| `GPTBot` | Training de modelos GPT | Uso do seu conteúdo p/ treinar futuros GPTs |
| `ChatGPT-User` | Fetch on-demand quando user clica em link no ChatGPT | Preview de links em respostas ChatGPT |
| `OAI-SearchBot` | Crawler do ChatGPT Search (produto) | Aparecer em resultados do ChatGPT Search |

Docs: https://platform.openai.com/docs/bots

---

## 🟣 Anthropic (2 bots)

| User-agent | Propósito |
|---|---|
| `ClaudeBot` | Crawler geral Anthropic (training + context) |
| `Claude-Web` | Fetch on-demand quando Claude acessa URL |

Docs: https://support.anthropic.com/en/articles/8896518

---

## 🔵 Google (2 bots p/ IA)

| User-agent | Propósito |
|---|---|
| `Google-Extended` | Controla uso em Gemini + Vertex AI. Independente de Googlebot |
| `GoogleOther` | Crawler experimental/research |

Docs: https://developers.google.com/search/docs/crawling-indexing/overview-google-crawlers

---

## 🟢 Perplexity

| User-agent | Propósito |
|---|---|
| `PerplexityBot` | Crawler principal Perplexity |
| `Perplexity-User` | Fetch on-demand |

Docs: https://docs.perplexity.ai/guides/bots

---

## 🟡 Meta / ByteDance / Outros

| User-agent | Owner | Propósito |
|---|---|---|
| `FacebookBot` | Meta | Training Llama + produtos Meta AI |
| `Bytespider` | ByteDance | Training Doubao (China) |
| `Amazonbot` | Amazon | Alexa + training |
| `Applebot` | Apple | Siri + Apple Intelligence |
| `Applebot-Extended` | Apple | Training Apple Intelligence (independente Applebot) |
| `CCBot` | Common Crawl | Dataset usado por múltiplos LLMs |
| `cohere-ai` | Cohere | Training Cohere models |
| `Diffbot` | Diffbot | Knowledge Graph commercial |

---

## ⚙️ Lógica de validação (ALLOW/DISALLOW/UNSPEC)

Ordem de precedência em `robots.txt`:

1. Grupo c/ User-agent mais específico vence (`GPTBot` > `*`)
2. Dentro do grupo: regra mais longa (path) vence (`/blog/draft/` > `/blog/`)
3. `Allow` e `Disallow` de mesmo path → `Allow` vence (RFC 9309)

**UNSPEC:** bot ñ aparece no robots.txt E `User-agent: *` ñ é restritivo.

---

## 🎯 Recomendações p/ Febracis (baseline)

**Permitir sempre (marca quer ser citada):**
- GPTBot, ChatGPT-User, OAI-SearchBot
- ClaudeBot, Claude-Web
- PerplexityBot, Perplexity-User
- Google-Extended (só se quer aparecer em Gemini)
- Applebot-Extended

**Considerar bloquear:**
- Bytespider (se ñ opera na China)
- CCBot (se preocupado c/ redistribuição do conteúdo em datasets públicos)

Exemplo robots.txt:
```
User-agent: GPTBot
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: Google-Extended
Allow: /

User-agent: Bytespider
Disallow: /
```

---

## 🔄 Manutenção

Revisar catálogo trimestralmente. Novos bots surgem rápido (2024-2026: mercado em expansão). Gatilho p/ revisão: release de nova IA major (ex: novo modelo Gemini/Claude c/ search).

Último update: 2026-04-21.
