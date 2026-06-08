# Gotchas — knowledge-graph

## 1. Memory MCP graph é volátil
- **Sintoma:** Graph vazio após reiniciar o MCP server
- **Fix:** O graph persiste em arquivo JSON local (~/.claude/memory/), mas se o MCP for reinstalado, pode perder dados
- **Mitigação:** Flat files (MEMORY.md) são a fonte de verdade. Graph é camada de relações reconstruível

## 2. Nomes de entidades são case-sensitive
- **Sintoma:** "Aria" e "aria" são entidades diferentes
- **Fix:** Sempre usar PascalCase para entidades (Aria, Febracis, Supabase)
- **Convenção:** Pessoas em PascalCase (Deivithi), tools em lowercase (n8n, supabase)

## 3. Relações não têm peso ou score
- **Sintoma:** Não dá para diferenciar "usa muito" de "usa pouco"
- **Fix:** Usar observations na entidade para qualificar: "primary tool" vs "occasional"
- **Alternativa:** Se crítico, criar relation types mais específicos (primary_tool, secondary_tool)

## 4. Graph sem limites cresce indefinido
- **Sintoma:** Centenas de entidades tornando busca lenta e resultados ruidosos
- **Fix:** Manter máximo ~100 entidades ativas. Entidades de projetos concluídos/abandonados → deletar
- **Regra:** Em cada `/recap`, verificar se há entidades obsoletas

## 5. read_graph() carrega TUDO
- **Sintoma:** Para graphs grandes, read_graph() retorna muito dado
- **Fix:** Preferir search_nodes(query) para buscas focadas. Usar read_graph() apenas para visão geral ou health check
