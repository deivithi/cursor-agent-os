# ⚠️ Gotchas — Commission Audit

---

## 1. Opportunity com Amount alterado após cálculo de comissão

- **Sintoma:** Comissão calculada com base em valor antigo da Opportunity. Após negociação, Amount mudou mas comissão não foi recalculada
- **Causa raiz:** Cálculo de comissão é feito uma vez (ao fechar) e não é retriggered quando Amount muda
- **Solução:** Recalcular comissões para todas as Opps com LastModifiedDate > Commission_Calculated_Date
- **Prevenção:** Workflow/Flow que recalcula comissão automaticamente quando Amount de Opp fechada muda
- **Descoberto em:** 2026-03-18

---

## 2. Comissão calculada com taxa do mês errado

- **Sintoma:** Vendedor deveria receber 8% (taxa do mês atual) mas recebeu 5% (taxa do mês anterior)
- **Causa raiz:** Regra de comissão usa CloseDate da Opportunity, mas a tabela de taxas foi atualizada no dia 1 do mês. Opps fechadas antes da atualização pegam taxa antiga
- **Solução:** Definir claramente: taxa válida é a da data de fechamento ou a data de cálculo? Alinhar com financeiro
- **Prevenção:** Versionamento de tabela de taxas com data de vigência explícita. Nunca sobrescrever taxa anterior
- **Descoberto em:** 2026-03-18

---

## 3. Split commission sem somar 100%

- **Sintoma:** Dois vendedores recebem comissão na mesma Opportunity, mas os percentuais somam mais ou menos que 100%
- **Causa raiz:** Split foi definido manualmente sem validação. Um vendedor com 60% e outro com 50% = 110%
- **Solução:** Adicionar validation rule: soma dos splits de uma Opp DEVE = 100%
- **Prevenção:** Validation rule no Opportunity Team Member que valida soma antes de salvar
- **Descoberto em:** 2026-03-18

---
