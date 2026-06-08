---
name: n8n-validation-expert
description: >
  Interpretar erros de validação n8n, debug de workflows, false positives,
  loop de correção e diagnóstico de falhas comuns.
domain: automation
subdomain: n8n-debug
version: 1.0.0
author: deivithi
tags:
  - n8n
  - validation
  - debug
  - errors
  - troubleshooting
---

# 🔍 n8n Validation Expert — Debug & Troubleshooting

> **"Todo erro de workflow tem uma causa raiz. Esta skill mapeia os 30 erros mais comuns e suas correções exatas."**

## 📁 File Structure
- `SKILL.md` — Você está aqui.

## 🔗 Related Skills
- `n8n-code-javascript` — Erros de Code node JavaScript (sandbox, retorno)
- `n8n-code-python` — Erros de Code node Python (variáveis legacy, dot access)
- `n8n-expression-syntax` — Erros em expressões `{{}}`
- `n8n-node-configuration` — Configuração correta de nodes

---

## 🔄 Loop de Diagnóstico

```
Erro reportado / Workflow falhou
    ↓
1. Identificar o node que falhou (execution log)
    ↓
2. Classificar o tipo de erro (tabela abaixo)
    ↓
3. Aplicar correção específica
    ↓
4. Validar: n8n_validate_workflow({id, profile: "strict"})
    ↓
5. Testar: n8n_test_workflow({id}) ou executar manual
    ↓
6. Se novo erro → voltar ao passo 1
```

---

## 🔴 Erros CRITICAL — Sandbox & Runtime

### E01: `Module 'X' is disallowed`
**Causa:** Code node tentando `require()` de módulo nativo bloqueado.
**Correção:**
- Se precisa de shell/fs → **Substituir por Execute Command node**
- Se precisa de crypto/uuid → Adicionar à allowlist `NODE_FUNCTION_ALLOW_BUILTIN`
- Se n8n Cloud → **Impossível** — redesenhar sem require()

### E02: `Cannot use import statement`
**Causa:** Usando `import X from 'Y'` em Code node.
**Correção:** Trocar para `const X = require('Y')` (CommonJS). Se módulo não está na allowlist → Execute Command.

### E03: `Code doesn't return items properly`
**Causa:** Formato de retorno inválido no Code node.
**Correção:**
```javascript
// Modo All Items → retornar ARRAY de {json: Object}
return [{ json: { campo: "valor" } }];

// Modo Each Item → retornar OBJETO {json: Object}
return { json: { campo: "valor" } };
```
> ⚠️ `json` DEVE ser objeto, NUNCA array.

### E04: `Cannot read properties of undefined`
**Causa:** Acessando campo que não existe no JSON.
**Correção:** Usar optional chaining e fallback:
```javascript
const valor = $json.endereco?.cep ?? 'N/A';
// ou em expressão:
{{ $json.endereco?.cep ?? 'N/A' }}
```

---

## 🟠 Erros HIGH — Conexão & API

### E05: `The connection timed out`
**Causa:** API externa demorou demais para responder.
**Correção:**
1. Habilitar retry: `retryOnFail: true, maxTries: 3, waitBetweenTries: 30000`
2. Aumentar timeout nas opções do node: `options.timeout: 60000`
3. Verificar se credencial OAuth não expirou

### E06: `NodeApiError` + status 401/403
**Causa:** Credencial expirada ou sem permissão.
**Correção:**
1. Abrir n8n UI → Credentials → testar a credencial
2. Se OAuth2 → reautenticar (fluxo de grant)
3. Verificar scopes necessários

### E07: `NodeApiError` + status 429
**Causa:** Rate limit da API excedido.
**Correção:**
1. Adicionar Wait node entre iterações
2. Reduzir batch size
3. Habilitar retry com backoff exponencial: `waitBetweenTries: 10000`

### E08: `NodeApiError` + status 400 (Telegram/Slack)
**Causa:** Mensagem excede limite de caracteres.
**Correção:** Adicionar Code node de splitting antes do envio.
- Telegram: split em 4000 chars
- Slack: split em 3900 chars
- Discord: split em 1900 chars
(Ver pattern 5 na skill `n8n-code-javascript`)

### E09: `ECONNREFUSED` / `ENOTFOUND`
**Causa:** Serviço destino não está rodando ou URL errada.
**Correção:**
1. Verificar se o serviço está rodando (ping, curl)
2. Verificar URL — typos comuns: `http` vs `https`, porta errada
3. Se Docker → verificar network (use `host.docker.internal` para localhost)

---

## 🟡 Erros MEDIUM — Lógica & Configuração

### E10: `No items to process` / Node não executa
**Causa:** Node anterior retornou array vazio `[]`.
**Correção:**
1. Verificar se o filtro/IF anterior está correto
2. Adicionar `alwaysOutputData: true` no node se quer que execute mesmo sem items

### E11: IF node rejeita dados válidos
**Causa:** `typeValidation: "strict"` com `isNotEmpty`.
**Correção:** Trocar para `typeValidation: "loose"` ou usar expressão:
```
{{ $json.text.length > 50 }}
```
> **Caso real:** IF com strict rejeitou texto de 6199 chars porque o tipo não era exatamente string.

### E12: Dados de node anterior não disponíveis
**Causa:** chainLlm e outros nodes não propagam campos upstream.
**Correção:** Usar `$("Nome do Node")` para acessar dados de qualquer node:
```javascript
const original = $("Email Trigger").first().json;
```

### E13: Schedule/Cron no timezone errado
**Causa:** Timezone do workflow não é `America/Sao_Paulo`.
**Correção:**
```json
{
  "settings": {
    "timezone": "America/Sao_Paulo"
  }
}
```

### E14: Webhook não recebe dados
**Causa:** URL errada ou método HTTP errado.
**Correção:**
1. Verificar URL de teste vs produção (são diferentes!)
2. Verificar método (GET/POST) — match com o sender
3. Verificar se workflow está **ativo** (URLs de produção só funcionam com workflow ativo)

---

## 🟢 Erros LOW — Warnings & Validação

### E15: `typeVersion outdated`
**Causa:** Node usando versão antiga do tipo.
**Correção:** Warning apenas. Atualizar `typeVersion` se quiser features novas, mas não é bloqueante.

### E16: `Expression contains emoji characters`
**Causa:** Validador flaggeia emojis em expressões.
**Correção:** É warning, não erro. Emojis funcionam — ignorar o warning.

### E17: `Node has no input connection`
**Causa:** Node solto sem conexão.
**Correção:** Conectar ao fluxo ou remover se não é necessário.

---

## 🔧 Validation Profiles

### Quando usar cada profile

| Profile | Quando | Rigor |
|---------|--------|-------|
| `runtime` | Desenvolvimento, iteração rápida | Médio — só erros que impedem execução |
| `strict` | Pré-produção, hardening | Alto — todos os warnings |
| `ai-friendly` | Workflows com nodes LLM | Especializado — checks de IA |

### Como validar

```
n8n_validate_workflow({
  id: "workflow-id",
  profile: "strict"
})
```

---

## 🔀 False Positives — Quando Ignorar

| Warning | Quando é False Positive |
|---------|------------------------|
| `typeVersion outdated` | Se o workflow funciona — não é necessário atualizar |
| `emoji in expression` | Sempre — emojis funcionam perfeitamente |
| `node has multiple outputs but only one connected` | IF/Switch nodes — é normal ter branch não conectado |
| `no error handling` | Se o workflow já tem Error Workflow configurado nos settings |

---

## 🏥 Checklist de Diagnóstico Rápido

Quando um workflow falha, responder estas perguntas em ordem:

```
1. [ ] QUAL node falhou? (ver execution log)
2. [ ] QUAL o tipo de erro? (NodeApiError, sandbox, expression, etc.)
3. [ ] O erro é reproduzível? (executar novamente)
4. [ ] As credenciais estão válidas? (testar na UI)
5. [ ] Os dados de entrada existem? (verificar node anterior)
6. [ ] O node está na versão correta? (typeVersion)
7. [ ] Há retry configurado? (retryOnFail)
8. [ ] O timezone está correto? (America/Sao_Paulo)
```

---

## Regras Invioláveis

1. **SEMPRE verificar execution log antes de diagnosticar** — não adivinhar
2. **SEMPRE validar após cada correção** — `n8n_validate_workflow` com profile adequado
3. **NUNCA ignorar erros CRITICAL** — resolver antes de prosseguir
4. **SEMPRE testar após correção** — executar e verificar output
5. **SEMPRE documentar o fix** — para evitar o mesmo erro no futuro
