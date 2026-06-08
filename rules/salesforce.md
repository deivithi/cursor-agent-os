---
paths: ["**/*.cls", "**/*.trigger", "**/*.apex", "**/force-app/**", "**/*salesforce*", "**/*sfdc*"]
---

# Salesforce Rules

- FLS (Field-Level Security): SEMPRE respeitar — nunca bypassing
- Sharing rules: usar `with sharing` como padrão em Apex
- Bulk patterns: NUNCA queries/DML dentro de loops
- Governor limits: verificar SOQL (100), DML (150), callouts (100)
- Shield: Platform Encryption para campos sensíveis
- Experience Cloud: verificar guest user permissions
- Dados de lead: validar campos obrigatórios antes de insert (consultar `/lead-audit`)
- Comissões: validar regras de cálculo antes de processar (consultar `/commission-audit`)
