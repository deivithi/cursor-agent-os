# Graphify — Knowledge Graph Estrutural do Codebase

> Ativa quando o contexto envolver arquitetura de codigo, dependencias, conexoes entre modulos ou analise de impacto.

## Quando ativar

Perguntas sobre: **dependencias**, **impacto de mudanca**, **o que depende de X**, **como A se conecta a B**, **modulos centrais**, **arquitetura do projeto**, **grafo de codigo**, **comunidades/clusters de codigo**.

## Comportamento

1. **Consultar o grafo ANTES de ler arquivos** — `query_graph` ou `get_neighbors` responde em milissegundos sem gastar tokens lendo codigo
2. **Ler arquivos so depois de identificar os relevantes** via grafo — economia massiva de contexto
3. **God nodes** para visao geral — os nos mais conectados sao o core do projeto
4. **Shortest path** para entender conexoes nao obvias entre modulos distantes

## Tools MCP disponiveis (graphify)

`query_graph`, `get_node`, `get_neighbors`, `shortest_path`, `god_nodes`, `get_community`, `graph_stats`

## Routing

- Estrutura/relacoes de CODIGO → graphify MCP (este)
- Relacoes de MEMORIA (projetos, skills, pessoas) → knowledge-graph / Memory MCP
- Conhecimento de MUNDO (pessoas, empresas) → gbrain MCP
