# Profile: Automation & Integration

## Contexto
Perfil para trabalho com n8n, automações, integrações e workflows.

## Skills Prioritárias
- n8n (coordenador + 9 sub-skills)
- n8n-hardening — Resiliência de workflows
- api-forge — Integrações de API
- automations — Tarefas agendadas

## Ferramentas Ativas
- n8n-mcp (21 tools)
- Gmail MCP + Google Calendar MCP
- Slack MCP
- browser-use + agent-browser

## Regras Específicas
- Sempre validar workflows com `/n8n-hardening` antes de ativar
- Retry 3x obrigatório em todos os HTTP nodes
- Error handling em todo workflow (catch + notify)
- Credenciais NUNCA no código — sempre via n8n credentials
