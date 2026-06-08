# ⚠️ Gotchas — Runbook

> Problemas conhecidos ao executar runbooks de investigação. Consulte quando algo falhar.

---

## 1. Logs do Vercel expiram em 1 hora para plano Hobby

- **Sintoma:** `vercel logs` retorna vazio ou "no logs found" para incidente que aconteceu há mais de 1h
- **Causa raiz:** No plano Hobby/Pro do Vercel, runtime logs são retidos por apenas 1 hora. Após isso, são deletados permanentemente
- **Solução:** Capturar logs IMEDIATAMENTE ao receber alerta. Se já expirou, verificar se há logs no Supabase ou no monitoring externo
- **Prevenção:** Configurar log drain externo (Axiom, Datadog) para reter logs além do TTL padrão
- **Descoberto em:** 2026-03-18

---

## 2. Diagnóstico enviesado por "último deploy" quando a causa é externa

- **Sintoma:** Investigação foca no último deploy como causa, mas o problema real é uma API externa (Salesforce, Stripe) que mudou comportamento
- **Causa raiz:** Viés de correlação temporal — "quebrou depois do deploy, logo o deploy causou"
- **Solução:** SEMPRE verificar status de APIs externas ANTES de investigar código interno. Checar status pages, API response times, e rate limits
- **Prevenção:** Adicionar "Checar APIs externas" como step obrigatório no triage, antes de olhar código
- **Descoberto em:** 2026-03-18

---

## 3. Runbook de leads CIS com volume alto causa timeout no SOQL

- **Sintoma:** Query SOQL para auditoria de leads retorna timeout ou "exceeded query rows" em eventos com 10K+ leads
- **Causa raiz:** Salesforce tem limite de 50K rows por query SOQL e 120s de timeout. Eventos CIS grandes excedem isso
- **Solução:** Particionar a query por data (lead created date) ou por fonte (Campaign). Processar em batches de 5K
- **Prevenção:** Sempre incluir filtro `WHERE CreatedDate = TODAY` ou `LIMIT 5000` em queries de auditoria
- **Descoberto em:** 2026-03-18

---
