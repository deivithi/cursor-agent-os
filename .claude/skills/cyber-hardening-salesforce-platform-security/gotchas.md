# ⚠️ Gotchas — Salesforce Platform Security Hardening

---

## 1. FLS (Field-Level Security) bypass via API quando Profile tem "API Enabled"

- **Sintoma:** Usuário sem acesso ao campo na UI consegue ler/escrever via API (Data Loader, integração)
- **Causa raiz:** FLS controla acesso na UI e API, MAS se o usuário tem permissão "Modify All Data" ou é System Admin, FLS é ignorado
- **Solução:** Verificar que perfis de integração não têm "Modify All Data". Usar Permission Sets com acesso granular
- **Prevenção:** Criar perfil dedicado para integrações com mínimo privilégio. Auditar com SOQL: `SELECT Id, Name, PermissionsModifyAllData FROM Profile WHERE PermissionsModifyAllData = true`
- **Descoberto em:** 2026-03-18

---

## 2. Sharing Rules "with all internal users" expõe dados entre equipes

- **Sintoma:** Vendedor da equipe A vê leads da equipe B que não deveria
- **Causa raiz:** OWD (Org-Wide Default) está como "Public Read" ou existe Sharing Rule com "All Internal Users"
- **Solução:** Alterar OWD para "Private". Criar Sharing Rules granulares por Role Hierarchy ou Criteria
- **Prevenção:** Nunca usar "All Internal Users" para objetos com dados sensíveis. Usar Role-based sharing
- **Descoberto em:** 2026-03-18

---

## 3. Session Settings padrão permitem sessão ativa por 12h

- **Sintoma:** Usuário deixa sessão aberta no computador compartilhado — outra pessoa acessa o Salesforce
- **Causa raiz:** Session Timeout padrão é 2h (inatividade) mas Lock Session to IP que originou login está desativado
- **Solução:** Setup → Session Settings → Session Timeout = 30min, Lock to originating IP = true, Force Relogin após timeout
- **Prevenção:** Implementar como parte do security hardening baseline
- **Descoberto em:** 2026-03-18

---
