---
name: guardrails
description: >
  3 camadas de proteção para agentes IA: Input Guard (sanitiza/rejeita entradas maliciosas),
  Output Guard (valida saídas antes de entregar), Action Auth (controla permissões de ações
  destrutivas). Use para blindar qualquer skill, workflow ou agente contra prompt injection,
  data leakage e ações não autorizadas.
domain: security
subdomain: agent-safety
version: 1.0.0
author: deivithi
tags:
  - guardrails
  - prompt-injection
  - output-validation
  - action-authorization
  - agent-safety
  - security
---

# 🛡️ Guardrails — 3 Camadas de Proteção para Agentes IA

> **"Um agente sem guardrails é um vetor de ataque com superpoderes."**

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Workflow abaixo.
- `references/patterns.md` — Padrões de ataque conhecidos e como cada camada responde.
- `gotchas.md` — Problemas conhecidos e edge cases.

## 🔗 Related Skills
- `code-review` — Reviewer detecta vulnerabilidades que guardrails previne em runtime
- `error-alerting` — Alertas quando guardrails bloqueia algo suspeito
- `cyber` → `prompt-injection-defense` — Técnicas avançadas de defesa contra injection

---

## 🎯 O Problema

Agentes IA com acesso a ferramentas (MCP, CLI, APIs) podem ser manipulados via:

| Vetor | Risco | Sem Guardrail |
|-------|-------|---------------|
| **Prompt Injection** | Usuário injeta instruções no input | Agente executa comandos maliciosos |
| **Data Leakage** | Output contém dados sensíveis | Secrets, PII, tokens expostos |
| **Unauthorized Actions** | Agente executa ação destrutiva | `rm -rf`, `DROP TABLE`, force push |

---

## 🔄 Workflow — 3 Camadas

```
INPUT → [Layer 1: Input Guard] → PROCESSING → [Layer 2: Output Guard] → [Layer 3: Action Auth] → OUTPUT
         │                                       │                         │
         ├─ Rejeita injection                    ├─ Redacta PII            ├─ Bloqueia destrutivo
         ├─ Sanitiza encoding                    ├─ Valida formato         ├─ Exige confirmação
         └─ Rate-limits                          └─ Size-limits            └─ Loga audit trail
```

---

## 🔒 Layer 1: Input Guard

### 1.1 Detectar — Classificar o input

```javascript
// Code node n8n — Input Classification
const input = $input.first().json.text || '';

const INJECTION_PATTERNS = [
  /ignore\s+(all\s+)?previous\s+instructions/i,
  /you\s+are\s+now\s+/i,
  /system\s*prompt/i,
  /\bDAN\b/,
  /do\s+anything\s+now/i,
  /jailbreak/i,
  /bypass\s+(safety|filter|guard)/i,
  /pretend\s+(you|to\s+be)/i,
  /role\s*play\s+as/i,
  /\bACT\s+AS\b/i,
];

const ENCODING_ATTACKS = [
  /&#x[0-9a-f]+;/i,       // HTML entity encoding
  /%[0-9a-f]{2}/i,         // URL encoding
  /\\u[0-9a-f]{4}/i,       // Unicode escape
  /\x00/,                   // Null byte
];

let risk = 'SAFE';
let matched = [];

for (const pattern of INJECTION_PATTERNS) {
  if (pattern.test(input)) {
    risk = 'BLOCKED';
    matched.push(pattern.source);
  }
}

for (const pattern of ENCODING_ATTACKS) {
  if (pattern.test(input)) {
    risk = risk === 'BLOCKED' ? 'BLOCKED' : 'SUSPICIOUS';
    matched.push(`encoding: ${pattern.source}`);
  }
}

// Length guard
if (input.length > 50000) {
  risk = 'SUSPICIOUS';
  matched.push('excessive_length');
}

return [{
  json: {
    original_input: input,
    risk_level: risk,
    matched_patterns: matched,
    timestamp: new Date().toISOString(),
    action: risk === 'BLOCKED' ? 'REJECT' : risk === 'SUSPICIOUS' ? 'SANITIZE' : 'PASS'
  }
}];
```

### 1.2 Agir — Baseado na classificação

| Risk Level | Ação |
|------------|------|
| `SAFE` | Passa direto para processing |
| `SUSPICIOUS` | Sanitiza (strip encoding, truncate) e marca com flag |
| `BLOCKED` | Rejeita com mensagem genérica, loga tentativa |

### 1.3 Rejeição segura

```javascript
// NUNCA revelar quais padrões foram detectados
// NUNCA ecoar o input malicioso de volta
const REJECTION = {
  message: "Não foi possível processar esta solicitação.",
  code: "INPUT_REJECTED",
  // NÃO incluir: matched_patterns, original_input
};
```

---

## 📤 Layer 2: Output Guard

### 2.1 Detectar — Dados sensíveis no output

```javascript
// Code node — Output Sanitization
const output = $input.first().json.result || '';

const PII_PATTERNS = {
  cpf: /\d{3}\.\d{3}\.\d{3}-\d{2}/g,
  email_sensitive: /[a-zA-Z0-9._%+-]+@(empresa|internal|corp)\.[a-zA-Z]{2,}/gi,
  api_key: /(sk-|api_key|apikey|token|bearer)\s*[=:]\s*['"]?[a-zA-Z0-9_-]{20,}/gi,
  password: /(password|senha|pwd)\s*[=:]\s*['"]?[^\s'"]{6,}/gi,
  phone_br: /\(\d{2}\)\s?\d{4,5}-\d{4}/g,
};

let redacted = output;
let findings = [];

for (const [type, pattern] of Object.entries(PII_PATTERNS)) {
  const matches = output.match(pattern);
  if (matches) {
    findings.push({ type, count: matches.length });
    redacted = redacted.replace(pattern, `[${type.toUpperCase()}_REDACTED]`);
  }
}

// Size guard — truncate outputs excessivos
const MAX_OUTPUT = 100000;
if (redacted.length > MAX_OUTPUT) {
  redacted = redacted.substring(0, MAX_OUTPUT) + '\n[OUTPUT_TRUNCATED]';
  findings.push({ type: 'truncated', count: 1 });
}

return [{
  json: {
    output: redacted,
    findings: findings,
    was_modified: findings.length > 0,
    timestamp: new Date().toISOString()
  }
}];
```

### 2.2 Formato de saída

- Respostas DEVEM seguir schema esperado (JSON, Markdown, etc.)
- Outputs fora do formato → logar como anomalia
- Outputs vazios → retornar mensagem de fallback, não silêncio

---

## ⚡ Layer 3: Action Auth

### 3.1 Lista de ações controladas

```json
{
  "destructive": {
    "actions": ["rm -rf", "DROP TABLE", "DELETE FROM", "git reset --hard", "git push --force", "kill -9"],
    "policy": "BLOCK_ALWAYS",
    "override": "explicit_user_confirmation"
  },
  "external": {
    "actions": ["git push", "gh pr create", "curl POST", "webhook trigger", "email send"],
    "policy": "REQUIRE_CONFIRMATION",
    "override": "pre_approved_in_session"
  },
  "sensitive_read": {
    "actions": [".env", "credentials", "secrets", "private_key", "token"],
    "policy": "LOG_AND_ALLOW",
    "override": null
  }
}
```

### 3.2 Enforcement

```javascript
// Code node — Action Authorization
const action = $input.first().json.proposed_action || '';
const actionLower = action.toLowerCase();

const DESTRUCTIVE = ['rm -rf', 'drop table', 'delete from', 'git reset --hard', 'git push --force', 'kill -9'];
const EXTERNAL = ['git push', 'gh pr create', 'curl -x post', 'webhook', 'email send'];

let authorization = 'ALLOWED';
let reason = '';

for (const d of DESTRUCTIVE) {
  if (actionLower.includes(d)) {
    authorization = 'BLOCKED';
    reason = `Destructive action detected: ${d}`;
    break;
  }
}

if (authorization === 'ALLOWED') {
  for (const e of EXTERNAL) {
    if (actionLower.includes(e)) {
      authorization = 'REQUIRES_CONFIRMATION';
      reason = `External action requires approval: ${e}`;
      break;
    }
  }
}

return [{
  json: {
    proposed_action: action,
    authorization,
    reason,
    timestamp: new Date().toISOString(),
    audit_trail: true
  }
}];
```

---

## 📊 Audit Trail

Toda interação com guardrails DEVE ser logada:

```json
{
  "timestamp": "2026-03-23T20:00:00-03:00",
  "layer": "input_guard|output_guard|action_auth",
  "input_hash": "sha256:abc...",
  "decision": "PASS|BLOCK|SANITIZE|REQUIRE_CONFIRMATION",
  "matched_patterns": [],
  "session_id": "session_xyz"
}
```

---

## ✅ Quality Checklist

Antes de considerar guardrails implementados, verificar:

- [ ] Input Guard ativo e testado com 5+ payloads de injection
- [ ] Output Guard redactando PII corretamente (testar com CPF, email, API key)
- [ ] Action Auth bloqueando comandos destrutivos (rm -rf, DROP TABLE, force push)
- [ ] Audit trail logando todas as decisões (PASS, BLOCK, SANITIZE)
- [ ] Falsos positivos < 5% em corpus de textos legítimos
- [ ] Nenhum secret ou PII vaza no output (testar com dados reais sanitizados)
- [ ] Size guards ativos (input < 50KB, output < 100KB)
- [ ] Mensagem de rejeição genérica (não revela patterns detectados)

---

## ⚠️ Gotchas

1. **Falsos positivos em injection detection** — Palavras como "ignore" e "pretend" podem aparecer em contexto legítimo. Usar threshold de 2+ padrões para BLOCK, 1 padrão = SUSPICIOUS.
2. **PII redaction pode quebrar dados válidos** — Regex de CPF pode match números aleatórios. Validar dígitos verificadores antes de redactar.
3. **Action auth não substitui permissões do OS** — É uma camada adicional, não a única. O sandbox do shell ainda é necessário.
4. **Encoding attacks evoluem** — Manter patterns atualizados. Base64-encoded injections são cada vez mais comuns.
5. **Output guard deve rodar ANTES de qualquer cache** — Nunca cachear output não-sanitizado.
