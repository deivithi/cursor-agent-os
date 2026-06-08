# Network Access Control

## Modelo de Segurança

Claude Code roda **100% local**. Todo o processamento acontece na sua máquina. Não existe sandbox cloud — isso é uma vantagem de segurança, não uma limitação.

## Ferramentas com Acesso à Rede

| Ferramenta | Tipo de Acesso | Controle |
|-----------|---------------|---------|
| WebSearch | Busca web via API | Automático por contexto |
| WebFetch | HTTP GET público | URL explícita do usuário |
| browser-use | Navegação headless | Daemon local, sessões isoladas |
| agent-browser | Navegação CDP | Chrome local, perfil isolado |
| n8n workflows | HTTP nodes, webhooks | Configurado por workflow |
| Context7 | Docs de bibliotecas | Automático por contexto |
| MCP servers nativos | Gmail, Calendar, Notion, etc. | OAuth autenticado |
| gh CLI | GitHub API | Token autenticado |

## Ferramentas SEM Acesso à Rede

| Ferramenta | Escopo |
|-----------|--------|
| Read/Write/Edit | Filesystem local |
| Glob/Grep | Busca local |
| DuckDB | Processamento local |
| minimax-pdf/xlsx/pptx | Geração local |
| Scripts (.sh, .ps1) | Execução local |

## Controles Disponíveis

- **`/freeze`** — Modo read-only total (nenhuma escrita)
- **`/careful`** — Bloqueia operações destrutivas
- **Permissões** — `settings.local.json` controla quais ferramentas são auto-aprovadas
- **MCP servers** — `enabledMcpjsonServers` controla quais estão ativos
