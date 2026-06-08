# Pilha de protocolos no workspace

Este repositório usa várias camadas de “contrato” entre sistemas e utilizador. **Não são substitutas** — combinam-se.

## Visão rápida

1. **MCP (Model Context Protocol)** — liga modelos/agentes a **ferramentas** e recursos (APIs, ficheiros, serviços). Configuração típica: `.cursor/mcp.json`, servidores MCP, política em `.cursor/MCP_AND_HOOKS_POLICY.md` quando aplicável.

2. **A2A (Agent-to-Agent)** — mensagens **entre agentes** (ex.: Claude Code ↔ n8n) com envelope JSON, agent-card e routing. Skill: `.claude/skills/a2a-protocol/`.

3. **AG-UI (Agent-User Interaction)** — **eventos e estado** entre o runtime do agente e a **interface humana** (browser, CopilotKit, terminal cliente AG-UI). Skill: `.claude/skills/ag-ui-protocol/`.

## Ordem mental de desenho

- O agente usa **MCP** para actuar no mundo (tools).
- Orquestra com outros agentes via **A2A** quando necessário.
- Expõe resultados e pedidos de confirmação ao utilizador via **AG-UI** (streams, generative UI, shared state).

## O que AG-UI não faz

- Não define o formato A2A (isso continua no envelope A2A).
- Não substitui MCP servers (são camadas diferentes).
- **n8n** não emite AG-UI nativamente; uma ponte HTTP/SSE customizada seria desenho de integração explícito, não “suporte built-in”.
