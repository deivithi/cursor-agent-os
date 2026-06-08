---
name: code-review
description: >
  Revisão de código com adversarial review, checklist por severidade e enforcement
  de convenções do projeto. Integra com agent-skill-patterns (Reviewer + Severity Scoring).
  Inclui style guide do Aria e checklist de revisão por tipo de mudança.
domain: quality-assurance
subdomain: code-review
version: 1.0.0
author: deivithi
tags:
  - code-review
  - quality
  - adversarial-review
  - style-guide
  - conventions
  - severity-scoring
---

# 🔍 Code Quality & Review — Revisão de Código

> **"adversarial-review spawna um subagente fresh-eyes para criticar, implementa fixes, itera até findings degradarem a nitpicks."** — Thariq, Anthropic

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Workflow abaixo.
- `references/aria-style-guide.md` — Convenções de código do projeto Aria.
- `references/review-checklist.md` — Checklist de revisão por severidade e tipo.
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `agent-skill-patterns` — Padrão Reviewer com Severity Scoring (base desta skill)
- `cicd` — Rode review antes de deploy para garantir qualidade
- `scaffolding` — Código scaffoldado deve passar por review antes de usar
- `careful` — Ative `/careful` ao revisar código que toca produção

---

## 1. Tipos de Review

### 1.1 Quick Review (Padrão)
**Quando:** Mudanças simples, < 100 linhas, 1-2 arquivos.
**Threshold:** `MEDIUM+` (ignora LOW/INFO)

Checklist rápido:
- [ ] Lógica correta?
- [ ] Sem bugs óbvios?
- [ ] Sem dados sensíveis expostos?
- [ ] Testes cobrem o cenário?

### 1.2 Adversarial Review (Profundo)
**Quando:** Mudanças complexas, > 100 linhas, lógica de negócio, segurança.
**Threshold:** `INFO+` (reporta tudo)

Workflow:
1. **Spawnar subagente** fresh-eyes (sem contexto da implementação)
2. Subagente analisa diff completo contra checklist
3. Classifica findings por severidade (CRITICAL → INFO)
4. Implementar fixes para CRITICAL e HIGH
5. Re-review até todos os findings serem MEDIUM ou abaixo
6. Listar findings restantes como "acknowledged"

### 1.3 Security Review
**Quando:** Mudanças em auth, API, dados pessoais, integração externa.
**Threshold:** `LOW+` (segurança não tolera falsos negativos)

Foco adicional:
- OWASP Top 10 (consultar `cyber` → `implementing-secure-coding-practices-owasp`)
- Input validation (Zod em frontend E backend?)
- Dados sensíveis em logs?
- Secrets em código?
- CORS/headers corretos?

---

## 2. Severity Scoring

Integra com `agent-skill-patterns` → Reviewer pattern:

| Severidade | Critério | Ação |
|-----------|---------|------|
| 🔴 **CRITICAL** | Bug em produção, segurança, perda de dados | **BLOQUEAR** — fix obrigatório |
| 🟠 **HIGH** | Bug provável, performance grave, lógica errada | **FIX** antes de merge |
| 🟡 **MEDIUM** | Code smell, manutenibilidade, naming | **SUGERIR** fix, não bloqueia |
| 🟢 **LOW** | Estilo, preferência, nitpick | **ANOTAR** para referência |
| ⚪ **INFO** | Observação, contexto, elogio | **INFORMAR** apenas |

### Thresholds por Contexto

| Contexto | Threshold | Justificativa |
|----------|-----------|--------------|
| Hotfix de produção | `CRITICAL` only | Velocidade > perfeição |
| Feature normal | `MEDIUM+` | Equilíbrio qualidade/velocidade |
| Refactoring | `HIGH+` | Foco em não quebrar |
| Segurança/LGPD | `LOW+` | Zero tolerância |
| Auditoria completa | `INFO+` | Captura tudo |

---

## 3. Convenções do Projeto

Consultar `references/aria-style-guide.md` para convenções específicas do Aria.

### Regras Universais (Qualquer Projeto)

1. **Sem `any` em TypeScript** — Tipar explicitamente
2. **Sem `console.log` em produção** — Usar logger estruturado
3. **Sem secrets em código** — Usar env vars
4. **Sem try/catch vazio** — Sempre logar ou re-throw
5. **Funções < 50 linhas** — Extrair se maior
6. **Nomes descritivos** — `getUserById` não `getData`
7. **Early return** — Evitar nesting profundo
8. **Imutabilidade** — Preferir `const`, spread, map/filter

> 📏 **Para regras detalhadas por linguagem** (JS/TS, Python): consultar `clean-code-rules` skill.
> Inclui: naming conventions, formatting, imports, error handling, anti-patterns — baseado em Google Style Guide, Airbnb e Clean Code JavaScript.

---

## 4. Workflow Completo

```
MUDANÇA → CLASSIFICAR TIPO → SELECIONAR REVIEW → EXECUTAR → FINDINGS → FIX → RE-REVIEW → APPROVE
```

1. **Classificar:** Simples, Complexo, ou Segurança?
2. **Selecionar:** Quick, Adversarial, ou Security Review
3. **Executar:** Aplicar checklist + severity scoring
4. **Fix:** Corrigir CRITICAL e HIGH
5. **Re-review:** Verificar que fixes não introduziram novos issues
6. **Approve:** Quando todos os findings são MEDIUM ou abaixo

---

## 5. Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Mudanças em auth, API keys, PII | `security-audit` | Review superficial insuficiente — escalar para auditoria completa |
| Findings CRITICAL não resolvidos após re-review | `alpha-loop` | Loop iterativo test→fix→retest para resolver issues persistentes |
| Código viola convenções de estilo sistematicamente | `clean-code-rules` | Enforcement de regras por linguagem (JS/TS, Python) |
| Review aprovado, pronto para deploy | `cicd` | Pipeline de deploy com smoke test pós-deploy |
| Review usa Severity Scoring e precisa de base formal | `agent-skill-patterns` | Padrão Reviewer + Severity Scoring do ADK |

---

## 6. Boas Práticas

1. **Review ANTES de commit, não depois** — Mais barato corrigir cedo
2. **Adversarial review para code de outro dev** — Fresh eyes encontram mais
3. **Não review seu próprio code sozinho** — Viés de confirmação
4. **Severity scoring elimina debates subjetivos** — "É MEDIUM ou HIGH?" tem critério
5. **Gotchas alimentam o review** — Cada bug encontrado vira item no checklist
