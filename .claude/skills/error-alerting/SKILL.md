---
name: error-alerting
description: >
  Configure universal error alerting for n8n workflows. Error Workflow pattern,
  node-level error handling, Telegram alerts with context (workflow name, node,
  timestamp BRT, error message). Use when setting up monitoring, adding error
  handling, or diagnosing silent failures.
domain: automation
subdomain: observability
version: 1.0.0
author: deivithi
tags:
  - n8n
  - error-handling
  - alerting
  - telegram
  - monitoring
  - observability
  - resilience
---

# 🚨 Error Alerting — Alertas de Erro para Workflows n8n

> **"Workflow silencioso que falha é pior que workflow inexistente — você confia em algo que não funciona."**

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Workflow abaixo.
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.
- `references/alert-templates.md` — Templates de mensagens para diferentes cenários de erro.

## 🔗 Related Skills
- `runbook` — Investigação de problemas pós-alerta
- `n8n-hardening` — Auditoria completa de resiliência (retry, guards, splits)
- `cyber` → `incident-response` — Quando o alerta indica incidente de segurança

---

## 1. Workflow — 4 Etapas

```
DETECTAR → PROPOR → APLICAR → VALIDAR
```

### 1.1 Detectar — Nodes sem tratamento de erro

Usar n8n MCP para listar workflows e identificar gaps:

```bash
# Via n8n MCP: listar todos os workflows ativos
n8n_list_workflows → filtrar status: active

# Para cada workflow: inspecionar nodes
n8n_get_workflow(id) → verificar:
  - settings.errorWorkflow está definido?
  - Cada node tem onError configurado?
  - Existe Error Trigger no workflow de erro?
```

**Checklist de detecção:**
- [ ] Workflow tem `errorWorkflow` definido nas settings?
- [ ] O workflow de erro referenciado existe e está ATIVO?
- [ ] Nodes críticos (HTTP Request, API calls, LLM) têm `onError` configurado?
- [ ] Nodes com `continueRegularOutput` têm guard nodes downstream?

### 1.2 Propor — Error Branches e Error Workflow

**Dois níveis de tratamento:**

#### Nível 1: Error Workflow (workflow-level)

Captura QUALQUER erro não tratado no workflow inteiro. É a rede de segurança final.

```
[Error Trigger] → [Format Message] → [Telegram Send]
```

Configuração no workflow principal:
```json
{
  "settings": {
    "errorWorkflow": "ID_DO_WORKFLOW_DE_ERRO"
  }
}
```

#### Nível 2: Node-level error handling (onError)

Para nodes específicos que precisam de tratamento granular:

| Opção | Comportamento | Quando Usar |
|-------|--------------|-------------|
| `stopWorkflow` | Para execução, dispara Error Workflow | Erros críticos (pagamento, dados obrigatórios) |
| `continueRegularOutput` | Continua com dados vazios na saída regular | Erros toleráveis (enriquecimento opcional) |
| `continueErrorOutput` | Continua por uma branch de erro separada | Tratamento customizado (fallback, retry manual) |

**Recomendação padrão:**
- Nodes de **integração externa** (HTTP, API, LLM): `continueErrorOutput` → branch de alerta
- Nodes de **transformação de dados**: `stopWorkflow` (dados corrompidos não devem propagar)
- Nodes **opcionais** (enriquecimento, lookup): `continueRegularOutput` + guard node

### 1.3 Aplicar — Via n8n MCP

```bash
# 1. Criar o Error Workflow (se não existir)
n8n_create_workflow({
  name: "⚠️ Error Handler Global",
  nodes: [ErrorTrigger, FormatMessage, TelegramSend],
  active: true  # OBRIGATÓRIO — workflow inativo não recebe erros
})

# 2. Configurar errorWorkflow em cada workflow ativo
n8n_update_partial_workflow(id, {
  settings: { errorWorkflow: "ID_ERROR_HANDLER" }
})

# 3. Adicionar onError nos nodes críticos
n8n_update_full_workflow(id, {
  # Atualizar nodes específicos com onError config
})
```

### 1.4 Validar — Testar o circuito completo

```bash
# 1. Executar workflow com input que força erro
n8n_test_workflow(id, { testData: "dado_invalido" })

# 2. Verificar execução do Error Workflow
n8n_executions({ workflowId: "ID_ERROR_HANDLER", limit: 1 })

# 3. Confirmar que mensagem chegou no Telegram
# → Verificar chat do bot manualmente ou via API
```

**Critérios de aceite:**
- [ ] Erro no workflow principal dispara Error Workflow
- [ ] Mensagem no Telegram contém: nome do workflow, node, timestamp BRT, mensagem de erro
- [ ] Erros em nodes com `continueRegularOutput` NÃO disparam alerta (são tolerados)
- [ ] Erros em nodes com `continueErrorOutput` seguem pela branch correta

---

## 2. Error Workflow — Arquitetura de Referência

```
┌─────────────────┐     ┌──────────────────┐     ┌────────────────┐
│  Error Trigger   │────▶│  Format Message   │────▶│ Telegram Send  │
│                  │     │  (Code node)      │     │ (Bot API)      │
└─────────────────┘     └──────────────────┘     └────────────────┘
```

### Error Trigger Node

Recebe automaticamente o objeto de erro com:
- `execution.id` — ID da execução que falhou
- `workflow.id` / `workflow.name` — Workflow de origem
- `execution.error.message` — Mensagem de erro
- `execution.error.node` — Node que falhou
- `execution.lastNodeExecuted` — Último node executado

### Format Message — Code Node (JavaScript)

```javascript
// Converter UTC → BRT (America/Sao_Paulo)
const now = new Date();
const brt = now.toLocaleString('pt-BR', {
  timeZone: 'America/Sao_Paulo',
  day: '2-digit',
  month: '2-digit',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit'
});

const errorData = $input.first().json;

// Truncar mensagem de erro para respeitar limite Telegram (4096 chars)
const errorMsg = (errorData.execution?.error?.message || 'Erro desconhecido').substring(0, 2000);
const nodeName = errorData.execution?.error?.node?.name || errorData.execution?.lastNodeExecuted || 'Desconhecido';
const workflowName = errorData.workflow?.name || 'Workflow sem nome';
const workflowId = errorData.workflow?.id || 'N/A';
const executionId = errorData.execution?.id || 'N/A';

const message = `🚨 *ERRO em Workflow n8n*

📋 *Workflow:* ${workflowName}
🔗 *ID:* \`${workflowId}\`
🆔 *Execução:* \`${executionId}\`
⚙️ *Node:* ${nodeName}
🕐 *Horário (BRT):* ${brt}

❌ *Erro:*
\`\`\`
${errorMsg}
\`\`\`

🔍 [Ver execução](${$env.N8N_HOST || 'http://localhost:5678'}/workflow/${workflowId}/executions/${executionId})`;

return [{ json: { message, chatId: $env.TELEGRAM_CHAT_ID || '-CHAT_ID' } }];
```

### Telegram Send Node

- **Credencial:** Telegram Bot API (token do bot)
- **Chat ID:** Variável de ambiente `TELEGRAM_CHAT_ID` ou hardcoded
- **Parse Mode:** MarkdownV2
- **Texto:** `{{ $json.message }}`

---

## 3. Template de Mensagem de Alerta

Ver `references/alert-templates.md` para templates específicos por cenário.

**Campos obrigatórios em TODO alerta:**

| Campo | Fonte | Obrigatório |
|-------|-------|:-----------:|
| Nome do workflow | `workflow.name` | ✅ |
| Node que falhou | `execution.error.node` | ✅ |
| Timestamp BRT | Conversão UTC-3 | ✅ |
| Mensagem de erro | `execution.error.message` | ✅ |
| Link para execução | URL construída | ✅ |
| ID da execução | `execution.id` | Recomendado |

---

## 4. Anti-Patterns — O que NÃO fazer

### ❌ 4.1 Alertas genéricos sem contexto

```
# ERRADO — não ajuda ninguém
"Erro no n8n"

# CERTO — contexto completo para ação imediata
"🚨 ERRO em [Sync Salesforce Leads] | Node: HTTP Request |
 429 Too Many Requests | 22/03/2026 14:30 BRT"
```

### ❌ 4.2 Engolir erros silenciosamente

```javascript
// ERRADO — erro desaparece, dados vazios propagam
onError: "continueRegularOutput"
// ... sem guard node depois

// CERTO — continuar com guard
onError: "continueRegularOutput"
// → IF node: $json.data != null ? "Sucesso" : "Sem dados (skip)"
```

### ❌ 4.3 Alert fatigue — excesso de notificações

| Problema | Solução |
|----------|---------|
| Mesmo erro 50x por hora | Adicionar **deduplicação**: só alertar se erro for diferente do último |
| Erros transientes (timeout 1x) | Adicionar **retry** antes de alertar (3 tentativas) |
| Alertas em workflow de teste | **Não** configurar errorWorkflow em workflows de dev/teste |
| Alertas de madrugada não-urgentes | Categorizar severidade: 🔴 crítico (imediato) / 🟡 warning (batch diário) |

### ❌ 4.4 Error Workflow inativo

O Error Workflow **DEVE** estar ativo (`active: true`). Um workflow inativo **não** recebe triggers de erro de outros workflows. Este é o erro mais comum e mais silencioso.

---

## 5. Quality Checklist

Antes de considerar o error alerting como configurado:

```
□ Error Workflow existe e está ATIVO?
□ Todos os workflows de produção apontam para o errorWorkflow?
□ Mensagem de alerta contém os 5 campos obrigatórios?
□ Timestamp está em BRT (não UTC)?
□ Mensagem de erro está truncada para < 4096 chars (limite Telegram)?
□ Nodes críticos têm onError configurado individualmente?
□ Nodes com continueRegularOutput têm guard nodes downstream?
□ Testou disparo real de erro e confirmou recebimento no Telegram?
□ Não há alert fatigue (deduplicação/retry antes de alertar)?
□ Error Workflow tem seu próprio tratamento de erro (evitar loop infinito)?
```

> ⚠️ **Armadilha do loop infinito:** O Error Workflow NÃO deve apontar para si mesmo como `errorWorkflow`. Se o Error Workflow falhar, configure um fallback simples (log em arquivo ou segunda instância mínima).

---

## 6. Variáveis de Ambiente Necessárias

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `N8N_HOST` | URL da instância n8n | `https://n8n.meudominio.com` |
| `TELEGRAM_BOT_TOKEN` | Token do bot Telegram | `123456:ABC-DEF...` |
| `TELEGRAM_CHAT_ID` | ID do chat/grupo para alertas | `-1001234567890` |

---

*Estou seguindo as minhas instruções, chefe.*
