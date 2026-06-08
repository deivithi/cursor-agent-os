---
name: ag-ui-protocol
description: >
  AG-UI (Agent-User Interaction Protocol): protocolo orientado a eventos que padroniza como
  agentes expõem streams ricos a interfaces humanas (chat, generative UI, estado partilhado).
  Use quando o pedido envolver CopilotKit, @ag-ui/client, SSE/WebSocket para agentes, eventos
  AG-UI, integração LangGraph/Mastra com UI, ou alinhar frontend com backends agenticos.
domain: infrastructure
subdomain: agent-ui-protocol
version: 1.0.0
author: deivithi
tags:
  - ag-ui
  - agent-ui
  - copilotkit
  - streaming
  - generative-ui
  - events
  - langgraph
---

# AG-UI — Agent-User Interaction Protocol

> **Fronteira:** MCP dá *ferramentas* ao agente; A2A liga *agente a agente*; **AG-UI** liga *agente à interface humana* (eventos, estado, UI generativa).

## File structure

| Ficheiro | Conteúdo |
|----------|----------|
| `SKILL.md` | Este ficheiro — visão geral e quando carregar referências |
| `references/protocol-stack.md` | Como MCP + A2A + AG-UI se encaixam neste workspace |
| `references/npm-pins.md` | Versões NPM oficiais registadas e comando de refresh |
| `references/links-oficiais.md` | Docs, repositório, Dojo, quickstarts |
| `gotchas.md` | Erros comuns de desenho |

## Related skills

- `a2a-protocol` — interop agente–agente (não substitui AG-UI)
- `spec-driven-core` — épico/plano antes de integrações grandes na UI

## O que é AG-UI (resumo)

- Fluxo **event-driven**: backends emitem eventos compatíveis com os tipos standard do protocolo; clientes consomem e renderizam (texto, ferramentas, estado, UI estruturada).
- **Transporte flexível:** SSE, WebSocket, webhooks, etc., com camada de middleware para compatibilidade.
- **SDKs NPM:** `@ag-ui/core` (tipos/eventos), `@ag-ui/client` (cliente, ex. `HttpAgent`, subscribers).
- **Scaffolding:** `npx create-ag-ui-app@latest` para novas apps de referência ([quickstart](https://docs.ag-ui.com/quickstart/applications)).

## MCP vs A2A vs AG-UI

| Camada | Pergunta que responde | Onde aparece aqui |
|--------|----------------------|-------------------|
| **MCP** | Como o agente acede a dados/APIs como tools? | Servidores MCP no Cursor; skills que documentam tools |
| **A2A** | Como dois agentes trocam mensagens tipadas? | `.claude/skills/a2a-protocol/` (ex.: n8n, envelopes) |
| **AG-UI** | Como o agente conversa com o utilizador na app? | Futuras UIs agenticas; docs em `references/` |

## Implementação de referência — Aria (ativo desde 03/04/2026)

**Aria** (`Aria/`) é a implementação live do protocolo AG-UI neste workspace:

| Camada | Arquivo | Função |
|--------|---------|--------|
| Backend | `Aria/backend/src/routes/agui.ts` | Endpoint SSE `POST /api/agui/stream` — emite 7 tipos de eventos AG-UI |
| Frontend | `Aria/frontend/src/hooks/useAgentStream.ts` | Hook React que consome o stream via `fetch` + `ReadableStream` |
| UI | `Aria/frontend/src/pages/Chat.tsx` | `handleSend` usa o hook; placeholder aparece imediatamente em `RUN_STARTED` |

**Sequência de eventos por turno:**
```
RUN_STARTED → TEXT_MESSAGE_START → TEXT_MESSAGE_CONTENT → TEXT_MESSAGE_END
  → [STATE_SNAPSHOT se queuedActionId] → RUN_FINISHED
```

**Pacotes instalados:**
- `Aria/backend`: `@ag-ui/core@0.0.50`
- `Aria/frontend`: `@ag-ui/core@0.0.50` + `@ag-ui/client@0.0.50`

> **Estratégia atual:** SSE wrapper (orquestrador não-streaming). Phase 2 futura: `stream: true` no `ai.chat.completions.create` para deltas token-a-token.

> **n8n** não tem suporte nativo AG-UI — ver `gotchas.md` se precisar de bridge.

## Progressive disclosure

1. Ler `references/protocol-stack.md` se o pedido cruzar MCP, A2A e UI.
2. Consultar `references/links-oficiais.md` para spec e tutoriais.
3. Antes de fixar versões em código, alinhar com `references/npm-pins.md`.
