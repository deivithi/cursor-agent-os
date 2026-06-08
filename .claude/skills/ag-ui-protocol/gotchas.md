# Gotchas — AG-UI

## Confundir com MCP

- **MCP** expõe tools ao modelo no **contexto da sessão** (Cursor, IDE, etc.).
- **AG-UI** trata do **fluxo de eventos** entre o backend do agente e a **UI da aplicação**. São camadas ortogonais; uma app pode usar ambos.

## Confundir com A2A

- **A2A** endereça **dois agentes** (mensagens, agent-card, webhooks).
- **AG-UI** endereça **agente ↔ utilizador** (streaming, estado de UI, human-in-the-loop). Não misturar envelopes JSON A2A com o formato de eventos AG-UI sem uma camada de tradução explícita.

## n8n “a falar AG-UI”

- Workflows n8n não são clientes AG-UI por defeito. Expor AG-UI a partir de n8n implica **implementar** um endpoint que emita o stream de eventos correcto (ou usar um serviço intermédio), não assumir compatibilidade automática.

## Transporte e middleware

- O protocolo permite vários transportes; misturar **SSE** e **WebSocket** no mesmo desenho sem middleware documentado gera bugs de ordenação e reconexão. Escolher um transporte primário por ambiente ou usar a stack recomendada nos docs para o teu cliente (ex. CopilotKit).

## CopilotKit vs @ag-ui/client

- **CopilotKit** é o cliente 1st party listado no ecossistema AG-UI; `@ag-ui/client` é o SDK mais baixo nível. Para UIs novas, a escolha depende de produto (componentes prontos vs controlo fino) — ver `SKILL.md` e docs antes de fixar arquitectura.

## Versões NPM

- Pacotes `@ag-ui/*` em `0.0.x` mudam com frequência; **não** copiar versões de memória — usar `npm view` e `references/npm-pins.md`.
