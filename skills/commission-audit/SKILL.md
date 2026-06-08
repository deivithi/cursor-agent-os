---
name: commission-audit
description: >
  Workflow de auditoria de comissões Febracis. Validação de regras de cálculo,
  verificação de pagamentos, detecção de inconsistências e checklist de conferência.
  Focado em precisão e rastreabilidade para evitar erros de pagamento.
domain: business-process
subdomain: commission-management
version: 1.0.0
author: deivithi
tags:
  - commission
  - audit
  - salesforce
  - payment
  - validation
  - febracis
---

# 💰 Commission Audit — Auditoria de Comissões Febracis

> **"Cada automação gerada por IA deve ser auditada contra inconsistências."** — CLAUDE.md

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Workflow abaixo.
- `references/commission-rules.md` — Regras de cálculo de comissão por tipo.
- `references/validation-checklist.md` — Checklist completo de validação.
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `lead-audit` — Qualidade dos leads impacta diretamente cálculo de comissão
- `runbook` — Use para investigar discrepâncias encontradas na auditoria
- `science` — Use SymPy para validar fórmulas de comissão matematicamente

---

## 1. Workflow de Auditoria

```
EXTRAIR DADOS → APLICAR REGRAS → COMPARAR → DETECTAR DIVERGÊNCIAS → REPORT
```

### 1.1 Extrair Dados

Dados necessários para auditoria:

| Fonte | Dados | Query |
|-------|-------|-------|
| Opportunities | Valor fechado, data, vendedor, produto | SOQL |
| Comissões calculadas | Valor comissão, regra aplicada, status | SOQL/Report |
| Pagamentos | Valor pago, data pagamento, comprovante | Sistema financeiro |

```soql
-- Opportunities fechadas no período
SELECT Id, Amount, CloseDate, Owner.Name, Product__c,
       StageName, Commission_Amount__c, Commission_Rule__c
FROM Opportunity
WHERE StageName = 'Closed Won'
  AND CloseDate >= 2026-03-01
  AND CloseDate <= 2026-03-31
ORDER BY Owner.Name, CloseDate
```

### 1.2 Aplicar Regras

Consultar `references/commission-rules.md` para as regras vigentes.

Para cada Opportunity:
1. Identificar a regra de comissão aplicável (por produto, tier, campanha)
2. Calcular comissão esperada: `Amount × Rate`
3. Comparar com valor registrado no Salesforce (`Commission_Amount__c`)

### 1.3 Detectar Divergências

| Tipo | Critério | Severidade |
|------|---------|-----------|
| **Valor diferente** | Calculado ≠ Registrado (tolerância: R$ 0,01) | 🔴 Alto |
| **Regra errada** | Regra aplicada ≠ Regra esperada para o produto | 🔴 Alto |
| **Sem comissão** | Opp fechada sem comissão calculada | 🟠 Médio |
| **Comissão dupla** | Mesmo vendedor com 2 comissões na mesma Opp | 🔴 Alto |
| **Vendedor errado** | Comissão para vendedor que não é Owner | 🟠 Médio |

### 1.4 Relatório

```markdown
## 📊 Relatório de Auditoria de Comissões — MM/YYYY

### Resumo
- **Período:** [mês/ano]
- **Opportunities auditadas:** X
- **Valor total de comissões:** R$ X.XXX,XX
- **Divergências encontradas:** X

### Divergências
| # | Opp ID | Vendedor | Esperado | Registrado | Diff | Tipo |
|---|--------|----------|----------|-----------|------|------|
| 1 | ... | ... | R$ X | R$ Y | R$ Z | Valor |

### Ações
1. Corrigir divergência #1: ...
2. ...
```

---

## 2. Princípios de Auditoria

1. **Nunca confiar apenas no sistema** — Recalcular SEMPRE, mesmo que o Salesforce mostre "correto"
2. **Tolerância zero** para divergências > R$ 1,00 — qualquer diferença deve ser investigada
3. **Rastreabilidade** — toda correção deve ser documentada com motivo e aprovação
4. **Segregação** — quem calcula não deve ser quem aprova. Auditoria é independente
5. **Periodicidade** — auditoria mensal ANTES do pagamento, não depois

---

## 3. ◆ Diamond Gates

| Operação | Gate |
|----------|------|
| Aprovar pagamento de comissões | ◆ DIAMOND — Irreversível financeiramente |
| Alterar regra de comissão | ◆ DIAMOND — Impacta cálculos futuros |
| Corrigir comissão retroativamente | ◆ DIAMOND — Impacta financeiro já fechado |
