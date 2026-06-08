---
name: a2a-protocol
description: >
  Protocolo de interoperabilidade Agent-to-Agent entre Claude Code e n8n. Define JSON envelope
  padronizado, agent-card para discovery, handshake protocol e message routing. Permite que
  agentes Claude Code disparem workflows n8n e vice-versa com contrato tipado. Use para
  orquestração multi-agente, delegação de tarefas entre Claude Code e n8n, ou integração
  de resultados entre domínios.
domain: infrastructure
subdomain: agent-interop
version: 1.0.0
author: deivithi
tags:
  - a2a
  - agent-to-agent
  - interop
  - n8n
  - protocol
  - json-envelope
  - agent-card
---

# 🔗 A2A Protocol — Interop Claude Code <-> n8n

> **"Agentes que não se comunicam são silos inteligentes — o valor está na orquestração."**

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Protocol abaixo.
- `references/envelope-schema.md` — JSON Schema completo do envelope A2A.
- `references/agent-card-spec.md` — Especificação do agent-card.
- `gotchas.md` — Problemas conhecidos de interop.

## 🔗 Related Skills
- `ag-ui-protocol` — **Fronteira:** A2A = agente–agente; AG-UI = agente–interface humana (eventos, UI). Não substituem um ao outro.
- `autonomous-agent-loop` — Loop que usa A2A para delegar tarefas ao n8n
- `error-alerting` — Alertas quando mensagens A2A falham
- `agent-builder` — Construção de agentes que implementam o protocolo A2A

---

## 🎯 O Problema

Claude Code e n8n são dois runtime de agentes com capacidades complementares:

| Capacidade | Claude Code | n8n |
|-----------|-------------|-----|
| Raciocínio complexo | ✅ Excelente | ❌ Limitado |
| Agendamento cron | ❌ Não nativo | ✅ Nativo |
| Integrações (APIs) | Via MCP tools | ✅ 400+ nodes |
| Execução contínua | ❌ Sessão finita | ✅ 24/7 |
| Git/código | ✅ Nativo | ❌ Limitado |

**Sem protocolo:** Comunicação ad-hoc via webhooks sem contrato, sem tipagem, sem retry.
**Com A2A:** Envelope padronizado, discovery via agent-card, routing automático.

---

## 📨 1. JSON Envelope — Formato da Mensagem

### 1.1 Estrutura

```json
{
  "a2a_version": "1.0",
  "message_id": "msg_20260323_205500_abc123",
  "timestamp": "2026-03-23T20:55:00-03:00",
  "sender": {
    "agent_id": "claude-code",
    "agent_type": "reasoning",
    "capabilities": ["code", "analysis", "review"]
  },
  "receiver": {
    "agent_id": "n8n-scheduler",
    "agent_type": "automation",
    "endpoint": "http://localhost:5678/webhook/a2a-inbox"
  },
  "intent": "execute_task",
  "priority": "normal",
  "payload": {
    "task": "evaluate-skill",
    "params": {
      "skill_name": "lead-audit",
      "mode": "full"
    }
  },
  "reply_to": null,
  "correlation_id": "session_harness_20260323",
  "ttl_seconds": 3600,
  "require_ack": true
}
```

### 1.2 Campos obrigatórios

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `a2a_version` | string | Versão do protocolo (semver) |
| `message_id` | string | UUID único da mensagem |
| `timestamp` | string | ISO 8601 com timezone BRT |
| `sender.agent_id` | string | Identificador do agente emissor |
| `receiver.agent_id` | string | Identificador do agente receptor |
| `intent` | string | Ação solicitada (ver tabela de intents) |
| `payload` | object | Dados da requisição (schema varia por intent) |

### 1.3 Intents suportados

| Intent | Direção | Descrição |
|--------|---------|-----------|
| `execute_task` | Claude → n8n | Dispara execução de workflow |
| `report_result` | n8n → Claude | Retorna resultado de execução |
| `health_check` | Bidirecional | Verifica se agente está vivo |
| `query_status` | Claude → n8n | Consulta status de execução |
| `schedule_task` | Claude → n8n | Agenda tarefa para execução futura |
| `cancel_task` | Claude → n8n | Cancela tarefa agendada |
| `notify` | n8n → Claude | Notificação assíncrona (alerta, resultado) |

---

## 🪪 2. Agent Card — Discovery & Capabilities

### 2.1 Estrutura

Cada agente publica um agent-card que descreve suas capabilities:

```json
{
  "agent_id": "claude-code",
  "agent_type": "reasoning",
  "name": "Claude Code — Ouroboros System",
  "version": "1.0.0",
  "description": "Agente de raciocínio com acesso a código, MCP tools e skills",
  "capabilities": [
    "code-review",
    "skill-evaluation",
    "git-operations",
    "file-manipulation",
    "analysis",
    "planning"
  ],
  "supported_intents": [
    "execute_task",
    "report_result",
    "health_check"
  ],
  "endpoints": {
    "inbox": null,
    "webhook_callback": "http://localhost:5678/webhook/claude-callback"
  },
  "constraints": {
    "max_payload_bytes": 1048576,
    "max_concurrent_tasks": 5,
    "timeout_seconds": 300,
    "requires_auth": false
  },
  "metadata": {
    "owner": "deivithi",
    "environment": "local",
    "updated_at": "2026-03-23T20:55:00-03:00"
  }
}
```

### 2.2 Agent Card do n8n

```json
{
  "agent_id": "n8n-scheduler",
  "agent_type": "automation",
  "name": "n8n Automation Platform",
  "version": "2.40.0",
  "description": "Plataforma de automação com 400+ nodes, cron scheduling e webhooks",
  "capabilities": [
    "cron-scheduling",
    "webhook-processing",
    "api-integration",
    "data-transformation",
    "telegram-notifications",
    "email-sending"
  ],
  "supported_intents": [
    "execute_task",
    "schedule_task",
    "cancel_task",
    "query_status",
    "health_check"
  ],
  "endpoints": {
    "inbox": "http://localhost:5678/webhook/a2a-inbox",
    "health": "http://localhost:5678/healthz",
    "api": "http://localhost:5678/api/v1"
  },
  "constraints": {
    "max_payload_bytes": 5242880,
    "max_concurrent_tasks": 20,
    "timeout_seconds": 600,
    "requires_auth": true,
    "auth_header": "X-N8N-API-KEY"
  }
}
```

---

## 🤝 3. Handshake Protocol

### 3.1 Fluxo

```
Claude Code                          n8n
    │                                 │
    ├── health_check ───────────────▶ │
    │                                 ├── ACK (capabilities)
    │ ◀──────────────────────────────┤
    │                                 │
    ├── execute_task ───────────────▶ │
    │   (payload: evaluate lead-audit)│
    │                                 ├── ACK (task_id: t_001)
    │ ◀──────────────────────────────┤
    │                                 │
    │        [n8n executa workflow]    │
    │                                 │
    │                                 ├── report_result
    │ ◀──────────────────────────────┤
    │   (result: score 0.82, KEEP)    │
    ├── ACK ─────────────────────────▶│
    │                                 │
```

### 3.2 Implementação — Claude Code → n8n

```bash
# Enviar mensagem A2A para n8n via webhook
send_a2a_message() {
  local INTENT="$1"
  local PAYLOAD="$2"
  local ENDPOINT="${3:-http://localhost:5678/webhook/a2a-inbox}"
  local MSG_ID="msg_$(date +%Y%m%d_%H%M%S)_$(head -c 4 /dev/urandom | xxd -p)"

  local ENVELOPE=$(python3 -c "
import json
from datetime import datetime
msg = {
    'a2a_version': '1.0',
    'message_id': '$MSG_ID',
    'timestamp': datetime.now().astimezone().isoformat(),
    'sender': {'agent_id': 'claude-code', 'agent_type': 'reasoning'},
    'receiver': {'agent_id': 'n8n-scheduler', 'agent_type': 'automation'},
    'intent': '$INTENT',
    'priority': 'normal',
    'payload': json.loads('$PAYLOAD'),
    'require_ack': True,
    'ttl_seconds': 3600
}
print(json.dumps(msg))
")

  # Enviar com retry (3 tentativas, backoff exponencial)
  local MAX_RETRIES=3
  local RETRY=0

  while [ $RETRY -lt $MAX_RETRIES ]; do
    RESPONSE=$(curl -s -w "\n%{http_code}" \
      -X POST "$ENDPOINT" \
      -H "Content-Type: application/json" \
      -d "$ENVELOPE" \
      --connect-timeout 10 \
      --max-time 30)

    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    BODY=$(echo "$RESPONSE" | head -n -1)

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "202" ]; then
      echo "$BODY"
      return 0
    fi

    RETRY=$((RETRY + 1))
    sleep $((2 ** RETRY))
  done

  echo "{\"error\": \"Failed after $MAX_RETRIES retries\", \"last_status\": $HTTP_CODE}"
  return 1
}
```

### 3.3 Implementação — n8n Receiver (Code node)

```javascript
// n8n Code node — A2A Inbox Handler
const message = $input.first().json;

// Validar envelope
if (!message.a2a_version || !message.intent || !message.payload) {
  return [{
    json: {
      error: 'Invalid A2A envelope',
      required: ['a2a_version', 'intent', 'payload'],
      received: Object.keys(message)
    }
  }];
}

// Router por intent
const HANDLERS = {
  'execute_task': () => ({
    action: 'route_to_workflow',
    task: message.payload.task,
    params: message.payload.params,
    correlation_id: message.correlation_id
  }),
  'health_check': () => ({
    status: 'healthy',
    agent_id: 'n8n-scheduler',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  }),
  'query_status': () => ({
    action: 'check_execution',
    execution_id: message.payload.execution_id
  }),
  'cancel_task': () => ({
    action: 'cancel_execution',
    execution_id: message.payload.execution_id
  })
};

const handler = HANDLERS[message.intent];

if (!handler) {
  return [{
    json: {
      error: `Unknown intent: ${message.intent}`,
      supported: Object.keys(HANDLERS)
    }
  }];
}

return [{
  json: {
    ack: true,
    message_id: message.message_id,
    ...handler()
  }
}];
```

---

## 🔀 4. Message Routing

### Claude Code → n8n (via webhook)

```
Claude Code CLI
    │
    ├─ send_a2a_message("execute_task", {...})
    │
    ▼
n8n Webhook Trigger (POST /webhook/a2a-inbox)
    │
    ├─ A2A Inbox Handler (Code node) — valida + roteia
    │
    ├─ Switch node (por intent)
    │   ├─ execute_task → Sub-workflow correspondente
    │   ├─ health_check → Responde imediatamente
    │   └─ query_status → Consulta execução
    │
    └─ Respond to Webhook (ACK)
```

### n8n → Claude Code (via file drop)

```
n8n Workflow (resultado pronto)
    │
    ├─ Write File node → .claude/data/a2a-inbox/{correlation_id}.json
    │
    ▼
Claude Code (próxima sessão ou polling)
    │
    ├─ Lê .claude/data/a2a-inbox/*.json
    ├─ Processa resultados
    └─ Move para .claude/data/a2a-processed/
```

---

## ✅ Quality Checklist

Antes de considerar o protocolo A2A operacional, verificar:

- [ ] Envelope JSON segue schema com todos os campos obrigatórios
- [ ] Health check bidirecional funciona (Claude → n8n e n8n → file drop)
- [ ] Webhook n8n recebe e parseia envelope corretamente
- [ ] Tarefas longas retornam ACK imediato (< 5s) e resultado via file drop
- [ ] Deduplicação por `message_id` ativa no receptor
- [ ] Timestamps sempre com timezone explícito (BRT -03:00)
- [ ] Retry com backoff exponencial (3 tentativas, 2/4/8s)
- [ ] Agent cards atualizados com capabilities corretas

---

## ⚠️ Gotchas

1. **n8n webhook timeout** — Default 30s. Tarefas longas devem retornar ACK imediato e enviar resultado via file drop.
2. **Payload size limit** — n8n webhook aceita ~5MB. Para dados maiores, usar referência a arquivo.
3. **Timezone mismatch** — SEMPRE usar ISO 8601 com timezone explícito. Nunca UTC sem offset.
4. **Auth em produção** — Webhook sem auth é vetor de ataque. Usar `X-A2A-Token` header com secret compartilhado.
5. **Idempotência** — `message_id` garante que re-envios não executem a tarefa duas vezes. Receptor deve deduplicar por `message_id`.
