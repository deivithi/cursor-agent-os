# ⚠️ Gotchas — Lead Audit

---

## 1. SOQL query timeout em eventos CIS com 10K+ leads no mesmo dia

- **Sintoma:** Query retorna "System.QueryException: Non-selective query" ou timeout
- **Causa raiz:** Salesforce tem limite de 50K rows e 120s. Eventos grandes sem filtro adequado excedem
- **Solução:** Particionar: `WHERE CreatedDate = TODAY AND LeadSource = 'CIS'` e processar em batches de 2K com `LIMIT 2000 OFFSET X`
- **Prevenção:** Sempre incluir pelo menos 2 filtros seletivos (data + source/campaign)
- **Descoberto em:** 2026-03-18

---

## 2. Duplicados não detectados porque email tem espaço trailing

- **Sintoma:** " joao@email.com" e "joao@email.com" são tratados como leads diferentes
- **Causa raiz:** Web-to-Lead ou integração não faz trim no email. SOQL `GROUP BY Email` trata como valores distintos
- **Solução:** Normalizar antes de comparar: `TRIM(LOWER(Email))`. Ou usar Matching Rule nativa do Salesforce
- **Prevenção:** Adicionar validation rule no Lead: `TRIM(Email) != Email` → erro. Forçar normalização na entrada
- **Descoberto em:** 2026-03-18

---

## 3. Lead convertido some da query de auditoria

- **Sintoma:** Total de leads na auditoria é menor que o total real — leads convertidos não aparecem
- **Causa raiz:** `FROM Lead WHERE IsConverted = false` é o filtro default. Leads convertidos ficam fora
- **Solução:** Para auditoria completa, incluir: `WHERE IsConverted IN (true, false)` ou usar `FROM Lead ALL ROWS` (admin only)
- **Prevenção:** Definir no escopo da auditoria se inclui convertidos ou não. Documentar no relatório
- **Descoberto em:** 2026-03-18

---
