---
name: deep-research-workspace
description: Pesquisa profunda com orçamento de passos, citações obrigatórias, critérios de parada e relatório estruturado (paridade funcional com agentes tipo “deep research” comerciais). Ativa com deep research, relatório com fontes, síntese multi-fonte, due diligence rápida, landscape de mercado.
---

# Deep Research — workspace

## Quando usar

- Perguntas que exigem **múltiplas fontes** (web, papers, docs internos).
- **Temas instáveis** (preços, leis, versões de produto): segunda verificação obrigatória.
- Saída deve ser **auditável** (links ou `ficheiro:linha`).

## Orçamento (definir no início)

| Parâmetro | Valor sugerido | Notas |
|-----------|----------------|-------|
| `max_iterations` | 5–12 | Cada iteração = busca + leitura + notas. |
| `max_sources` | 8–25 | Fontes **primárias** preferíveis a agregadores. |
| `stop_when` | texto | Ex.: “3 fontes independentes concordam no facto X” ou “outline coberto”. |

Pare **antes** de esgotar o orçamento se `stop_when` for satisfeito.

## Fluxo

1. **Outline fixo** (abaixo) em rascunho — preencher títulos com base na pergunta.
2. **Coleta:** para cada lacuna do outline, buscar evidência (ferramentas adequadas ao `sources_policy` do TaskEnvelope).
   - Código / repo: `/smart-explore` ou leitura direcionada de ficheiros.
   - Web: MCP/search configurado no projeto (ex. Firecrawl skill, Tavily, fetch) — seguir regras do workspace.
   - Académico: alphaXiv MCP + quando aplicável `/science` e skills em `.claude/scientific-skills/`.
3. **Síntese:** só redigir afirmações fortes com citação imediata `(fonte)`.
4. **Segunda passagem** (temas instáveis): confirmar com fonte **oficial ou recente**; se divergir, documentar em “Conflitos resolvidos”.
5. **MoA-lite:** passagem **Reviewer** curta (gaps, vieses, contradições) → **Fusão** na entrega final.

## Estrutura obrigatória do relatório

```markdown
## Resumo executivo
## Pergunta e escopo
## Evidências
### [Subtema 1]
- Afirmação — [fonte](url) ou `path:linhas`
## Implicações
## Riscos e limitações
## Próximos passos
## Referências (lista consolidada)
## Não verificado
## Conflitos resolvidos (se MoA-lite)
```

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Fonte de pesquisa é o próprio codebase | `smart-explore` | Exploração progressiva de código em vez de web |
| Avaliação de qualidade dos outputs | `evals` | LLM-as-Judge para medir confiabilidade das fontes |
| Pesquisa conclui e precisa virar plano | `spec-planner` | Transformar findings em plano de implementação |
| Pesquisa requer acesso web avançado | `web-research` | Multi-source triangulation com WebSearch + WebFetch |
| Relatório final precisa de formato rico | `artifact-factory` | Pipeline PDF/PPTX com QA obrigatório |

---

## Audit Trail — Classificação de Claims

> Padrão absorvido do tinyfish-cookbook/kb-builder: classificar **cada claim** do relatório para tornar a auditoria rastreável.

Ao preencher a seção “Evidências”, classificar cada afirmação:

| Tag | Significado | Quando usar |
|-----|-------------|-------------|
| `FOUND` | Evidência direta em fonte primária | Dado concreto com URL/citação |
| `INFERRED` | Deduzido de múltiplas fontes indiretas | Padrão observado, sem declaração explícita |
| `CONFLICTING` | Fontes discordam entre si | Reportar ambas versões + fontes |
| `MISSING` | Lacuna — nenhuma fonte cobre | Documentar o que foi buscado sem sucesso |

**Formato no relatório:**
```markdown
### [Subtema]
- `FOUND` Afirmação X — [fonte](url)
- `INFERRED` Afirmação Y — baseado em [fonte1] + [fonte2]
- `CONFLICTING` Afirmação Z — [fonte1] diz A, [fonte2] diz B
- `MISSING` Não encontrado: [o que foi buscado]
```

**Regra:** Seção “Não verificado” do relatório deve listar todos os items `MISSING` + `INFERRED` com confiança < 0.7.

---

## Anti-patterns

- Resumir uma única fonte sem cruzar.
- Misturar opinião com facto sem rótulo.
- Continuar após `stop_when` só por “completismo”.
- Afirmação sem tag de classificação (FOUND/INFERRED/CONFLICTING/MISSING).

## Integração

- Envelope: [`.claude/references/task-envelope.md`](../../references/task-envelope.md)
- Avaliação contínua: `/evals` e [tasks/benchmarks/genspark-parity-benchmark.md](../../../tasks/benchmarks/genspark-parity-benchmark.md) (tarefa B1)
