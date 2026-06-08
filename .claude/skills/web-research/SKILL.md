---
name: web-research
description: >
  Pesquisa web profunda com metodologia estruturada: multi-source triangulation,
  progressive refinement, source quality scoring e output otimizado para LLM.
  Usa WebSearch + WebFetch + Context7. Não requer instalação externa.
domain: research
subdomain: web-intelligence
version: 1.0.0
author: deivithi
tags:
  - research
  - web-search
  - triangulation
  - fact-checking
  - deep-research
  - RAG
---

# 🔍 Web Research — Pesquisa Profunda com Triangulação

> **"Uma fonte é opinião. Duas fontes é padrão. Três fontes é fato."**

## File Structure
- `SKILL.md` — Workflow principal (comece aqui)
- `references/methodology.md` — Detalhes da metodologia de triangulação
- `gotchas.md` — Problemas conhecidos e edge cases

## Related Skills
- `iterative-retrieval` — Pesquisa iterativa em codebases (complementar: código vs web)
- `smart-explore` — Exploração progressiva de código (complementar: interno vs externo)
- `data-charts` — Visualizar dados de pesquisa em gráficos
- `mermaid-diagrams` — Mapear relações encontradas em diagramas

---

## 1. Tools Disponíveis

| Tool | Uso | Força | Custo médio |
|------|-----|-------|-------------|
| **WebSearch** | Busca ampla, múltiplas fontes | Descoberta, panorama, fontes recentes | ~500-1K tokens/busca |
| **WebFetch** | Leitura profunda de uma URL | Extração detalhada, dados específicos | ~2.5K-25K tokens/página |
| **Context7** | Docs de bibliotecas/frameworks | Documentação técnica atualizada | ~1K-5K tokens/query |
| **Agent (Explore)** | Busca em codebase local | Código-fonte, implementações | Variável |

---

## 2. Workflow — DART (Discover → Analyze → Refine → Triangulate)

### Fase 1: DISCOVER (Descoberta Ampla)

**Objetivo:** Mapear o espaço do problema com buscas amplas.

```
AÇÕES:
1. Formular 3 queries com ângulos diferentes:
   - Query técnica: "[tema] implementation guide 2026"
   - Query comparativa: "[tema] vs [alternativa] comparison"
   - Query problemas: "[tema] gotchas pitfalls common mistakes"

2. Executar WebSearch em paralelo (3 buscas simultâneas)

3. Catalogar fontes encontradas:
   | # | Fonte | Tipo | Credibilidade | URL |
   |---|-------|------|---------------|-----|
```

**Regra:** Mínimo 3 buscas, máximo 5. Parar quando fontes começarem a repetir.

### Fase 2: ANALYZE (Leitura Profunda)

**Objetivo:** Extrair informação detalhada das melhores fontes.

```
AÇÕES:
1. Selecionar top 3-5 fontes por credibilidade (ver Source Quality Scoring)
2. WebFetch em cada fonte selecionada
3. Extrair claims verificáveis:
   - Fatos com dados concretos (números, datas, versões)
   - Afirmações técnicas (funciona/não funciona, suporta/não suporta)
   - Opiniões de especialistas (com atribuição)
4. Anotar contradições entre fontes
```

**Regra:** Nunca confiar em uma única fonte para claims críticos.

### Fase 3: REFINE (Refinamento Direcionado)

**Objetivo:** Resolver lacunas e contradições com buscas focadas.

```
AÇÕES:
1. Identificar gaps: O que ainda não foi respondido?
2. Identificar contradições: Fontes discordam em quê?
3. Formular queries específicas para resolver cada gap/contradição
4. WebSearch direcionado + WebFetch nas novas fontes
5. Se for documentação técnica: usar Context7 (resolve-library-id → query-docs)
```

**Regra:** Máximo 2 rodadas de refinamento. Se não resolver, rotular como `[Não verificado]`.

### Fase 4: TRIANGULATE (Síntese com Confiança)

**Objetivo:** Consolidar findings com nível de confiança por claim.

```
AÇÕES:
1. Para cada claim, contar fontes independentes:
   - 3+ fontes concordam → ✅ Verificado (confiança alta)
   - 2 fontes concordam → ⚠️ Provável (confiança média)
   - 1 fonte apenas → 🟡 Não triangulado (confiança baixa)
   - Fontes discordam → 🔴 Conflitante (reportar ambas versões)

2. Montar relatório final:
   ## Findings
   [Claims organizadas por confiança]

   ## Fontes
   [Lista com URLs e credibilidade]

   ## Gaps Não Resolvidos
   [O que ficou sem resposta]

   ## Contradições
   [Onde fontes discordam e por quê]
```

---

## 3. Source Quality Scoring

| Tier | Score | Exemplos | Uso |
|------|-------|----------|-----|
| **S — Oficial** | 1.0 | Docs oficiais, RFCs, specs, repos GitHub do autor | Base de verdade |
| **A — Especialista** | 0.8 | Blog do mantenedor, conferência oficial, paper peer-reviewed | Referência primária |
| **B — Comunidade** | 0.6 | Stack Overflow (aceito+votado), blog técnico respeitado, tutorial detalhado | Validação cruzada |
| **C — Genérico** | 0.4 | Blog genérico, Medium sem credenciais, tutorial superficial | Apenas pistas |
| **D — Suspeito** | 0.2 | Conteúdo gerado por IA sem revisão, fórum sem moderação, SEO spam | Evitar |

**Heurísticas de detecção:**
- **Data:** Fontes de 2024+ > fontes de 2022- (para tech)
- **Especificidade:** Código + exemplos > apenas texto conceitual
- **Atribuição:** Autor identificável > anônimo
- **Evidência:** Benchmarks/dados > opinião

---

## 4. Research Modes

### Mode: QUICK (1-2 min)
```
Quando: Pergunta factual simples, verificação rápida
Queries: 1-2 WebSearch
Depth: Sem WebFetch (snippets suficientes)
Output: Resposta direta + 2-3 fontes
```

### Mode: STANDARD (3-5 min)
```
Quando: Tema técnico, comparação, decisão de design
Queries: 3 WebSearch + 2-3 WebFetch
Depth: DART completo
Output: Relatório estruturado com findings + fontes
```

### Mode: DEEP (10+ min)
```
Quando: Pesquisa original, análise de mercado, auditoria técnica
Queries: 5+ WebSearch + 5+ WebFetch + Context7
Depth: DART com 2 rodadas de refinamento
Output: Relatório completo com triangulação, gaps, contradições
Execution: Usar subagentes para paralelizar buscas
```

---

## 5. Output Templates

### Template: Research Brief
```markdown
# 🔍 [Tema]
**Data:** DD/MM/YYYY | **Mode:** QUICK|STANDARD|DEEP | **Fontes:** N

## TL;DR
[2-3 frases com a conclusão principal]

## Findings
### ✅ Verificado (3+ fontes)
- [claim 1] — Fontes: [1], [2], [3]

### ⚠️ Provável (2 fontes)
- [claim 2] — Fontes: [1], [2]

### 🟡 Não Triangulado (1 fonte)
- [claim 3] — Fonte: [1]

## Fontes
| # | Título | Tier | URL |
|---|--------|------|-----|

## Gaps & Contradições
[Se houver]
```

### Template: Comparison Matrix
```markdown
# ⚖️ [Opção A] vs [Opção B] vs [Opção C]

| Critério | A | B | C | Fonte |
|----------|---|---|---|-------|
| [critério 1] | ✅ | ❌ | ⚠️ | [url] |

## Recomendação
[Com justificativa baseada nos dados]
```

---

## 6. Anti-Patterns

| Anti-Pattern | Por Que é Ruim | Fazer Isso |
|-------------|----------------|------------|
| Confiar na primeira fonte | Viés de confirmação | Sempre buscar 3+ fontes |
| Busca genérica demais | Resultados irrelevantes | Queries específicas com contexto |
| Ignorar contradições | Falsa confiança | Reportar ambas versões |
| Pesquisar infinitamente | Paralysis by analysis | Máximo 2 rodadas de refinamento |
| Copiar snippet sem verificar | Alucinação por proxy | WebFetch para ler fonte completa |
| Ignorar data da fonte | Info desatualizada | Priorizar fontes recentes (2024+) |

---

## 7. Integração com Ecossistema

### Crawl4AI (Opcional — Pesquisa em Escala)
Se instalado (`pip install crawl4ai`), habilita crawling profundo:
```python
from crawl4ai import AsyncWebCrawler
async with AsyncWebCrawler() as crawler:
    result = await crawler.arun(url="https://example.com")
    # result.markdown → conteúdo LLM-friendly
    # result.links → links para crawl recursivo
```
**Quando usar:** Crawling de domínio inteiro, extração estruturada em massa, scraping de múltiplas páginas.
**Não precisa para:** 90% das pesquisas (WebSearch + WebFetch cobrem).

### Com Outras Skills
- **`data-charts`** — Visualizar dados coletados
- **`mermaid-diagrams`** — Mapear relações entre conceitos
- **`minimax-pdf`** — Gerar relatório de pesquisa em PDF
- **`minimax-xlsx`** — Tabular dados comparativos em Excel
