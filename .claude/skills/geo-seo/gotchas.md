# 🕳️ Gotchas — geo-seo

## 1. llms.txt ñ é spec W3C
Padrão emergente (llmstxt.org, proposta Jeremy Howard 2024). Grandes IAs (OpenAI, Anthropic) ñ garantem obedecer. Trata como **sinal**, ñ contrato. Sempre combinar c/ robots.txt + schema.org.

## 2. robots.txt `User-agent: *` NÃO cobre bots IA em todos os cenários
- Google-Extended é **independente** de Googlebot — bloquear Googlebot ñ bloqueia AI training.
- ClaudeBot respeita `*` mas tem grupo próprio q pode sobrescrever.
- Regra: sempre listar bots IA explicitamente em regras críticas.

## 3. GPTBot ≠ ChatGPT-User ≠ OAI-SearchBot
3 bots OpenAI distintos:
- **GPTBot** — crawler p/ training de modelos
- **ChatGPT-User** — fetch quando user clica em link dentro do ChatGPT
- **OAI-SearchBot** — crawler do ChatGPT Search (produto)

Bloquear GPTBot ñ bloqueia ChatGPT Search. Referência: `references/ai-bots-catalog.md`.

## 4. JSON-LD inválido passa silencioso
Google Rich Results Test detecta. Script Node faz validação básica (required fields + tipos) — usar Rich Results Test p/ validação completa: https://search.google.com/test/rich-results

## 5. Citability score é heurístico, ñ verdade absoluta
Algoritmo mede: estrutura + densidade factual + length + authority signals. Ñ mede (v1): tópico, relevância semântica, competição. Score alto ñ garante citação — é **condição necessária**, ñ suficiente.

## 6. Passagens 134-167 palavras = mediana das citações observadas
Número vem da pesquisa original do geo-seo-claude. Ñ é regra dura — é sweet spot. Passagens fora dessa faixa ainda podem ser citadas se densidade factual for alta.

## 7. Schema Event Febracis precisa `offers` atualizado
Se Event schema tem `offers.price` e data/preço mudam → schema stale → risco de Google Rich Results rebaixar. Sempre regenerar schema em build/deploy.

## 8. CORS e WebFetch
WebFetch ignora CORS (server-side), mas alguns sites bloqueiam por user-agent. Fallback: `browser-use` headless Chrome.

## 9. Sitemap > 50k URLs
Sitemap XML grande → WebFetch corta. Se sitemap.xml aponta p/ sitemap-index.xml, subir 1 nível só. Múltiplos sitemaps ñ são merged (v1 limitation).

## 10. llms.txt gerado ≠ llms.txt curado
Geração automática a partir de sitemap é **baseline**. Versão final precisa edição humana p/ priorizar conteúdo estratégico. Skill avisa isso no output.

## 11. Histórico de audits
V1 ñ persiste audits — cada run sobrescreve `out/geo-audit-<host>.md`. V2: tabela `geo_audits` em Supabase via `supabase-factory`. Anotar data no nome (`geo-audit-<host>-YYYY-MM-DD.md`) pra ter série temporal local.

## 12. Salesforce Experience Cloud (comunidades)
Sites SF-hosted têm robots.txt/llms.txt controlados pela plataforma. Audit funciona (é só fetch externo), mas **fix** precisa passar por admin SF. Skill ñ edita SF direto.

## 13. JSON-LD `@context` DEVE ser `https://schema.org`
Erro comum: `http://schema.org` (sem S) → ainda funciona mas Google rebaixa. Sempre HTTPS.

## 14. Event schema sem `startDate` é inválido
Required fields Event: `name`, `startDate` (ISO8601 c/ timezone). Templates já incluem. Se user gerar customizado, validar.

## 15. FAQPage schema ñ é apropriado p/ landing pages
Google mudou em 2023: FAQPage schema só é exibido p/ sites gov/saúde. Use `QAPage` se for single Q&A. Ñ spammear FAQPage em landing de venda.

## 16. `organization` schema e logo
Logo DEVE ser URL absoluta, PNG/JPG, mínimo 112x112px, ratio próximo 1:1. Google rebaixa se logo falha.

## 17. Política caverna (PT-BR)
Relatórios gerados em `out/` seguem PT-BR c/ acentuação correta. Comentários inline em código EN OK (convenção Febracis).

## 18. Não duplicar brand monitoring
`agent-reach` + `marketing-ai-citation-strategist` fazem brand mention tracking. Esta skill ñ — apenas audita estrutura do próprio site.
