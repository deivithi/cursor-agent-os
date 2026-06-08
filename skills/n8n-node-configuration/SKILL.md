---
name: n8n-node-configuration
description: >
  Guia de configuração de nodes n8n: dependências de propriedades, campos obrigatórios
  por operação, retry/timeout, e padrões por tipo de node.
domain: automation
subdomain: n8n-nodes
version: 1.0.0
author: deivithi
tags:
  - n8n
  - node-configuration
  - retry
  - timeout
  - credentials
---

# ⚙️ n8n Node Configuration

> **"Cada tipo de node tem configurações críticas que, se omitidas, causam falhas silenciosas."**

## 📁 File Structure
- `SKILL.md` — Você está aqui.

## 🔗 Related Skills
- `n8n-code-javascript` — Configuração específica de Code nodes
- `n8n-validation-expert` — Debug de configuração incorreta
- `n8n-workflow-patterns` — Qual node usar em cada padrão
- `n8n-mcp-tools-expert` — Como usar get_node para descobrir campos

---

## 🔍 Como Descobrir Campos de um Node

```
1. search_nodes({query: "telegram"})
   → Retorna nodeType e workflowNodeType

2. get_node({nodeType: "nodes-base.telegram", detail: "standard"})
   → Retorna todas as operações e campos obrigatórios

3. get_node({nodeType: "nodes-base.telegram", detail: "full"})
   → Retorna TUDO incluindo opções avançadas
```

**REGRA CRÍTICA — Dois formatos de nodeType:**
- `nodes-base.xxx` → para `search_nodes`, `get_node`, `validate_node`
- `n8n-nodes-base.xxx` → para `n8n_create_workflow`, `n8n_update_partial_workflow`
- `@n8n/n8n-nodes-langchain.xxx` → para nodes de IA em workflows

---

## 📋 Configurações por Tipo de Node

### 🔵 Trigger Nodes

| Node | Configuração Obrigatória |
|------|--------------------------|
| **Schedule Trigger** | `rule.interval[0].field` (minutes/hours/days), timezone |
| **Webhook** | `path`, `httpMethod`, `responseMode` |
| **Email Trigger (IMAP)** | Polling mode (não IDLE), credencial, mailbox |
| **Google Drive Trigger** | Polling interval, pasta, credencial OAuth2 |
| **Cron** | Expressão cron, timezone `America/Sao_Paulo` |

#### Schedule Trigger — Exemplos

```json
// A cada hora
{
  "type": "n8n-nodes-base.scheduleTrigger",
  "parameters": {
    "rule": {
      "interval": [{ "field": "hours", "hoursInterval": 1 }]
    }
  }
}

// Todo dia às 2h BRT
{
  "parameters": {
    "rule": {
      "interval": [{ "field": "cronExpression", "expression": "0 2 * * *" }]
    }
  }
}
```

---

### 🔵 HTTP & API Nodes

| Node | Config Obrigatória | Config Recomendada |
|------|--------------------|--------------------|
| **HTTP Request** | `url`, `method` | `timeout: 30000`, retry |
| **Webhook Response** | `respondWith`, `responseBody` | — |

#### HTTP Request — Template Completo

```json
{
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "parameters": {
    "url": "https://api.example.com/data",
    "method": "POST",
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        { "name": "key", "value": "={{ $json.value }}" }
      ]
    },
    "options": {
      "timeout": 30000,
      "allowUnauthorizedCerts": false
    }
  },
  "retryOnFail": true,
  "maxTries": 3,
  "waitBetweenTries": 5000
}
```

---

### 🔵 Messaging Nodes

| Node | Config Obrigatória | Limites |
|------|--------------------|---------|
| **Telegram** | `chatId`, `text`, credencial bot | 4096 chars/msg |
| **Slack** | `channel`, `text`, credencial OAuth | 4000 chars/msg |
| **Discord** | `webhookId`, `content` | 2000 chars/msg |
| **Email (SMTP)** | `to`, `subject`, `text`/`html` | ∞ (mas cuidado com spam filters) |

> ⚠️ **SEMPRE** adicionar Code node de splitting antes de messaging nodes se o texto pode exceder o limite.

---

### 🔵 Database Nodes

| Node | Config Obrigatória |
|------|--------------------|
| **Google Sheets** | `documentId`, `sheetName`, operação (`append`/`read`/`update`) |
| **Postgres** | `query` ou operação, credencial |
| **MySQL** | `query` ou operação, credencial |
| **MongoDB** | `collection`, operação, credencial |

---

### 🔵 Code & Command Nodes

| Node | Tipo no Workflow | Quando Usar |
|------|------------------|-------------|
| **Code** | `n8n-nodes-base.code` | Transformação de dados, lógica JS/Python |
| **Execute Command** | `n8n-nodes-base.executeCommand` | Shell, CLI, scripts externos, filesystem |

#### Execute Command — Template

```json
{
  "type": "n8n-nodes-base.executeCommand",
  "typeVersion": 1,
  "parameters": {
    "command": "={{ 'python3 /path/script.py \"' + $json.arg + '\"' }}"
  },
  "retryOnFail": true,
  "maxTries": 2,
  "waitBetweenTries": 10000
}
```

> ⚠️ **Execute Command é desabilitado por default no n8n v2.** Para habilitar, garantir que `NODES_EXCLUDE` não inclui `n8n-nodes-base.executeCommand`.

---

### 🔵 AI/LLM Nodes

| Node | Tipo no Workflow | Config Obrigatória |
|------|------------------|--------------------|
| **OpenAI** | `@n8n/n8n-nodes-langchain.openAi` | model, prompt, credencial |
| **Anthropic** | `@n8n/n8n-nodes-langchain.lmChatAnthropic` | model, credencial |
| **AI Agent** | `@n8n/n8n-nodes-langchain.agent` | model, tools, system prompt |
| **Chain LLM** | `@n8n/n8n-nodes-langchain.chainLlm` | model, prompt template |

> ⚠️ **chainLlm NÃO propaga campos upstream.** Sempre use `$("Node Name")` para acessar dados anteriores.

---

## 🔧 Retry & Error Handling — Referência

### Onde colocar retry (nível do NODE, não parameters!)

```json
{
  "type": "n8n-nodes-base.httpRequest",
  "parameters": { "url": "..." },
  "retryOnFail": true,
  "maxTries": 3,
  "waitBetweenTries": 5000
}
```

### Error handling options

| Opção | Efeito |
|-------|--------|
| `onError: "stopWorkflow"` | Para tudo (default) |
| `onError: "continueRegularOutput"` | Ignora erro, continua output 0 |
| `onError: "continueErrorOutput"` | Envia para output 1 (erro), output 0 fica vazio |
| `continueOnFail: true` | Legacy — equivale a `continueRegularOutput` |
| `alwaysOutputData: true` | Garante output mesmo sem items |

### Padrão recomendado para nodes críticos

```json
{
  "onError": "continueErrorOutput",
  "retryOnFail": true,
  "maxTries": 3,
  "waitBetweenTries": 5000
}
```
- Output 0 → sucesso → próximo node normal
- Output 1 → erro → node de alerta (Telegram/Slack)

---

## 🔀 IF Node — Configuração Correta

### Template seguro

```json
{
  "type": "n8n-nodes-base.if",
  "typeVersion": 2,
  "parameters": {
    "conditions": {
      "options": { "caseSensitive": false, "leftValue": "", "typeValidation": "loose" },
      "conditions": [{
        "id": "condition-1",
        "leftValue": "={{ $json.text }}",
        "rightValue": "",
        "operator": { "type": "string", "operation": "isNotEmpty" }
      }],
      "combinator": "and"
    }
  }
}
```

### Gotchas do IF node

1. **NUNCA** usar `typeValidation: "strict"` com `isNotEmpty` → rejeita dados válidos
2. **SEMPRE** usar `caseSensitive: false` para comparações de email
3. Para validação de output LLM, preferir expressão de comprimento:
   ```
   {{ $json.text.length > 50 }}
   ```

---

## 📋 Checklist Pré-Deploy por Node

Para cada node do workflow, verificar:

```
[ ] Tipo correto (n8n-nodes-base.xxx / @n8n/n8n-nodes-langchain.xxx)?
[ ] typeVersion mais recente?
[ ] Credencial associada (se necessário)?
[ ] Retry configurado (se chamada externa)?
[ ] Timeout adequado?
[ ] Error handling definido?
[ ] Expressões com optional chaining (?.)?
[ ] Splitting antes de messaging (se texto variável)?
```

---

## Regras Invioláveis

1. **NUNCA colocar retryOnFail dentro de parameters** — é propriedade do node
2. **NUNCA usar typeValidation strict em IF de validação** — causa false positives
3. **SEMPRE usar o formato correto de nodeType** para cada contexto (MCP tools vs workflow)
4. **SEMPRE verificar credenciais necessárias** ao criar/editar workflow
5. **SEMPRE usar get_node antes de configurar** — não assumir campos
