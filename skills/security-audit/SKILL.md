---
name: security-audit
description: >
  Enterprise-grade security audit patterns inspirados no Trail of Bits (audita protocolos crypto
  bilionários). 3 fases: Context Building → Vulnerability Hunting → Reporting. Integra Semgrep
  rules (OWASP Top 10 2025) e patterns de auditoria profissional. Complementa /cyber com
  metodologia de auditoria estruturada.
domain: security
subdomain: audit-methodology
version: 1.0.0
author: deivithi
license: Apache-2.0
tags:
  - security-audit
  - trail-of-bits
  - semgrep
  - owasp
  - vulnerability-detection
  - code-audit
  - security-review
  - threat-modeling
---

# Security Audit — Enterprise-Grade Patterns (Trail of Bits)

> **"O Trail of Bits audita protocolos que guardam bilhões. Estes são os patterns deles."**

## 📁 File Structure
- `SKILL.md` — Você está aqui. Metodologia completa.
- `references/tob-skills-catalog.md` — Catálogo completo das 35+ skills do Trail of Bits.
- `references/semgrep-rules.md` — Regras Semgrep relevantes para nosso stack.
- `gotchas.md` — ⚠️ Problemas conhecidos.

## 🔗 Related Skills
- `cyber` — Router de 572 skills de cybersecurity (esta skill é um UPGRADE de profundidade)
- `code-review` — Review padrão. security-audit adiciona camada de auditoria profissional
- `guardrails` — Proteção runtime. security-audit é análise estática/manual pré-deploy

---

## 1. Quando Usar

| Cenário | Use `security-audit` | Use `code-review` | Use `/cyber` |
|---------|---------------------|-------------------|--------------|
| Código novo entrando em produção | ✅ | ✅ | ❌ |
| PR de feature simples | ❌ | ✅ | ❌ |
| Auditoria pré-deploy completa | ✅ | ❌ | ❌ |
| Pesquisa de vulnerabilidade específica | ❌ | ❌ | ✅ |
| Código que lida com auth/payments/PII | ✅ | ✅ | ✅ |
| Entender postura de segurança geral | ✅ | ❌ | ✅ |

---

## 2. Metodologia: 3 Fases (Trail of Bits)

### Fase 1 — Context Building (NÃO busque vulnerabilidades aqui)

> Inspirado no `audit-context-building` skill do Trail of Bits.
> **Objetivo:** Entender profundamente a arquitetura ANTES de procurar bugs.

#### 1.1 — Orientação Inicial

```
Para cada codebase auditada, mapear:

□ MÓDULOS: Quais são os módulos/packages principais?
□ ENTRY POINTS: Quais são os pontos de entrada? (rotas, webhooks, CLI, cron jobs)
□ ATORES: Quem interage com o sistema? (usuário anônimo, autenticado, admin, sistema)
□ STORAGE: Onde dados são armazenados? (DB, files, cache, external API)
□ TRUST BOUNDARIES: Onde dados externos entram no sistema?
□ DEPENDÊNCIAS: Quais libs externas são críticas? (auth, crypto, ORM, HTTP client)
```

#### 1.2 — Análise Ultra-Granular (por função crítica)

Para cada função em path crítico (auth, payment, data access):

```
1. LER linha por linha — o que cada linha FAZ (não o que parece fazer)
2. FIRST PRINCIPLES: Por que esta lógica existe? Qual invariante ela mantém?
3. 5 WHYS: Por que é implementada desta forma? (5 níveis de profundidade)
4. 5 HOWS: Como exatamente funciona? (trace completo)
5. CROSS-FUNCTION: Seguir dados através de function boundaries
6. ASSUMPTIONS: Quais suposições implícitas o código faz? (estas são onde bugs moram)
```

#### 1.3 — Anti-Hallucination (obrigatório)

```
REGRAS DE COERÊNCIA (Trail of Bits):
✗ NUNCA adaptar evidências para confirmar hipótese anterior
✗ NUNCA inferir comportamento sem ler o código
✓ Se contradição: atualizar modelo mental explicitamente
✓ Se incerto: declarar "Unclear; need to inspect X"
✓ Cross-reference constante com o entendimento global
```

---

### Fase 2 — Vulnerability Hunting

> Agora sim, com contexto completo, procurar vulnerabilidades.

#### 2.1 — OWASP Top 10 2025 Checklist

| # | Categoria | O que procurar |
|---|-----------|---------------|
| A01 | **Broken Access Control** | Missing auth checks, IDOR, privilege escalation, CORS misconfiguration |
| A02 | **Cryptographic Failures** | Weak algorithms, hardcoded secrets, missing encryption at rest/transit |
| A03 | **Injection** | SQL injection, NoSQL injection, command injection, XSS, template injection |
| A04 | **Insecure Design** | Missing rate limiting, business logic flaws, insufficient anti-automation |
| A05 | **Security Misconfiguration** | Default credentials, unnecessary features enabled, missing security headers |
| A06 | **Vulnerable Components** | Known CVEs in dependencies, outdated packages, unmaintained libs |
| A07 | **Auth Failures** | Weak passwords allowed, missing MFA, session fixation, JWT issues |
| A08 | **Data Integrity Failures** | Insecure deserialization, unsigned updates, CI/CD pipeline tampering |
| A09 | **Logging Failures** | Missing audit trail, PII in logs, insufficient monitoring |
| A10 | **SSRF** | Unvalidated URLs, internal service access, cloud metadata exposure |

#### 2.2 — Semgrep Rules (Automatizado)

```bash
# Instalar Semgrep (se não instalado)
pip install semgrep

# Rodar com ruleset OWASP Top 10
semgrep --config "p/owasp-top-ten" ./src/

# Rodar com rulesets específicos
semgrep --config "p/javascript" --config "p/typescript" ./src/
semgrep --config "p/python" ./backend/

# Rodar com rules do Trail of Bits (quando disponíveis)
semgrep --config "p/trailofbits" ./src/

# Output JSON para processamento
semgrep --config "p/owasp-top-ten" --json ./src/ > semgrep-results.json
```

**Regras Semgrep mais relevantes para nosso stack:**

| Categoria | Rules | Linguagens |
|-----------|-------|-----------|
| SQL Injection | `sql-injection`, `nosql-injection` | JS/TS, Python |
| XSS | `react-dangerouslysetinnerhtml`, `xss` | JS/TS (React) |
| Command Injection | `child-process-injection`, `exec-injection` | JS/TS, Python |
| Path Traversal | `path-traversal` | JS/TS, Python |
| SSRF | `ssrf-requests`, `ssrf-fetch` | JS/TS, Python |
| Hardcoded Secrets | `hardcoded-password`, `hardcoded-token` | Todas |
| Insecure Crypto | `weak-crypto`, `insecure-hash` | Todas |
| Auth Bypass | `jwt-none-algorithm`, `missing-auth-check` | JS/TS |

#### 2.3 — Patterns do Trail of Bits (Manual)

**Pattern 1: Variant Analysis**
```
Dado um bug conhecido em X:
1. Entender a CLASSE do bug (ex: "missing null check before dereference")
2. Buscar VARIANTES do mesmo pattern em todo o codebase
3. Para cada variante: verificar se é exploitável no contexto
4. Documentar TODOS os achados (mesmo false positives — documentar por quê)
```

**Pattern 2: Supply Chain Risk Audit**
```
Para cada dependência:
1. Verificar se tem CVEs conhecidas (npm audit / pip audit)
2. Verificar se é ativamente mantida (last commit, open issues)
3. Verificar se o package é quem diz ser (typosquatting check)
4. Verificar permissões (scripts de postinstall, network access)
```

**Pattern 3: Insecure Defaults**
```
Para cada configuração/feature:
1. Qual é o valor DEFAULT?
2. O default é SEGURO? (principle of least privilege)
3. Se não: documentar como FINDING com severidade
4. Exemplos: debug=true em prod, CORS *, permissive CSP
```

**Pattern 4: Sharp Edges**
```
Identificar APIs/funções que são fáceis de usar de forma insegura:
1. Funções com nomes enganosos (ex: "sanitize" que não sanitiza tudo)
2. Funções que requerem chamadas em ordem específica
3. Funções com side effects não óbvios
4. Configurações onde o comportamento muda drasticamente com 1 flag
```

**Pattern 5: Differential Review**
```
Para cada mudança de código:
1. O que MUDOU exatamente? (diff preciso)
2. O que a mudança ASSUME? (contexto implícito)
3. O que poderia DAR ERRADO? (failure modes)
4. A mudança é CONSISTENTE com o design existente?
```

---

### Fase 3 — Reporting

#### 3.1 — Severity Scoring (Integra com agent-skill-patterns)

| Severity | CVSS | Critério | Ação |
|----------|------|----------|------|
| 🔴 **Critical** | 9.0-10.0 | RCE, auth bypass, data breach | Fix IMEDIATO antes de deploy |
| 🟠 **High** | 7.0-8.9 | Privilege escalation, injection exploitável | Fix antes de produção |
| 🟡 **Medium** | 4.0-6.9 | XSS stored, IDOR com impacto limitado | Fix no próximo sprint |
| 🔵 **Low** | 0.1-3.9 | Info leak menor, missing headers | Backlog |
| ⚪ **Info** | 0.0 | Best practice não seguida, sem exploitabilidade | Nota para melhoria |

#### 3.2 — Template de Report

```markdown
# Security Audit Report

**Projeto:** {nome}
**Data:** {data} BRT
**Auditor:** Claude Code + {humano}
**Escopo:** {arquivos/módulos auditados}
**Metodologia:** Trail of Bits audit-context-building + OWASP Top 10 2025 + Semgrep

## Resumo Executivo

- **Findings totais:** X
- 🔴 Critical: X | 🟠 High: X | 🟡 Medium: X | 🔵 Low: X | ⚪ Info: X
- **Postura geral:** {Seguro / Necessita atenção / Crítico}

## Findings

### [SEV-001] {Título do finding}
- **Severidade:** 🔴 Critical
- **Categoria:** OWASP A03 (Injection)
- **Localização:** `src/api/users.ts:42`
- **Descrição:** {o que está errado}
- **Impacto:** {o que um atacante poderia fazer}
- **Reprodução:** {passos para reproduzir}
- **Recomendação:** {como corrigir}
- **Referência:** {CWE, CVE, docs}

## Recomendações Gerais

1. {recomendação priorizada}
2. ...

## Escopo NÃO Auditado

- {listar o que ficou fora do escopo}
```

#### 3.3 — False Positive Verification (Trail of Bits fp-check)

```
Para cada finding automatizado (Semgrep):
1. REPRODUZIR: O finding é real? Trace o data flow.
2. EXPLOITÁVEL: No contexto real, é exploitável? (sanitização upstream?)
3. IMPACTO: Se exploitado, qual o dano real?
4. CLASSIFICAR:
   - TRUE POSITIVE: Finding real → adicionar ao report
   - FALSE POSITIVE: Documentar POR QUE é falso (útil para tuning)
   - UNDETERMINED: Não conseguiu confirmar → marcar para review humano
```

---

## 3. Integração com Ecossistema

| Skill/Tool | Como Integra |
|-----------|-------------|
| `code-review` | security-audit adiciona Fase 1 (context) e Fase 2 (vuln hunting) ao review padrão |
| `/cyber` | Router geral. security-audit é a metodologia detalhada de auditoria |
| `guardrails` | guardrails = runtime. security-audit = análise estática/manual pré-deploy |
| `agent-skill-patterns` | Severity Scoring usado no report (mesma escala do Reviewer pattern) |
| `deploy-checklist` | Incluir security-audit como gate obrigatório pré-produção |
| `codebase-graph` | Usar impact analysis para priorizar o que auditar |
| `clean-code-rules` | Enforce code quality reduz superfície de ataque |

---

## 4. Quick Reference — Comandos Semgrep

```bash
# OWASP Top 10 completo
semgrep --config "p/owasp-top-ten" ./src/

# Por linguagem
semgrep --config "p/javascript" ./src/
semgrep --config "p/typescript" ./src/
semgrep --config "p/python" ./backend/

# Segurança de secrets
semgrep --config "p/secrets" .

# Supply chain
npm audit --json > npm-audit.json
pip audit --format json > pip-audit.json

# Security headers (se tiver HTTP server)
semgrep --config "p/security-headers" ./src/

# Custom rules (criar as nossas)
semgrep --config ./semgrep-rules/ ./src/
```

---

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Auditoria superficial suficiente | `code-review` | Review padrão quando não há risco alto de segurança |
| Vulnerabilidade específica requer pesquisa | `cyber` | Router de 572 cybersecurity skills especializadas |
| Proteção runtime pós-auditoria | `guardrails` | Input/Output Guard + Action Auth para blindar |
| Findings precisam de fix iterativo | `alpha-loop` | Loop test→fix→retest para resolver vulnerabilidades |
| Auditoria de dependências/supply chain | `deploy-checklist` | Validação pré-deploy com npm audit + pip audit |
