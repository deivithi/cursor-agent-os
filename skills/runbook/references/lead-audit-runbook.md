# 🎯 Runbooks — Auditoria de Leads Febracis

> Runbooks para problemas de qualidade, sanitização e atribuição de leads, especialmente durante eventos CIS de alto volume.

---

## RB-LEAD-001: Leads Duplicados Pós-Evento CIS

**Sintoma:** Volume anormal de leads com mesmo email/telefone após evento
**Triage:** P1 durante evento, P2 pós-evento

**Investigação:**
1. SOQL: `SELECT Email, COUNT(Id) FROM Lead WHERE CreatedDate = TODAY GROUP BY Email HAVING COUNT(Id) > 1`
2. Verificar fonte: `SELECT LeadSource, COUNT(Id) FROM Lead WHERE CreatedDate = TODAY GROUP BY LeadSource`
3. Checar se Web-to-Lead está gerando duplicados (form submit duplo)
4. Verificar se integração Marketing Cloud está sincronizando duplicados

**Causas comuns:**
- Form sem proteção contra double-submit
- Integração re-sincronizando leads já existentes
- QR Code escaneado múltiplas vezes pelo mesmo participante
- Sem matching rule ativa para dedup

**Ação:**
- Ativar Duplicate Rule com Matching Rule por Email
- Adicionar debounce no form (disabled button pós-submit)
- Configurar upsert (não insert) na integração
- Merge manual dos duplicados já criados

---

## RB-LEAD-002: Leads Sem Dados Obrigatórios

**Sintoma:** Leads com campos críticos vazios (Nome, Email, Telefone, Lead Source)
**Triage:** P2

**Investigação:**
1. SOQL: `SELECT Id, Name, Email, Phone, LeadSource FROM Lead WHERE (Email = null OR Phone = null) AND CreatedDate = LAST_N_DAYS:7`
2. Verificar validation rules ativas: Setup → Lead → Validation Rules
3. Verificar form de origem: campos estão como required?
4. Verificar integração: mapping está completo?

**Causas comuns:**
- Validation rule desativada ou bypass por perfil
- Form sem validação client-side
- API integration sem campo obrigatório no mapping
- Import via Data Loader sem todos os campos

**Ação:**
- Reativar/criar validation rules obrigatórias
- Adicionar required + pattern validation no form HTML
- Corrigir mapping da integração
- Template de Data Loader com campos obrigatórios

---

## RB-LEAD-003: Leads Não Atribuídos a Vendedores

**Sintoma:** Leads na Queue genérica ou atribuídos ao Admin por muito tempo
**Triage:** P1 em período de evento (leads esfriando)

**Investigação:**
1. SOQL: `SELECT Id, Owner.Name, CreatedDate FROM Lead WHERE Owner.Type = 'Queue' AND CreatedDate = LAST_N_DAYS:3`
2. Verificar Assignment Rules: Setup → Lead Assignment Rules
3. Verificar Queue membership: Setup → Queues → membros ativos
4. Round-robin: verificar se está configurado e funcionando

**Ação:**
- Corrigir critérios de Assignment Rule
- Adicionar vendedores à Queue
- Implementar auto-assignment via Flow (Round Robin)
- Alertar sales manager sobre leads pendentes

---

## RB-LEAD-004: Volume Anômalo (Muito Alto ou Muito Baixo)

**Sintoma:** Volume de leads no dia diverge significativamente do esperado
**Triage:** P1 se durante evento CIS (expectativa de alto volume)

**Investigação:**
1. Baseline: `SELECT COUNT(Id), DAY_ONLY(CreatedDate) FROM Lead WHERE CreatedDate = LAST_N_DAYS:30 GROUP BY DAY_ONLY(CreatedDate)`
2. Volume hoje vs média: comparar com baseline
3. Se muito baixo: form está acessível? QR code correto? Integração rodando?
4. Se muito alto: ataque de spam? Bot? Form sem captcha?

**Causas comuns:**
- **Baixo:** Form offline, QR code apontando para URL errada, integração pausada
- **Alto:** Bot spam, form sem reCAPTCHA, campanha duplicada

**Ação:**
- Baixo: verificar infra (site, form, integração). Corrigir e reprocessar
- Alto: adicionar reCAPTCHA, filtrar por honeypot, bloquear IPs suspeitos
- Em ambos: alertar equipe de vendas sobre o status

---

## Métricas de Referência — Eventos CIS

| Métrica | Valor Esperado | Alerta |
|---------|---------------|--------|
| Leads/hora durante evento | 50-200 | < 20 ou > 500 |
| Taxa de duplicados | < 5% | > 10% |
| Campos obrigatórios vazios | < 2% | > 5% |
| Tempo até atribuição | < 30 min | > 2 horas |
| Taxa de conversão esperada | 3-8% | < 1% |
