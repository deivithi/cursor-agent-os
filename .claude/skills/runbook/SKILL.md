---
name: runbook
description: >
  Skills que recebem um sintoma (alerta, erro, thread no Slack) e conduzem uma investigação
  estruturada multi-tool, produzindo um relatório com findings e recomendações. Inclui runbooks
  para Salesforce, Aria e auditoria de leads Febracis.
domain: operations
subdomain: incident-investigation
version: 1.0.0
author: deivithi
tags:
  - runbook
  - troubleshooting
  - investigation
  - incident
  - diagnostic
  - salesforce
  - aria
  - leads
---

# 📋 Runbook — Investigação Estruturada de Problemas

> **"Runbooks pegam um sintoma e caminham por uma investigação multi-tool até produzir um relatório estruturado."** — Thariq, Anthropic

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Framework abaixo.
- `scripts/run-diagnostic.sh` — Coleta diagnóstico genérico (logs, status, env).
- `references/salesforce-runbooks.md` — Problemas comuns de Salesforce.
- `references/aria-runbooks.md` — Deploy fail, API down, edge functions, Vercel.
- `references/lead-audit-runbook.md` — Sanitização, duplicados, regras CIS.
- `templates/runbook-template.md` — Template: sintoma → investigação → relatório.
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `product-verification` — Use para verificar se o fix resolveu o problema
- `cicd` — Use para re-deploy após aplicar correção
- `cyber` — Use se o problema tiver implicações de segurança

---

## 1. Framework de Investigação

Todo runbook segue o mesmo fluxo:

```
SINTOMA → TRIAGE → INVESTIGAÇÃO → DIAGNÓSTICO → AÇÃO → VERIFICAÇÃO → RELATÓRIO
```

### 1.1 Sintoma (Entrada)
O que disparou a investigação:
- Alerta de monitoramento
- Erro reportado por usuário
- Thread no Slack/email
- Métrica fora do esperado
- Deploy que falhou

### 1.2 Triage (30 segundos)
Classificação rápida de severidade:

| Severidade | Critério | SLA |
|-----------|---------|-----|
| 🔴 **P0 — Crítico** | Produção down, dados corrompidos, segurança | Imediato |
| 🟠 **P1 — Alto** | Funcionalidade principal quebrada, impacto em usuários | 1 hora |
| 🟡 **P2 — Médio** | Funcionalidade secundária, workaround existe | 4 horas |
| 🟢 **P3 — Baixo** | Cosmético, performance minor, melhoria | Próximo sprint |

### 1.3 Investigação (Coleta de Dados)
Coletar dados de TODAS as fontes relevantes antes de diagnosticar:

```bash
# Executar diagnóstico genérico
bash .claude/skills/runbook/scripts/run-diagnostic.sh

# Fontes específicas por projeto:
# Aria → vercel logs, supabase logs, edge function logs
# Landing → netlify logs, form submissions
# Salesforce → debug logs, apex exception emails
```

### 1.4 Diagnóstico
Com dados coletados, identificar:
- **Causa raiz** (não sintoma!)
- **Componentes afetados**
- **Desde quando** (timeline)
- **Blast radius** (o que mais pode estar afetado)

### 1.5 Ação
Definir e executar a correção:
- Se P0/P1: mitigar PRIMEIRO, fix permanente DEPOIS
- Se P2/P3: fix permanente direto

### 1.6 Verificação
Usar `product-verification` skill para confirmar que o fix resolveu.

### 1.7 Relatório
Gerar relatório usando `templates/runbook-template.md`.

---

## 2. Runbooks por Domínio

### 2.1 Salesforce
Consultar `references/salesforce-runbooks.md` para:
- Apex Exceptions
- Flow/Process Builder failures
- Integration failures (API limits, auth expired)
- Data quality issues (duplicados, campos vazios)
- Permission/sharing errors

### 2.2 Aria (SaaS)
Consultar `references/aria-runbooks.md` para:
- Deploy Vercel falhou
- Edge function timeout/error
- Supabase connection issues
- API returning 500
- Auth/JWT problems

### 2.3 Leads (Febracis)
Consultar `references/lead-audit-runbook.md` para:
- Leads duplicados pós-evento CIS
- Leads sem dados obrigatórios
- Leads não atribuídos a vendedores
- Inconsistência entre fontes (Marketing Cloud vs Sales Cloud)
- Volume anômalo (muito alto ou muito baixo)

---

## 3. Boas Práticas

1. **Nunca pular triage** — 30 segundos de classificação economizam horas de investigação no caminho errado
2. **Coletar antes de diagnosticar** — Não formular hipótese sem dados. Viés de confirmação é o maior inimigo
3. **Timeline é crucial** — "Desde quando?" ajuda a correlacionar com deploys, mudanças de config, picos de tráfego
4. **Documentar TUDO** — Cada investigação alimenta o próximo runbook. Se descobrir algo novo, adicionar ao `gotchas.md`
5. **Verificar o fix** — Nunca considerar "resolvido" sem evidência de que o fix funcionou
