---
name: geo-seo
description: GEO (Generative Engine Optimization) — camada executável p/ otimizar sites p/ search IA (ChatGPT, Perplexity, Gemini, Google AIO). Gera llms.txt, valida robots.txt p/ 14+ bots IA, calcula citability score, emite JSON-LD schema.org. Integra c/ agency-agents marketing (seo-specialist, ai-citation-strategist, agentic-search-optimizer) — esta skill é execução, eles são estratégia. Absorção seletiva de geo-seo-claude (6.6k⭐, MIT). Ativa por keywords: GEO, llms.txt, AI search, generative engine, citability, ChatGPT citation, Perplexity, schema.org, JSON-LD, AI crawler.
---

# 🤖 GEO-SEO — Generative Engine Optimization Executável

> Camada **executável** p/ GEO. Estratégia fica c/ os 3 agents de marketing.
> Fork seletivo de `zubair-trabzada/geo-seo-claude` (6.6k⭐, MIT).

---

## 🎯 Quando ativar

Auto-ativa por keyword (rule `.claude/rules/geo-seo-activate.md`):

- `GEO`, `generative engine optimization`, `AI search`
- `llms.txt`, `citability`, `AI citation`
- `ChatGPT citation`, `Perplexity`, `Google AIO`
- `schema.org`, `JSON-LD`, `structured data`
- `robots.txt AI`, `AI crawler`, `GPTBot`, `ClaudeBot`, `PerplexityBot`

Invocação manual: `/geo-seo <subcomando> [args]`

---

## 📋 Subcomandos

| Subcomando | O q faz | Inputs | Output |
|---|---|---|---|
| `audit <url>` | Quick GEO audit combinado (llms.txt + robots + schema + citability) | URL completo | Markdown report em `out/geo-audit-<host>.md` |
| `llmstxt <url>` | Fetch + valida `/llms.txt`. Se ausente, gera baseado em sitemap | URL | Arquivo `out/llms-<host>.txt` + diagnóstico |
| `crawlers <url>` | Valida `/robots.txt` contra 14+ AI bots | URL | Tabela bot → ALLOW/DISALLOW/UNSPEC |
| `schema <tipo> [args]` | Gera JSON-LD válido (Organization, Event, Article, FAQ, HowTo, LocalBusiness) | Tipo + params | JSON-LD pronto em `out/schema-<tipo>.json` |
| `citability <url>` | Score 0-100 de citability p/ IA | URL | Score + top 3 passagens + sugestões |

**Padrão:** `audit` se user disser só "audita GEO do site X".

---

## 🔧 Workflow de execução

### `audit` — orquestra os 4 subcomandos

```
1. Normalizar URL (força https, remove trailing /)
2. Paralelo:
   - WebFetch /robots.txt       → crawlers check
   - WebFetch /llms.txt         → llmstxt check
   - WebFetch /                 → extrair HTML p/ schema + citability
   - WebFetch /sitemap.xml      → p/ gerar llms.txt se ausente
3. Citability scoring (algoritmo §5)
4. Schema detection (regex JSON-LD no HTML)
5. Compila markdown em out/geo-audit-<host>-<date>.md
6. Retorna resumo ≤10 linhas no chat
```

### `llmstxt`

```
1. Fetch /llms.txt
2. Se 200 → validar spec llmstxt.org (ver references/llms-txt-spec.md)
3. Se 404 → gerar a partir de sitemap.xml + meta descrição home
4. Output: arquivo + diagnóstico
```

### `crawlers`

```
1. Fetch /robots.txt
2. Parse c/ User-agent groups
3. P/ cada bot em references/ai-bots-catalog.md:
   - Resolver Allow/Disallow mais específico
   - Flag conflitos (ex: User-agent: *  Disallow: /  vs  User-agent: GPTBot  Allow: /)
4. Output: tabela markdown
```

### `schema <tipo>`

```
Tipos suportados (v1):
- organization   → Febracis default + params de override
- event          → Evento Método CIS (template pronto)
- event-cis      → Shortcut p/ template Febracis
- article        → Artigo de blog
- faq            → FAQPage c/ pares Q/A
- howto          → HowTo c/ steps
- localbusiness  → Filial Febracis

Usa templates/*.json como base, faz overrides via args.
Valida contra schema.org via regex + required fields.
```

### `citability` — algoritmo

```
Score = 0.25*Struct + 0.25*Density + 0.25*Length + 0.25*Authority

- Struct (0-100): headings hierárquicos H1→H2→H3 corretos? Listas? Tabelas?
- Density (0-100): % de sentenças factuais (números, datas, nomes próprios)
- Length (0-100): passagens entre 134-167 palavras = 100. Fora = decay
- Authority (0-100): tem author byline? schema Article? data publicação?

Output: score + top 3 passagens mais citáveis + top 3 sugestões de melhoria.
```

---

## 🏛️ Integração c/ agency-agents (acoplamento 100%)

**Esta skill é execução. Estratégia → delega:**

| User pede | Skill faz | Skill delega p/ agent |
|---|---|---|
| "qual score de citability?" | Executa algoritmo §5 | — |
| "como melhorar citação no ChatGPT?" | Passa contexto + resultado do audit | `marketing-ai-citation-strategist` |
| "plano de GEO p/ Febracis?" | Audit inicial como dado | `marketing-seo-specialist` |
| "estamos WebMCP-ready?" | Fetch + check básico | `marketing-agentic-search-optimizer` |
| "monitorar menções da marca?" | — (fora de escopo) | `marketing-ai-citation-strategist` + `agent-reach` |

**Regra:** se user pede plano/estratégia/narrativa → invoca agent. Se pede dado/validação/geração → executa.

---

## 🔗 Integrações c/ stack Febracis

- **Pulso Finance:** `templates/llms-txt-febracis.txt` tem bloco pronto p/ `pulsofinance.com.br`.
- **Método CIS:** `templates/schema-event-cis.json` = Event + Offers + Location.
- **Supabase:** histórico de audits → v2 (anotado em gotchas.md).
- **Salesforce:** GEO audit ñ roda em Salesforce direto (comunidades são SF-hosted) — flag em gotchas.md.
- **deep-research-workspace:** invocado p/ concorrência GEO.
- **artifact-factory / minimax-pdf:** gera relatório PDF a partir do markdown.

---

## 🛡️ Safety

- Skill é **read-only** externamente (só fetch HTTP, ñ modifica sites).
- Escreve só em `out/` (relatórios) e usa templates locais.
- `WebFetch` respeita robots.txt automaticamente.
- Zero deps novas (só WebFetch + browser-use existentes).
- Sem auth, sem secrets, sem risco destrutivo.

---

## 📚 Referências

- `references/ai-bots-catalog.md` — 14+ bots IA c/ user-agents oficiais + owner + user-visible
- `references/llms-txt-spec.md` — Spec llmstxt.org + exemplos Febracis
- `references/schema-patterns.md` — JSON-LD padrões (Organization, Event, Article, FAQ)
- `templates/llms-txt-febracis.txt` — Template pronto
- `templates/schema-event-cis.json` — Event schema Método CIS
- `gotchas.md` — Armadilhas conhecidas

---

## 🔒 Anti-patterns (ñ fazer)

- ❌ Duplicar estratégia dos 3 marketing agents → sempre delegar
- ❌ Criar CRM/prospect pipeline (Deivithi usa Salesforce)
- ❌ Gerar PDFs aqui → usar `artifact-factory` / `minimax-pdf`
- ❌ Puxar Python/Playwright → stack local é Node/TS/Go
- ❌ Criar 5 comandos separados → 1 command c/ subcomandos
- ❌ Brand monitoring contínuo → usar `agent-reach` + agent citação

---

## 📊 Fonte upstream

Fork seletivo de [`zubair-trabzada/geo-seo-claude`](https://github.com/zubair-trabzada/geo-seo-claude) — 6.6k⭐, MIT. Apenas 5 features das 13 foram absorvidas (ver plano em `plans/faz-sentido-para-n-s-ethereal-meerkat.md`). Licença MIT preservada, crédito em `references/llms-txt-spec.md`.
