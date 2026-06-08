---
name: graphify
description: >
  Knowledge graph estrutural do codebase via AST (tree-sitter). 8800+ nos, 14800+ arestas,
  246 comunidades. MCP server com 7 tools para queries de relacoes, impacto e navegacao.
  Ativacao automatica quando o contexto envolve conexoes, dependencias ou arquitetura de codigo.
domain: developer-tools
subdomain: code-intelligence
version: 1.0.0
author: deivithi
tags:
  - knowledge-graph
  - codebase
  - architecture
  - dependencies
  - impact-analysis
  - tree-sitter
  - mcp
---

# Graphify — Knowledge Graph Estrutural do Codebase

> **"Pergunte sobre conexoes — o grafo responde em milissegundos, sem ler arquivos."**

## File Structure
- `SKILL.md` — Voce esta aqui. Workflow e triggers.
- `gotchas.md` — Problemas conhecidos (criar quando necessario).

## Related Skills
- `codebase-graph` — Complementar: analise LLM-native pontual (sem persistencia)
- `knowledge-graph` — Memory MCP para relacoes semanticas de memoria (nao codigo)
- `gbrain` — Knowledge base de mundo (pessoas, empresas, conceitos)
- `smart-explore` — Exploracao progressiva que pode alimentar o grafo
- `iterative-retrieval` — Pesquisa profunda em codigo (complementar)

---

## 1. Overview

### O que esta skill faz

Expoe um knowledge graph persistente do codebase via MCP server com 7 tools:

| Tool MCP | O que faz | Quando usar |
|----------|-----------|-------------|
| `query_graph` | Busca BFS/DFS por pergunta natural | "o que conecta X a Y?", "funcoes relacionadas a auth" |
| `get_node` | Detalhes de um no especifico | "me fale sobre UserService" |
| `get_neighbors` | Vizinhos diretos de um no | "o que depende de prisma?" |
| `shortest_path` | Caminho mais curto entre dois conceitos | "como auth se conecta ao database?" |
| `god_nodes` | Nos mais conectados (core abstractions) | "quais sao os modulos centrais?" |
| `get_community` | Todos os nos de uma comunidade | "o que esta no cluster do auth?" |
| `graph_stats` | Estatisticas do grafo | "tamanho do grafo, comunidades" |

### Numeros atuais

- **8.889 nos** (arquivos, classes, funcoes, imports)
- **14.858 arestas** (imports, extends, calls, composes)
- **246 comunidades** (Leiden clustering, sem embeddings)
- **100% AST local** — zero tokens gastos na construcao
- **Auto-rebuild** no fim de cada sessao (hook Stop)

### Quando usar

| Cenario | Esta skill |
|---------|------------|
| "O que depende desse modulo?" | `get_neighbors` |
| "Impacto de mudar X?" | `get_neighbors` + `shortest_path` |
| "Quais os modulos centrais?" | `god_nodes` |
| "Como A se conecta a B?" | `shortest_path` |
| "Arquitetura geral do projeto" | `graph_stats` + `god_nodes` |
| "O que esta nesse cluster?" | `get_community` |
| Busca de texto em arquivo | NAO usar — use Grep |
| Leitura de conteudo | NAO usar — use Read |

### Ativacao automatica

Quando o contexto envolver: **conexoes entre modulos**, **dependencias**, **impacto de mudanca**, **arquitetura de codigo**, **grafo**, **o que depende de**, **como X se relaciona com Y**, **modulos centrais** — usar as MCP tools do graphify ANTES de ler arquivos individuais.

---

## 2. Workflow

### Query simples
```
1. Usar query_graph com a pergunta do usuario
2. Se precisar de mais detalhe: get_node ou get_neighbors
3. Apresentar resultado estruturado
```

### Analise de impacto
```
1. get_neighbors(label="ModuloAlvo") — dependencias diretas
2. Para cada vizinho critico: get_neighbors novamente (2o hop)
3. shortest_path entre ModuloAlvo e modulos distantes suspeitos
4. Consolidar: lista de impacto por distancia (1 hop = alto, 2+ = medio)
```

### Onboarding em projeto
```
1. graph_stats — visao geral (nos, arestas, comunidades)
2. god_nodes(top_n=10) — core abstractions
3. get_community para as maiores comunidades
4. Apresentar mapa conceitual do projeto
```

---

## 3. Infraestrutura

- **Venv:** `~/.graphify-env/` (Python 3.12, tree-sitter + networkx + mcp)
- **Graph:** `graphify-out/graph.json` (9.2 MB, NetworkX JSON)
- **MCP:** Configurado em `.mcp.json` como stdio server
- **Rebuild:** Hook Stop executa `graphify-rebuild.sh` (incremental, background)
- **Report:** `graphify-out/GRAPH_REPORT.md` (god nodes + comunidades)

---

## 4. Anti-Patterns

| Anti-Pattern | Correto |
|-------------|---------|
| Usar graphify para buscar texto em arquivo | Usar Grep |
| Usar graphify para ler conteudo de funcao | Usar Read |
| Rebuild manual do grafo | Automatico via hook Stop |
| Ignorar o grafo e ler 50 arquivos | Consultar grafo primeiro, ler so os relevantes |
| Confundir com knowledge-graph (memoria) | Este e para CODIGO, aquele para MEMORIA |
