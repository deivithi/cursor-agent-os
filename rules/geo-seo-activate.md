# 🤖 GEO-SEO — Rule de Ativação

> Ativa skill `.claude/skills/geo-seo/SKILL.md` quando contexto envolver GEO (Generative Engine Optimization) — otimização p/ search IA.

## Quando ativar

**Keywords:** `GEO`, `generative engine optimization`, `AI search`, `search IA`, `llms.txt`, `citability`, `AI citation`, `ChatGPT citation`, `Perplexity`, `Google AIO`, `Gemini`, `schema.org`, `JSON-LD`, `structured data`, `robots.txt AI`, `AI crawler`, `GPTBot`, `ClaudeBot`, `PerplexityBot`, `Google-Extended`.

**Frases típicas:**
- "como otimizar p/ ChatGPT?"
- "gera llms.txt p/ site X"
- "audit GEO da Febracis"
- "schema de evento p/ Método CIS"
- "estamos bloqueando bots IA?"
- "score de citability"

## Comportamento

1. Carregar `.claude/skills/geo-seo/SKILL.md`
2. Detectar subcomando implícito (audit / llmstxt / crawlers / schema / citability)
3. Se user pede **estratégia** → delegar p/ agency-agent correto (seo-specialist, ai-citation-strategist, agentic-search-optimizer)
4. Se user pede **execução** → rodar subcomando + gerar output em `out/`

## Defaults travados

- **Output dir:** `out/` (relativo ao projeto ativo)
- **URL padrão p/ testes Febracis:** `https://febracis.com.br`
- **URL padrão Pulso:** `https://pulsofinance.com.br`
- **Template padrão p/ evento:** `schema-event-cis.json`
- **Schema @context:** sempre `https://schema.org` (HTTPS)

## Safety carve-out

- Skill é **read-only** externamente (só fetch HTTP)
- Ñ modifica sites alvos
- Outputs em `out/` ñ tocam em código de produção
- Ñ gera operações destrutivas em Supabase

## Integração c/ agents

| User pede | Delegar p/ |
|---|---|
| Estratégia de citação | `marketing-ai-citation-strategist` |
| Plano SEO completo | `marketing-seo-specialist` |
| WebMCP readiness | `marketing-agentic-search-optimizer` |
| Brand monitoring contínuo | `marketing-ai-citation-strategist` + `agent-reach` |

## Fonte de verdade

- `.claude/skills/geo-seo/SKILL.md` — hub
- `.claude/skills/geo-seo/references/` — ai-bots, llms-txt spec, schema patterns
- `.claude/skills/geo-seo/templates/` — llms.txt Febracis + Event schema CIS
- `.claude/skills/geo-seo/gotchas.md` — 18 armadilhas
- `.claude/commands/geo-seo.md` — command c/ subcomandos
- Upstream: https://github.com/zubair-trabzada/geo-seo-claude (MIT, 6.6k⭐)
