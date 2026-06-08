---
description: "Pesquisa iterativa estilo RAG em codebases grandes"
---

# Iterative Retrieval

Pedido do utilizador: **$ARGUMENTS**

## Processo

1. Tratar como investigação **multi-ficheiro** no repositório: hipóteses → grep/busca semântica → leitura de ficheiros → refinamento da pergunta.
2. Preferir `/smart-explore` para primeira passagem de mapa; depois afunilar com leitura direcionada.
3. Se o pedido envolver **factos externos** ou documentação fora do repo, combinar com `/deep-research` ou busca web conforme [`.claude/references/task-envelope.md`](../references/task-envelope.md).

## Saída

- Lista de ficheiros tocados com **papel** (origem de verdade, consumidor, config).
- Fluxo de dados ou chamadas em bullets ou diagrama mermaid curto.
- **Não verificado** para trechos não lidos.
