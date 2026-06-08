---
name: n8n-code-javascript
description: >
  Padrões JavaScript seguros para Code nodes n8n. Documenta sandbox V8,
  o que é permitido/proibido, quando usar Execute Command, e 10 patterns de produção.
domain: automation
subdomain: n8n-code
version: 1.0.0
author: deivithi
tags:
  - n8n
  - code-node
  - javascript
  - sandbox
  - execute-command
---

# ⚡ n8n Code Node — JavaScript

> **"Code nodes rodam em sandbox V8 isolado. Saber o que pode e o que não pode é a diferença entre workflow funcionando e erro misterioso."**

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Workflow abaixo.

## 🔗 Related Skills
- `n8n-code-python` — Code nodes Python (limitações diferentes)
- `n8n-expression-syntax` — Expressões `{{}}` em campos de nodes
- `n8n-validation-expert` — Debug de erros de Code nodes
- `n8n-node-configuration` — Configurar Execute Command e outros nodes
- `n8n-workflow-patterns` — Padrões arquiteturais (quando usar Code vs outros nodes)

---

## 🚨 REGRA #1: Sandbox V8 — O Que Bloqueia Workflows

### ❌ PROIBIDO em Code Nodes (causa erro imediato)

| Operação | Erro | Solução |
|----------|------|---------|
| `require('child_process')` | `Module 'child_process' is disallowed` | Usar **Execute Command** node |
| `require('fs')` | `Module 'fs' is disallowed` | Usar **Read/Write Binary File** node |
| `require('os')` | `Module 'os' is disallowed` | Usar **Execute Command** node com `uname` |
| `require('path')` | `Module 'path' is disallowed` | Manipular strings manualmente |
| `require('http')` / `require('https')` | `Module disallowed` | Usar **HTTP Request** node |
| `import ... from ...` | `Cannot use import statement` | Usar `require()` (CommonJS) |
| Qualquer módulo npm não allowlisted | `Cannot find module` | Configurar `NODE_FUNCTION_ALLOW_EXTERNAL` |
| `process.env.VAR` | `undefined` (silencioso!) | Usar `$env.VAR` (se desbloqueado) ou `$vars.VAR` |

### ✅ PERMITIDO em Code Nodes (funciona sempre)

| Recurso | Exemplo |
|---------|---------|
| **Processamento de texto** | `text.replace()`, `text.split()`, regex |
| **JSON** | `JSON.parse()`, `JSON.stringify()` |
| **Math** | `Math.round()`, `Math.random()` |
| **Arrays** | `map`, `filter`, `reduce`, `sort`, `flat` |
| **Luxon DateTime** | `DateTime.now()`, `DateTime.fromISO()` (global, sem import) |
| **JMESPath** | `$jmespath(data, 'expression')` (global) |
| **console.log** | Para debug — aparece nos logs da execução |
| **async/await** | Suportado para Promises internas |
| **Static Data** | `$getWorkflowStaticData('global')` — persistir entre execuções |
| **Custom Execution Data** | `$execution.customData.set('key', 'val')` |

---

## 🔀 Decision Tree: Code Node vs Execute Command

```
Preciso executar lógica no n8n?
│
├── É processamento de DADOS? (map, filter, transform, parse)
│   └── ✅ Code Node
│
├── Precisa chamar HTTP/API?
│   └── ✅ HTTP Request Node (NÃO Code node com fetch)
│
├── Precisa executar CLI/shell/script externo?
│   └── ✅ Execute Command Node
│
├── Precisa ler/escrever arquivos do filesystem?
│   └── ✅ Execute Command Node (ou Read/Write Binary File)
│
├── Precisa usar pacote npm complexo (puppeteer, sharp, etc.)?
│   └── ✅ Execute Command Node (chamar script externo)
│
└── Precisa de crypto, uuid, ou módulo simples?
    └── ⚠️ Code Node COM allowlist (NODE_FUNCTION_ALLOW_BUILTIN)
```

---

## 📐 Formato de Retorno — REGRA INVIOLÁVEL

### Modo "Run Once for All Items" (default)

```javascript
// ✅ CORRETO — retorna array de objetos com key "json"
return [
  { json: { nome: "Item 1", valor: 100 } },
  { json: { nome: "Item 2", valor: 200 } }
];

// ❌ ERRADO — json como array (erro silencioso!)
return [{ json: [1, 2, 3] }];

// ❌ ERRADO — sem key json
return [{ nome: "Item 1" }];

// ❌ ERRADO — retornar objeto direto
return { json: { nome: "Item 1" } };
```

### Modo "Run Once for Each Item"

```javascript
// ✅ CORRETO — retorna objeto único com key "json"
return { json: { resultado: $json.campo * 2 } };

// ❌ ERRADO — retornar array
return [{ json: { resultado: 1 } }];
```

> ⚠️ **A propriedade `json` DEVE ser um OBJETO, nunca um array.** Isso causa erro silencioso — o workflow continua mas com dados corrompidos.

---

## 🏗️ Variáveis Built-in — Referência Completa

### Dados de Entrada

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `$input.all()` | `Item[]` | Todos os items de entrada |
| `$input.first()` | `Item` | Primeiro item |
| `$input.last()` | `Item` | Último item |
| `$input.item` | `Item` | Item atual (no modo "Each Item") |
| `$json` | `Object` | Shorthand para `$input.item.json` |
| `$binary` | `Object` | Dados binários do item atual |

### Acesso a Outros Nodes

```javascript
// Todos os items de output de um node
const items = $("Nome do Node").all();

// Primeiro item
const first = $("Nome do Node").first();

// Item pareado (item linking)
const paired = $("Nome do Node").item;

// Campo específico
const email = $("Email Trigger").first().json.from;
```

### Metadados

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `$workflow.id` | `string` | ID do workflow |
| `$workflow.name` | `string` | Nome do workflow |
| `$workflow.active` | `boolean` | Se está ativo |
| `$execution.id` | `string` | ID da execução atual |
| `$execution.mode` | `string` | `test` / `production` |
| `$now` | `DateTime` | Timestamp atual (Luxon) |
| `$today` | `DateTime` | Data atual meia-noite (Luxon) |
| `$itemIndex` | `number` | Índice do item (modo Each) |
| `$runIndex` | `number` | Quantas vezes o node rodou |
| `$prevNode` | `Object` | Info do node anterior |

### Dados Persistentes entre Execuções

```javascript
// Ler/escrever dados que sobrevivem entre execuções
const staticData = $getWorkflowStaticData('global');

// Exemplo: round-robin com estado
staticData.lastIndex = (staticData.lastIndex ?? -1) + 1;
const targets = ['skill-a', 'skill-b', 'skill-c'];
const target = targets[staticData.lastIndex % targets.length];

return [{ json: { target, index: staticData.lastIndex } }];
```

---

## 🎯 10 Padrões de Produção

### Pattern 1: Flatten — 1 item com array → N items

```javascript
// Input: 1 item com { data: [{...}, {...}, {...}] }
// Output: 3 items separados
const items = $input.first().json.data;
return items.map(item => ({ json: item }));
```

### Pattern 2: Aggregate — N items → 1 item

```javascript
// Input: N items individuais
// Output: 1 item com array
const allData = $input.all().map(item => item.json);
return [{ json: { items: allData, count: allData.length } }];
```

### Pattern 3: Filter com contexto

```javascript
const items = $input.all();
const filtered = items.filter(item => {
  return item.json.status === 'active' && item.json.score > 50;
});

if (filtered.length === 0) {
  return [{ json: { error: 'Nenhum item passou no filtro', count: 0 } }];
}

return filtered.map(item => ({ json: item.json }));
```

### Pattern 4: Dedup por campo

```javascript
const seen = new Set();
const items = $input.all();
const unique = [];

for (const item of items) {
  const key = item.json.email?.toLowerCase();
  if (key && !seen.has(key)) {
    seen.add(key);
    unique.push({ json: item.json });
  }
}

return unique;
```

### Pattern 5: Split de mensagem (Telegram/Slack)

```javascript
const MAX_CHARS = 4000;
const MAX_PARTS = 10;
const text = $input.first().json.text ?? '';

if (!text || text.trim().length === 0) {
  return [{ json: { error: 'Texto vazio', parts: [] } }];
}

const parts = [];
let remaining = text;
while (remaining.length > 0 && parts.length < MAX_PARTS) {
  if (remaining.length <= MAX_CHARS) {
    parts.push(remaining);
    break;
  }
  let splitAt = remaining.lastIndexOf('\n\n', MAX_CHARS);
  if (splitAt <= 0) splitAt = remaining.lastIndexOf('\n', MAX_CHARS);
  if (splitAt <= 0) splitAt = remaining.lastIndexOf('. ', MAX_CHARS);
  if (splitAt <= 0) splitAt = MAX_CHARS;
  parts.push(remaining.substring(0, splitAt));
  remaining = remaining.substring(splitAt).trim();
}

return parts.map((part, i) => ({
  json: {
    text: parts.length > 1 ? `[${i + 1}/${parts.length}]\n${part}` : part,
    partIndex: i,
    totalParts: parts.length
  }
}));
```

### Pattern 6: HTML stripping

```javascript
const html = $input.first().json.html ?? $input.first().json.body ?? '';

const text = html
  .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
  .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
  .replace(/<br\s*\/?>/gi, '\n')
  .replace(/<\/p>/gi, '\n\n')
  .replace(/<\/div>/gi, '\n')
  .replace(/<li[^>]*>/gi, '• ')
  .replace(/<\/li>/gi, '\n')
  .replace(/<[^>]+>/g, '')
  .replace(/&nbsp;/g, ' ')
  .replace(/&amp;/g, '&')
  .replace(/&lt;/g, '<')
  .replace(/&gt;/g, '>')
  .replace(/&quot;/g, '"')
  .replace(/\n{3,}/g, '\n\n')
  .trim();

return [{ json: { text, originalLength: html.length, cleanLength: text.length } }];
```

### Pattern 7: Date formatting (BRT)

```javascript
// Luxon DateTime está disponível globalmente — sem import!
const now = DateTime.now().setZone('America/Sao_Paulo');
const formatted = now.toFormat('dd/MM/yyyy HH:mm');

return [{ json: {
  timestamp: formatted + ' BRT',
  iso: now.toISO(),
  dayOfWeek: now.weekdayLong
} }];
```

### Pattern 8: Round-robin com estado persistente

```javascript
const staticData = $getWorkflowStaticData('global');
const dayOfYear = Math.floor((Date.now() - new Date(new Date().getFullYear(), 0, 0)) / 86400000);

const targets = [
  { domain: 'skills', target: 'code-review' },
  { domain: 'skills', target: 'lead-audit' },
  { domain: 'skills', target: 'commission-audit' },
  { domain: 'workflows', target: 'newsletter-summarizer' }
];

const index = dayOfYear % targets.length;
staticData.lastTarget = targets[index].target;
staticData.lastRun = new Date().toISOString();

return [{ json: { ...targets[index], dayOfYear, maxIterations: 3 } }];
```

### Pattern 9: Parse JSON defensivo

```javascript
const raw = $input.first().json.output ?? $input.first().json.text ?? '';

let parsed;
try {
  // Tentar extrair JSON de texto misto (LLM output)
  const jsonMatch = raw.match(/\{[\s\S]*\}/);
  if (jsonMatch) {
    parsed = JSON.parse(jsonMatch[0]);
  } else {
    parsed = JSON.parse(raw);
  }
} catch (e) {
  return [{ json: { error: 'JSON inválido', raw: raw.substring(0, 500) } }];
}

return [{ json: { parsed, success: true } }];
```

### Pattern 10: Acessar dados de node anterior (cross-node)

```javascript
// Útil quando IF node descarta dados do fluxo
// Acessar dados originais de qualquer node pelo nome
const emailFrom = $("Email Trigger").first().json.from;
const emailSubject = $("Email Trigger").first().json.subject;
const llmOutput = $("Claude Summarize").first().json.text;

return [{ json: {
  from: emailFrom,
  subject: emailSubject,
  summary: llmOutput,
  timestamp: DateTime.now().setZone('America/Sao_Paulo').toFormat('dd/MM/yyyy HH:mm') + ' BRT'
} }];
```

---

## ⚠️ Gotchas Conhecidos

### 1. `$json` só funciona no modo "Each Item"
No modo "All Items", use `$input.first().json` ou `$input.all()`.

### 2. `DateTime` concatenado com string retorna Unix timestamp
```javascript
// ❌ "Data: 1679500800" (unix!)
const msg = "Data: " + $now;

// ✅ "Data: 22/03/2026 14:30 BRT"
const msg = "Data: " + $now.setZone('America/Sao_Paulo').toFormat('dd/MM/yyyy HH:mm') + ' BRT';
```

### 3. Code node vazio silencia o fluxo
Se o Code node retorna `[]` (array vazio), os nodes seguintes **não executam**. Isso pode parecer que o workflow "não fez nada".

### 4. Unicode em expressões — use emojis reais
```javascript
// ❌ Literal: \u26a0\ufe0f
const msg = '\u26a0\ufe0f Alerta';

// ✅ Emoji real
const msg = '⚠️ Alerta';
```

### 5. n8n Cloud não suporta require() de NADA
Se o workflow vai rodar no n8n Cloud, **zero require()**. Todo processamento deve usar apenas built-ins do JavaScript.

---

## 🔧 Allowlist de Módulos (Self-hosted apenas)

Se realmente precisar de um módulo nativo em Code node:

### Via variável de ambiente (PM2 / Docker)

```javascript
// Em ecosystem.config.js (PM2):
module.exports = {
  apps: [{
    name: 'n8n',
    env: {
      NODE_FUNCTION_ALLOW_BUILTIN: 'crypto,path',
      NODE_FUNCTION_ALLOW_EXTERNAL: 'moment,uuid,lodash'
    }
  }]
};
```

### Via Task Runners (n8n v2+)

```json
// n8n-task-runners.json
{
  "task-runners": [{
    "runner-type": "javascript",
    "env-overrides": {
      "NODE_FUNCTION_ALLOW_BUILTIN": "crypto",
      "NODE_FUNCTION_ALLOW_EXTERNAL": "moment,uuid"
    }
  }]
}
```

> ⚠️ **Preferência:** Mesmo com allowlist, preferir nodes nativos (HTTP Request, Execute Command) em vez de require() em Code nodes. A allowlist é escape hatch, não padrão.

---

## Regras Invioláveis

1. **NUNCA usar require() para módulos nativos sem verificar allowlist** — falha imediata
2. **NUNCA retornar json como array** — `{ json: [...] }` causa erro silencioso
3. **NUNCA usar import/export** — apenas `require()` (CommonJS)
4. **SEMPRE retornar array no modo "All Items"** — `return [{json: {...}}]`
5. **SEMPRE usar Execute Command para operações de shell/filesystem** — Code node não tem acesso
6. **SEMPRE testar com dados reais** — expressões que funcionam no editor podem falhar em produção
