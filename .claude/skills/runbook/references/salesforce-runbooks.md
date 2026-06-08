# ☁️ Runbooks — Salesforce

> Runbooks para problemas comuns no ecossistema Salesforce Febracis.

---

## RB-SF-001: Apex Exception em Trigger/Flow

**Sintoma:** Email de "Apex Exception" ou erro em Flow/Process Builder
**Triage:** P1 se afeta criação de leads, P2 caso contrário

**Investigação:**
1. Checar email de exception → extrair stack trace
2. Setup → Apex Exception Email → revisar últimos logs
3. Setup → Debug Logs → ativar para usuário afetado
4. Developer Console → Query Logs → buscar por `ApexTrigger` ou `Flow`

**Causas comuns:**
- Governor limits excedidos (SOQL 101, DML 150)
- Null pointer em campo não preenchido
- Recursão de trigger sem flag de controle
- Flow desatualizado referenciando campo removido

**Ação:**
- Se governor limit: otimizar bulkificação
- Se null pointer: adicionar null check
- Se recursão: implementar static flag
- Se flow: atualizar referência de campo

---

## RB-SF-002: Integração Falhando (API Limits)

**Sintoma:** Integração externa retorna erro 503 ou "REQUEST_LIMIT_EXCEEDED"
**Triage:** P1 se integração crítica (pagamento, lead sync)

**Investigação:**
1. Setup → Company Information → API Requests Last 24h
2. Setup → API Usage Notifications → checar threshold
3. Verificar se há batch job consumindo requests em excesso

**Causas comuns:**
- Sincronização full em vez de delta
- Loop de retry sem backoff
- Múltiplas integrações competindo pelo mesmo limite

**Ação:**
- Implementar delta sync (filtrar por LastModifiedDate)
- Adicionar exponential backoff nos retries
- Agendar integrações pesadas para horário de baixo uso

---

## RB-SF-003: Leads Não Atribuídos

**Sintoma:** Leads criados mas sem Owner atribuído (ou atribuídos ao admin)
**Triage:** P1 em período de evento CIS

**Investigação:**
1. Setup → Lead Assignment Rules → verificar regras ativas
2. Verificar se Lead Source está preenchido corretamente
3. Checar se a Queue de destino tem membros ativos
4. Verificar Web-to-Lead form → campo `oid` e assignment rule checkbox

**Causas comuns:**
- Assignment rule desativada
- Critérios de regra não matching (Lead Source diferente do esperado)
- Queue sem membros ou com membros inativos
- Web-to-Lead sem `assignmentRule` checkbox

**Ação:**
- Reativar ou ajustar critérios da Assignment Rule
- Adicionar membros à Queue
- Corrigir form Web-to-Lead

---

## RB-SF-004: Dados Inconsistentes entre Clouds

**Sintoma:** Dado existe no Marketing Cloud mas não no Sales Cloud (ou vice-versa)
**Triage:** P2

**Investigação:**
1. Marketing Cloud → Contact Builder → buscar registro por email
2. Sales Cloud → buscar mesmo email em Leads + Contacts
3. Verificar Marketing Cloud Connect → Sync status
4. Verificar Mapping → campos mapeados estão corretos?

**Causas comuns:**
- Sync schedule atrasado ou pausado
- Filtro de sync excluindo registros (ex: leads sem email)
- Campo de matching (Email) com formato diferente entre clouds
- Subscriber Key diferente do Lead/Contact ID

**Ação:**
- Verificar e retomar sync schedule
- Ajustar filtros de sincronização
- Padronizar formato de email (lowercase, trim)
