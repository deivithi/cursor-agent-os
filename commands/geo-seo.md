---
description: GEO-SEO — audit + llms.txt + robots.txt AI bots + JSON-LD + citability. Absorção seletiva de geo-seo-claude
argument-hint: "<subcomando> [url|tipo] — audit|llmstxt|crawlers|schema|citability"
---

# 🤖 /geo-seo — Generative Engine Optimization

Carrega skill `.claude/skills/geo-seo/SKILL.md` e executa subcomando.

## Subcomandos

| Subcomando | Input | O q faz |
|---|---|---|
| `audit <url>` | URL site | Quick audit combinado — llms.txt + robots + schema + citability |
| `llmstxt <url>` | URL site | Fetch + valida `/llms.txt`. Se ausente, gera a partir de sitemap |
| `crawlers <url>` | URL site | Valida `/robots.txt` contra 14+ AI bots |
| `schema <tipo>` | `organization\|event\|event-cis\|article\|faq\|howto\|localbusiness` | Gera JSON-LD válido |
| `citability <url>` | URL página | Score 0-100 + top 3 passagens + sugestões |

**Padrão:** se só URL sem subcomando → `audit`.

## Exemplos

```
/geo-seo audit https://febracis.com.br
/geo-seo llmstxt https://pulsofinance.com.br
/geo-seo crawlers https://febracis.com.br
/geo-seo schema event-cis
/geo-seo citability https://febracis.com.br/blog/ie-5-passos
```

## Outputs

- Relatórios markdown em `out/geo-*.md`
- JSON-LD em `out/schema-*.json`
- Nome c/ data: `out/geo-audit-<host>-YYYY-MM-DD.md`

## Arguments

`$ARGUMENTS` = linha inteira após `/geo-seo`. Primeiro token = subcomando, resto = args.

## Instrução p/ o agent

1. Carregar `.claude/skills/geo-seo/SKILL.md` (hub)
2. Parsing: primeiro token de `$ARGUMENTS` → subcomando. Se ñ casar c/ lista acima + segundo token é URL → assumir `audit`.
3. Consultar references/gotchas conforme subcomando:
   - `crawlers` → `references/ai-bots-catalog.md`
   - `llmstxt` → `references/llms-txt-spec.md` + `templates/llms-txt-febracis.txt`
   - `schema` → `references/schema-patterns.md` + `templates/schema-event-cis.json`
   - `citability` → algoritmo §5 do SKILL.md
4. Executar fetch via WebFetch (ñ tocar em `mcp__browser-use__*` salvo fallback)
5. Gerar output em `out/` (criar diretório se ñ existir)
6. Retornar resumo caverna ultra (≤10 linhas) no chat c/ link p/ arquivo gerado
7. Se user pediu **estratégia** ñ execução → delegar p/ agent (`marketing-ai-citation-strategist` / `marketing-seo-specialist` / `marketing-agentic-search-optimizer`) e sair

## Integração

- **browser-use:** fallback quando WebFetch bloqueia (CORS / user-agent)
- **artifact-factory:** gera PDF do audit se user pedir
- **deep-research-workspace:** concorrência GEO se user pedir análise comparativa
- **agent-reach:** brand monitoring (ñ feito aqui)

## Safety

- Read-only externamente
- Zero deps novas
- Zero risco destrutivo
