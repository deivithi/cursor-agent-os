---
name: lead-audit
description: >
  Workflow de auditoria de leads Febracis. Sanitização, detecção de duplicados,
  validação de campos obrigatórios, atribuição a vendedores e regras específicas
  do Método CIS (alto volume de leads em eventos). Inclui scripts de diagnóstico
  e log de execuções para inteligência cumulativa.
domain: business-process
subdomain: lead-management
version: 1.0.0
author: deivithi
tags:
  - leads
  - audit
  - salesforce
  - sanitization
  - duplicates
  - cis
  - febracis
  - data-quality
---

# 🎯 Lead Audit — Auditoria de Leads Febracis

> **"Business Process skills automatizam workflows repetitivos em um comando. Salvar resultados anteriores em logs ajuda o modelo a ficar consistente."** — Thariq, Anthropic

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Workflow abaixo.
- `scripts/sanitize-leads.sh` — Pipeline de sanitização (campos vazios, formatos).
- `scripts/detect-duplicates.sh` — Detecção de leads duplicados por email/telefone.
- `references/lead-schema.md` — Schema de leads no Salesforce Febracis.
- `references/validation-rules.md` — Regras de validação ativas e esperadas.
- `references/cis-event-rules.md` — Regras específicas do Método CIS (alto volume).
- `data/audit-log.jsonl` — Log de execuções anteriores (append-only, memória da skill).
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `runbook` — Use `references/lead-audit-runbook.md` para investigação de problemas de leads
- `cyber` → `implementing-lgpd-data-protection-compliance` — Para compliance LGPD nos dados de leads
- `science` — Use Polars/Pandas para análise exploratória de dados de leads
- `product-verification` — Verifique que os forms de captação estão funcionando

---

## 1. Workflow de Auditoria

```
COLETA → SANITIZAÇÃO → DEDUP → VALIDAÇÃO → ATRIBUIÇÃO → REPORT
```

### 1.1 Coleta de Dados

Fonte primária: **Salesforce SOQL**

```soql
-- Leads recentes (últimos 7 dias)
SELECT Id, Name, Email, Phone, LeadSource, Status, Owner.Name,
       CreatedDate, ConvertedDate, Campaign.Name
FROM Lead
WHERE CreatedDate = LAST_N_DAYS:7
ORDER BY CreatedDate DESC
LIMIT 5000
```

```soql
-- Leads de evento CIS específico
SELECT Id, Name, Email, Phone, LeadSource, Status, Owner.Name
FROM Lead
WHERE Campaign.Name = 'CIS [Nome do Evento]'
  AND CreatedDate = TODAY
ORDER BY CreatedDate DESC
```

### 1.2 Sanitização

Verificar e corrigir:

| Campo | Regra | Ação |
|-------|-------|------|
| **Email** | Formato válido, lowercase, sem espaços | Normalizar |
| **Telefone** | Formato (XX) XXXXX-XXXX, DDD válido | Normalizar |
| **Nome** | Não vazio, capitalizado, sem caracteres especiais | Corrigir |
| **Lead Source** | Valor de picklist válido | Alertar se inválido |
| **Status** | Valor de picklist válido | Alertar se vazio |

**Script:** `scripts/sanitize-leads.sh`

### 1.3 Detecção de Duplicados

Critérios de matching:

| Prioridade | Critério | Confiança |
|-----------|---------|-----------|
| 1 | Email idêntico (case-insensitive) | 🔴 Certo |
| 2 | Telefone idêntico (normalizado) | 🟠 Alta |
| 3 | Nome + Empresa idênticos | 🟡 Média |
| 4 | Nome similar (Levenshtein < 2) + mesmo DDD | 🟢 Baixa |

```soql
-- Duplicados por email
SELECT Email, COUNT(Id) cnt, MIN(CreatedDate) first, MAX(CreatedDate) last
FROM Lead
WHERE Email != null
  AND CreatedDate = LAST_N_DAYS:7
GROUP BY Email
HAVING COUNT(Id) > 1
ORDER BY COUNT(Id) DESC
```

**Script:** `scripts/detect-duplicates.sh`

### 1.4 Validação de Campos Obrigatórios

Consultar `references/validation-rules.md` para regras ativas.

```soql
-- Leads sem campos obrigatórios
SELECT Id, Name, Email, Phone, LeadSource
FROM Lead
WHERE CreatedDate = LAST_N_DAYS:7
  AND (Email = null OR Phone = null OR LeadSource = null)
```

### 1.5 Verificação de Atribuição

```soql
-- Leads não atribuídos (na Queue ou com Admin)
SELECT Id, Name, Owner.Name, Owner.Type, CreatedDate
FROM Lead
WHERE Owner.Type = 'Queue'
  AND CreatedDate = LAST_N_DAYS:3
ORDER BY CreatedDate ASC
```

**SLA:** Leads devem ser atribuídos em < 30 min durante eventos CIS.

### 1.6 Relatório de Auditoria

Gerar relatório com:

```markdown
## 📊 Relatório de Auditoria de Leads — DD/MM/YYYY

### Resumo
- **Período:** [data início] — [data fim]
- **Total de leads:** X
- **Duplicados encontrados:** X (Y%)
- **Campos obrigatórios vazios:** X (Y%)
- **Não atribuídos:** X
- **Tempo médio de atribuição:** Xmin

### Findings
| # | Severidade | Finding | Quantidade | Ação |
|---|-----------|---------|-----------|------|
| 1 | 🔴 | Duplicados por email | X | Merge |
| 2 | 🟠 | Sem telefone | X | Completar |
| 3 | 🟡 | Na Queue > 2h | X | Atribuir |

### Ações Recomendadas
1. ...
2. ...
```

### 1.7 Logging (Memória da Skill)

Cada execução é logada em `data/audit-log.jsonl`:

```jsonl
{"date":"2026-03-18","period":"7d","total":1250,"duplicates":45,"missing_fields":23,"unassigned":12,"score":"B+"}
```

Isso permite ao Claude comparar com execuções anteriores e identificar tendências.

---

## 2. Contexto — Eventos CIS

O Método CIS gera **alto volume de leads** em curtos períodos. Regras específicas em `references/cis-event-rules.md`.

**Métricas de referência:**

| Métrica | Normal | Evento CIS | Alerta |
|---------|--------|-----------|--------|
| Leads/hora | 5-20 | 50-200 | < 10 ou > 500 |
| Taxa de duplicados | < 3% | < 5% | > 10% |
| Campos vazios | < 1% | < 3% | > 5% |
| Atribuição | < 2h | < 30min | > 2h |

---

## 3. Anti-Patterns — O que NÃO Fazer

| ❌ Anti-Pattern | Causa | Consequência | Regra |
|----------------|-------|-------------|-------|
| Rodar auditoria só pós-evento | Pressa, falta de processo | Leads duplicados já convertidos incorretamente, comissões erradas | NUNCA esperar pós-evento — rodar DIARIAMENTE durante CIS |
| Ignorar duplicados < 5% | "É pouco" | Acumula ao longo de campanhas, polui pipeline | SEMPRE tratar duplicados mesmo em % baixo |
| Merge manual sem backup | Confiança excessiva | Perda de dados de leads legítimos | NUNCA fazer merge sem snapshot prévio exportado |
| Sanitizar sem validar schema | Pular etapas | Campos normalizados para formato errado | SEMPRE consultar `references/lead-schema.md` antes |
| Atribuir leads sem verificar Owner Queue | Automação cega | Leads ficam em queues fantasma (inativas) | SEMPRE validar que a Queue-alvo está ativa e com membros |

---

## 4. Boas Práticas

1. **Rodar auditoria DIARIAMENTE** durante eventos CIS — não esperar o pós-evento
2. **Comparar com execuções anteriores** — o log em `data/audit-log.jsonl` permite isso
3. **Escalar duplicados > 10%** imediatamente — indica problema no form ou integração
4. **Verificar atribuição em real-time** durante eventos — leads esfriando = vendas perdidas
5. **Documentar findings** — cada auditoria alimenta o próximo gotcha

---

## 5. Checklist de Verificação Pré-Entrega

Antes de finalizar qualquer auditoria, verificar:

```
□ Dados coletados cobrem o período correto?
□ Sanitização rodou sem erros (scripts/sanitize-leads.sh)?
□ Duplicados detectados e quantificados?
□ Campos obrigatórios vazios identificados e reportados?
□ Atribuição verificada (sem leads órfãos em Queues)?
□ Relatório gerado com findings e severidades?
□ Log atualizado em data/audit-log.jsonl?
□ Comparação com auditoria anterior realizada?
□ Ações recomendadas são executáveis e específicas?
```
