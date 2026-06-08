# ⚠️ Gotchas — LGPD Data Protection Compliance

---

## 1. Consentimento coletado no Marketing Cloud não sincroniza para Sales Cloud

- **Sintoma:** Lead deu opt-in no formulário, mas no Salesforce Sales Cloud o campo de consentimento está vazio
- **Causa raiz:** Marketing Cloud Connect sincroniza dados mas não sincroniza campos customizados de consentimento automaticamente. O mapping precisa incluir explicitamente o campo de opt-in
- **Solução:** Verificar Synchronized Data Sources → Field Mapping → garantir que o campo de consentimento LGPD está mapeado
- **Prevenção:** Ao criar novo campo de consentimento, SEMPRE adicionar ao mapping de sync MC↔SC
- **Descoberto em:** 2026-03-18

---

## 2. RIPD (Relatório de Impacto) desatualizado após mudança no fluxo de dados

- **Sintoma:** ANPD solicita RIPD e o documento não reflete o fluxo atual de tratamento de dados
- **Causa raiz:** RIPD foi criado uma vez e nunca atualizado. Novos fluxos (QR code em eventos, integrações com ferramentas IA) foram adicionados sem atualizar o relatório
- **Solução:** Atualizar RIPD imediatamente. Mapear TODOS os fluxos de dados pessoais atuais
- **Prevenção:** Adicionar step no processo de mudança: "Esta mudança afeta dados pessoais? Se sim, atualizar RIPD"
- **Descoberto em:** 2026-03-18

---

## 3. Direito de exclusão executado no Sales Cloud não propaga para Marketing Cloud

- **Sintoma:** Titular solicita exclusão (Art. 18 LGPD), dados são deletados no Sales Cloud mas continuam no Marketing Cloud (emails continuam sendo enviados)
- **Causa raiz:** Exclusão no Sales Cloud não dispara exclusão automática no Marketing Cloud. São bases independentes
- **Solução:** Criar processo que ao marcar "Exclusão LGPD" no Sales Cloud, dispara automação para exclusão no MC via API
- **Prevenção:** Implementar Privacy Center ou processo manual documentado que cubra TODAS as bases de dados
- **Descoberto em:** 2026-03-18

---
