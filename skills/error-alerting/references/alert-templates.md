# 📋 Alert Templates — Templates de Mensagens de Alerta

> Templates prontos para uso no Code node do Error Workflow.
> Todos os timestamps são convertidos para BRT (America/Sao_Paulo).

---

## 1. Erro Genérico de Workflow (template base)

Usado como fallback quando o tipo de erro não é identificado.

```javascript
const brt = new Date().toLocaleString('pt-BR', {
  timeZone: 'America/Sao_Paulo',
  day: '2-digit', month: '2-digit', year: 'numeric',
  hour: '2-digit', minute: '2-digit', second: '2-digit'
});

const e = $input.first().json;
const errorMsg = (e.execution?.error?.message || 'Erro desconhecido').substring(0, 2000);
const nodeName = e.execution?.error?.node?.name || e.execution?.lastNodeExecuted || '?';
const wfName = e.workflow?.name || 'Sem nome';
const wfId = e.workflow?.id || 'N/A';
const execId = e.execution?.id || 'N/A';
const host = $env.N8N_HOST || 'http://localhost:5678';

return [{
  json: {
    message: `🚨 <b>ERRO em Workflow n8n</b>

📋 <b>Workflow:</b> ${wfName}
🔗 <b>ID:</b> <code>${wfId}</code>
🆔 <b>Execução:</b> <code>${execId}</code>
⚙️ <b>Node:</b> ${nodeName}
🕐 <b>Horário (BRT):</b> ${brt}

❌ <b>Erro:</b>
<pre>${errorMsg}</pre>

🔍 <a href="${host}/workflow/${wfId}/executions/${execId}">Ver execução</a>`,
    parse_mode: 'HTML'
  }
}];
```

---

## 2. Timeout de LLM (OpenAI, Anthropic, etc.)

Detecta erros de timeout em chamadas a modelos de linguagem.

```javascript
const brt = new Date().toLocaleString('pt-BR', {
  timeZone: 'America/Sao_Paulo',
  day: '2-digit', month: '2-digit', year: 'numeric',
  hour: '2-digit', minute: '2-digit', second: '2-digit'
});

const e = $input.first().json;
const errorMsg = e.execution?.error?.message || '';
const nodeName = e.execution?.error?.node?.name || '?';
const wfName = e.workflow?.name || 'Sem nome';
const wfId = e.workflow?.id || 'N/A';
const execId = e.execution?.id || 'N/A';
const host = $env.N8N_HOST || 'http://localhost:5678';

// Detectar se é timeout de LLM
const isLLMTimeout = /timeout|ETIMEDOUT|socket hang up|ECONNRESET/i.test(errorMsg);
const provider = /openai/i.test(nodeName) ? 'OpenAI'
  : /anthropic|claude/i.test(nodeName) ? 'Anthropic'
  : /google|gemini/i.test(nodeName) ? 'Google AI'
  : 'LLM Provider';

const severity = isLLMTimeout ? '🟡' : '🔴';

return [{
  json: {
    message: `${severity} <b>TIMEOUT — ${provider}</b>

📋 <b>Workflow:</b> ${wfName}
⚙️ <b>Node:</b> ${nodeName}
🕐 <b>Horário (BRT):</b> ${brt}

⏱️ <b>Tipo:</b> Timeout na chamada ao modelo de linguagem
💡 <b>Ação sugerida:</b>
  • Verificar status do provider: <a href="https://status.openai.com">OpenAI Status</a>
  • Considerar reduzir max_tokens ou trocar para modelo menor
  • Se recorrente, adicionar retry com backoff exponencial

❌ <b>Erro original:</b>
<pre>${(errorMsg).substring(0, 1500)}</pre>

🔍 <a href="${host}/workflow/${wfId}/executions/${execId}">Ver execução</a>`,
    parse_mode: 'HTML'
  }
}];
```

---

## 3. Rate Limit de API (429 Too Many Requests)

Detecta erros de rate limiting em integrações externas.

```javascript
const brt = new Date().toLocaleString('pt-BR', {
  timeZone: 'America/Sao_Paulo',
  day: '2-digit', month: '2-digit', year: 'numeric',
  hour: '2-digit', minute: '2-digit', second: '2-digit'
});

const e = $input.first().json;
const errorMsg = e.execution?.error?.message || '';
const nodeName = e.execution?.error?.node?.name || '?';
const wfName = e.workflow?.name || 'Sem nome';
const wfId = e.workflow?.id || 'N/A';
const execId = e.execution?.id || 'N/A';
const host = $env.N8N_HOST || 'http://localhost:5678';

// Extrair Retry-After se disponível
const retryAfterMatch = errorMsg.match(/retry.?after[:\s]*(\d+)/i);
const retryAfter = retryAfterMatch ? `${retryAfterMatch[1]} segundos` : 'Não informado';

return [{
  json: {
    message: `🟠 <b>RATE LIMIT — 429 Too Many Requests</b>

📋 <b>Workflow:</b> ${wfName}
⚙️ <b>Node:</b> ${nodeName}
🕐 <b>Horário (BRT):</b> ${brt}

🚦 <b>Tipo:</b> Limite de requisições excedido na API
⏳ <b>Retry-After:</b> ${retryAfter}

💡 <b>Ação sugerida:</b>
  • Adicionar node <b>Wait</b> com delay entre requisições
  • Implementar batch com <b>SplitInBatches</b> + Wait
  • Verificar cota da API e considerar upgrade de plano
  • Se Salesforce: verificar limite de 100 API calls/instância/15min

❌ <b>Erro original:</b>
<pre>${(errorMsg).substring(0, 1500)}</pre>

🔍 <a href="${host}/workflow/${wfId}/executions/${execId}">Ver execução</a>`,
    parse_mode: 'HTML'
  }
}];
```

---

## 4. Falha de Validação de Dados

Para erros de dados inválidos, campos obrigatórios ausentes ou formato incorreto.

```javascript
const brt = new Date().toLocaleString('pt-BR', {
  timeZone: 'America/Sao_Paulo',
  day: '2-digit', month: '2-digit', year: 'numeric',
  hour: '2-digit', minute: '2-digit', second: '2-digit'
});

const e = $input.first().json;
const errorMsg = e.execution?.error?.message || '';
const nodeName = e.execution?.error?.node?.name || '?';
const wfName = e.workflow?.name || 'Sem nome';
const wfId = e.workflow?.id || 'N/A';
const execId = e.execution?.id || 'N/A';
const host = $env.N8N_HOST || 'http://localhost:5678';

// Tentar identificar campo problemático
const fieldMatch = errorMsg.match(/(?:field|property|column|campo)[:\s]*['"]([\w.]+)['"]/i);
const fieldName = fieldMatch ? fieldMatch[1] : 'Não identificado';

// Tentar identificar tipo de validação
const validationType =
  /required|obrigat/i.test(errorMsg) ? 'Campo obrigatório ausente' :
  /type|tipo|invalid.*format/i.test(errorMsg) ? 'Formato/tipo inválido' :
  /duplicate|duplica/i.test(errorMsg) ? 'Registro duplicado' :
  /null|undefined/i.test(errorMsg) ? 'Valor nulo inesperado' :
  'Validação genérica';

return [{
  json: {
    message: `🟡 <b>VALIDAÇÃO DE DADOS — Falha</b>

📋 <b>Workflow:</b> ${wfName}
⚙️ <b>Node:</b> ${nodeName}
🕐 <b>Horário (BRT):</b> ${brt}

📊 <b>Tipo:</b> ${validationType}
📌 <b>Campo:</b> <code>${fieldName}</code>

💡 <b>Ação sugerida:</b>
  • Verificar dados de entrada do workflow (webhook payload, planilha, etc.)
  • Adicionar node <b>IF</b> para validar campos antes de processar
  • Se recorrente: adicionar Set node com valores default para campos opcionais
  • Revisar schema de dados na fonte (formulário, integração, API)

❌ <b>Erro original:</b>
<pre>${(errorMsg).substring(0, 1500)}</pre>

🔍 <a href="${host}/workflow/${wfId}/executions/${execId}">Ver execução</a>`,
    parse_mode: 'HTML'
  }
}];
```

---

## 5. Template Router — Detectar e rotear automaticamente

Use este Code node para detectar o tipo de erro e aplicar o template correto:

```javascript
const errorMsg = ($input.first().json.execution?.error?.message || '').toLowerCase();

let errorType = 'generic';

if (/timeout|etimedout|socket hang up|econnreset/i.test(errorMsg) &&
    /openai|anthropic|claude|gemini|llm|ai|model/i.test(errorMsg)) {
  errorType = 'llm_timeout';
} else if (/429|rate.?limit|too many requests|quota/i.test(errorMsg)) {
  errorType = 'rate_limit';
} else if (/required|invalid|validation|null|undefined|type.*error|campo.*obrigat/i.test(errorMsg)) {
  errorType = 'data_validation';
}

return [{ json: { ...$input.first().json, errorType } }];
```

Conectar a um **Switch node** que roteia para o template específico:
```
[Error Trigger] → [Detect Type] → [Switch: errorType]
                                      ├── llm_timeout → Template 2
                                      ├── rate_limit → Template 3
                                      ├── data_validation → Template 4
                                      └── default (generic) → Template 1
                                           ↓ (todos convergem)
                                      [Telegram Send]
```

---

## Notas de Uso

- **Parse mode:** Todos os templates usam `HTML` (mais robusto que MarkdownV2 para mensagens de erro)
- **Truncamento:** Mensagens de erro são truncadas em 1500-2000 chars para ficar dentro do limite de 4096 do Telegram
- **Link de execução:** Requer variável `N8N_HOST` configurada. Se não definida, usa localhost
- **Severidade visual:** 🔴 crítico | 🟠 rate limit | 🟡 warning | Ajuda a priorizar visualmente no chat
