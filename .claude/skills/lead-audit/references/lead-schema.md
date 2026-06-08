# 📋 Lead Schema — Salesforce Febracis

## Campos Padrão

| Campo | API Name | Tipo | Obrigatório | Notas |
|-------|----------|------|------------|-------|
| Nome | `Name` | Text | ✅ | First + Last Name |
| Email | `Email` | Email | ✅ | Normalizar: lowercase, trim |
| Telefone | `Phone` | Phone | ✅ | Formato: (XX) XXXXX-XXXX |
| Empresa | `Company` | Text | ✅ (SF default) | Nome da empresa ou "Pessoa Física" |
| Lead Source | `LeadSource` | Picklist | ✅ | Origem do lead |
| Status | `Status` | Picklist | ✅ | Etapa no funil |
| Owner | `OwnerId` | Lookup | ✅ | Vendedor ou Queue |
| Campaign | `CampaignId` | Lookup | ⬜ | Evento/campanha associada |

## Valores de Picklist — Lead Source

| Valor | Descrição | Volume Típico |
|-------|-----------|--------------|
| `Web` | Site institucional | Baixo |
| `CIS Evento` | Evento presencial CIS | 🔴 Alto |
| `CIS Online` | Evento online CIS | Alto |
| `Indicação` | Referral de aluno/cliente | Médio |
| `Marketing Digital` | Campanha Meta/Google | Médio-Alto |
| `Parceiro` | Canal de parceiros | Baixo |
| `Reativação` | Lead antigo reativado | Variável |

## Valores de Picklist — Status

| Valor | Significado | SLA |
|-------|------------|-----|
| `Novo` | Recém-criado, não contactado | Atribuir em < 30min (CIS) |
| `Contactado` | Primeiro contato realizado | Follow-up em 24h |
| `Qualificado` | Interesse confirmado | Converter em 48h |
| `Não Qualificado` | Sem fit/interesse | Mover para nurturing |
| `Convertido` | Virou Opportunity + Contact | — |

## Campos Customizados Relevantes

| Campo | API Name | Tipo | Uso |
|-------|----------|------|-----|
| Consentimento LGPD | `LGPD_Consent__c` | Checkbox | Opt-in para contato |
| Data Consentimento | `LGPD_Consent_Date__c` | DateTime | Timestamp do opt-in |
| Score | `Lead_Score__c` | Number | Pontuação de qualificação |
| Evento CIS | `CIS_Event__c` | Text | Nome do evento de origem |
| WhatsApp | `WhatsApp__c` | Phone | Número para WhatsApp |

## Índices de Qualidade

| Métrica | Fórmula | Bom | Aceitável | Ruim |
|---------|---------|-----|-----------|------|
| Completude | Campos preenchidos / Total campos | > 95% | 85-95% | < 85% |
| Duplicação | Duplicados / Total leads | < 3% | 3-5% | > 5% |
| Atribuição | Tempo médio até assignment | < 30min | 30min-2h | > 2h |
| Conversão | Convertidos / Total leads | > 5% | 3-5% | < 3% |
