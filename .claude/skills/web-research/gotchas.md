# Gotchas — web-research

## 1. WebSearch retorna snippets, não conteúdo completo
- **Sintoma:** Informação parcial ou cortada nos resultados de busca
- **Fix:** Sempre usar WebFetch nas fontes importantes para ler conteúdo completo
- **Exceção:** Mode QUICK pode usar apenas snippets para perguntas factuais simples

## 2. WebFetch pode falhar em sites com anti-bot
- **Sintoma:** Conteúdo vazio, CAPTCHA, ou erro 403
- **Fix:** Tentar URL alternativa da mesma informação, ou usar snippet do WebSearch como fallback
- **Fallback:** Se crítico, usar agent-browser via `/browser` para acessar site com JavaScript rendering

### Failure Table — Falhas Comuns por Tipo de Site

> Padrão absorvido do tinyfish-cookbook: documentar falhas previsíveis com ação específica.

| Tipo de site | Falha esperada | Ação |
|-------------|----------------|------|
| Sites com paywall (Medium, WSJ, FT) | Conteúdo truncado ou 403 | WebSearch snippet como fonte, ou buscar versão em cache/archive.org |
| SPAs pesadas (React/Angular sem SSR) | Conteúdo vazio no WebFetch | Escalar para browser-use MCP (`/browser`) |
| Sites com Cloudflare/anti-bot agressivo | 403 ou CAPTCHA | Buscar URL alternativa da mesma info; se crítico, `/browser` |
| APIs/docs com versioning | Info desatualizada | Verificar versão na URL; usar Context7 para docs oficiais |
| Redes sociais (X, LinkedIn, Instagram) | Login required ou conteúdo parcial | Usar agent-reach via `/reach` (acesso autenticado) |
| PDFs acadêmicos | WebFetch retorna garbage | Usar MarkItDown (`/markitdown`) para converter PDF → markdown |
| Sites regionais/gov BR | Encoding quebrado ou layout bizarro | WebFetch com prompt específico para extrair só o conteúdo relevante |

## 3. Fontes geradas por IA poluem resultados
- **Sintoma:** Múltiplas "fontes" dizem exatamente a mesma coisa com palavras diferentes
- **Fix:** Verificar se fontes são realmente independentes (autores diferentes, datas diferentes)
- **Heurística:** Se 3 blogs Medium dizem o mesmo sem dados originais, conta como 1 fonte, não 3

## 4. Documentação técnica muda rápido
- **Sintoma:** Tutorial de 2024 não funciona em 2026
- **Fix:** Sempre checar versão mencionada na fonte vs versão atual. Usar Context7 para docs oficiais atualizados
- **Regra:** Para bibliotecas/frameworks, Context7 > WebSearch

## 5. Viés de busca em inglês
- **Sintoma:** Pesquisas em inglês dominam resultados, perdem contexto local (BR, LGPD, etc.)
- **Fix:** Para temas com componente local, fazer busca adicional em português
- **Exemplo:** "LGPD compliance salesforce" + "LGPD conformidade salesforce"

## 6. WebFetch consome tokens proporcionais ao tamanho do conteúdo
- **Referência de custo:**
  - Página média (10 kB) ≈ **2.500 tokens**
  - Doc grande (100 kB) ≈ **25.000 tokens**
  - PDF acadêmico (500 kB) ≈ **125.000 tokens**
- **Fix:** Em mode STANDARD, limitar WebFetch a 3-5 fontes. Em DEEP, usar subagentes para paralelizar e evitar estouro de contexto
- **API tip:** Ao construir apps com Claude API, usar `max_content_tokens` para truncar conteúdo automaticamente. Ver [references/api-web-fetch.md](references/api-web-fetch.md)
