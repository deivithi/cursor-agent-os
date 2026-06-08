---
name: artifact-factory
description: Pipeline único para relatório PDF, deck PPTX e landing web — outline, pesquisa opcional, draft, QA obrigatório e export. Ativa com gerar PDF e slides, entregar deck e relatório, landing + PDF, pacote de apresentação, artefatos múltiplos.
---

# Artifact Factory — PDF, PPTX, landing

## Pipeline (sempre nesta ordem)

1. **Outline** — secções/títulos aprovados (implícito se o utilizador já deu estrutura clara).
2. **Pesquisa (opcional)** — só se o conteúdo depender de factos externos; usar `/deep-research` ou busca mínima com citações.
3. **Draft** — conteúdo completo em Markdown intermédio quando útil.
4. **QA obrigatório** (checklist abaixo) — falhou → corrigir antes de export.
5. **Export** — escolher engine por tipo de artefato.

## Engines por tipo

| Artefato | Skill / comando | Notas |
|----------|-----------------|-------|
| PDF editorial | [minimax-pdf](../minimax-pdf/SKILL.md) | Qualidade visual e identidade. |
| PPTX | [pptx-generator](../pptx-generator/skills/ppt-orchestra-skill/SKILL.md) + [slide-making-skill](../pptx-generator/skills/slide-making-skill/SKILL.md) | Orquestrar deck; slides com PptxGenJS. |
| Slides web | `/frontend-slides` | Ver [go.md](../../commands/go.md). |
| Landing | `/landing-page-generator` | CRO + SEO conforme skill. |
| Planilhas | minimax-xlsx ou spreadsheet skill | Quando o pedido incluir dados tabulares. |

## Checklist de QA (bloqueante)

Antes de declarar “pronto”:

- [ ] **Overflow:** títulos/corpos sem texto cortado de forma absurda; slides sem parágrafos ilegíveis.
- [ ] **Contraste:** legibilidade básica (fundo/texto).
- [ ] **Links:** URLs internas/externas mencionadas não estão óbvias como placeholder quebrado (`example.com` substituído por real ou removido).
- [ ] **Números:** métricas têm fonte ou estão marcadas como hipotéticas / `[Não verificado]`.
- [ ] **UI web:** smoke manual ou `/browser` / product-verification quando for página crítica.

## Integração com `/go`

Pedidos que misturam **“relatório + deck + página”** devem ser roteados para esta skill e executados em **uma** sessão lógica (mesmo envelope TaskEnvelope com `artifacts_expected` múltiplos).

## Referências

- Verificação: [product-verification](../product-verification/SKILL.md)
- Envelope: [`.claude/references/task-envelope.md`](../../references/task-envelope.md)
- Benchmark: [tasks/benchmarks/genspark-parity-benchmark.md](../../../tasks/benchmarks/genspark-parity-benchmark.md) (B2–B4)
