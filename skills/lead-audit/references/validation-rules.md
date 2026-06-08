# ✅ Validation Rules — Leads Febracis

## Regras Ativas no Salesforce

### VR-001: Email Obrigatório
```
ISBLANK(Email)
```
- **Mensagem:** "Email é obrigatório para todos os leads"
- **Bypass:** Nenhum

### VR-002: Telefone com Formato Válido
```
NOT(REGEX(Phone, "\\(\\d{2}\\) \\d{4,5}-\\d{4}"))
```
- **Mensagem:** "Telefone deve estar no formato (XX) XXXXX-XXXX"
- **Bypass:** Profile "Integration User"

### VR-003: Lead Source Preenchido
```
ISBLANK(TEXT(LeadSource))
```
- **Mensagem:** "Lead Source é obrigatório"
- **Bypass:** Nenhum

### VR-004: Consentimento LGPD em Leads de Marketing
```
AND(
  ISPICKVAL(LeadSource, "Marketing Digital"),
  NOT(LGPD_Consent__c)
)
```
- **Mensagem:** "Leads de Marketing Digital requerem consentimento LGPD"
- **Bypass:** Nenhum

## Regras Recomendadas (Não Implementadas)

### VR-R01: Email Normalizado
```
Email != LOWER(TRIM(Email))
```
- **Objetivo:** Forçar email lowercase sem espaços na entrada
- **Status:** Pendente implementação

### VR-R02: Duplicado Bloqueado
- **Objetivo:** Usar Duplicate Rule nativa com Matching Rule por Email
- **Status:** Matching Rule criada, Duplicate Rule em modo "Alert" (não "Block")
- **Recomendação:** Mudar para "Block" durante eventos CIS

## Checklist de Auditoria de Validation Rules

- [ ] Todas as VRs ativas estão listadas acima?
- [ ] Alguma VR foi desativada recentemente? (Setup Audit Trail)
- [ ] Perfis de bypass estão corretos e necessários?
- [ ] VRs recomendadas foram implementadas?
- [ ] Duplicate Rule está em modo correto? (Alert vs Block)
