---
paths: ["**/*.n8n.json", "**/n8n/**", "**/*workflow*"]
---

# n8n Workflow Rules

- SEMPRE usar MCP tools (n8n-mcp) — nunca curl/API manual
- NUNCA criar workflow one-shot — iterar: criar → validar → editar → validar → ativar
- Dois formatos de nodeType: `nodes-base.x` (search/validate) vs `n8n-nodes-base.x` (workflow)
- Credenciais são configuradas na UI — sempre listar quais nodes precisam de credencial
- HARDENING OBRIGATÓRIO após criar/modificar — executar `/n8n-hardening` automaticamente
- Preprocessar docs antes de LLMs — usar `/markitdown` ou strip HTML em Code nodes
- Consultar skill `/n8n-workflow-patterns` para arquitetura
- Consultar skill `/n8n-validation-expert` ao interpretar erros
