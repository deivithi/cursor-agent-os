# Padrões Arquiteturais Salesforce — Febracis

Este guia estabelece os padrões técnicos que toda especificação Salesforce deve seguir para manter conformidade com boas práticas, governança e integridade no Gauntlet.

---

## 1. Padrão Trigger Handler (Apex)

Nunca colocar lógica de negócio diretamente dentro do corpo da Trigger. Usar o padrão **One Trigger Per Object** com Handler dedicado.

### Estrutura Canônica:

```apex
// LeadTrigger.trigger
trigger LeadTrigger on Lead (before insert, before update, after insert, after update) {
    LeadTriggerHandler.run();
}
```

```apex
// LeadTriggerHandler.cls
public with sharing class LeadTriggerHandler {
    public static void run() {
        if (Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert((List<Lead>) Trigger.new);
        } else if (Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert((List<Lead>) Trigger.new, (Map<Id, Lead>) Trigger.newMap);
        }
        // Demais contextos...
    }

    private static void handleBeforeInsert(List<Lead> newLeads) {
        LeadDomainService.enrichLeadSource(newLeads);
    }

    private static void handleAfterInsert(List<Lead> newLeads, Map<Id, Lead> newLeadMap) {
        LeadDomainService.distributeLeads(newLeads);
    }
}
```

---

## 2. Bulkification e Proteção de Governor Limits

- **Coleções Sempre:** Métodos de serviço devem aceitar `List<SObject>` ou `Set<Id>`, nunca instâncias isoladas.
- **SOQL / DML fora de Loops:**
  ```apex
  // CORRETO
  List<Account> accountsToUpdate = new List<Account>();
  for (Contact c : contacts) {
      if (c.AccountId != null) {
          accountsToUpdate.add(new Account(Id = c.AccountId, LastActivityDate__c = System.today()));
      }
  }
  if (!accountsToUpdate.isEmpty()) {
      update accountsToUpdate;
  }
  ```

---

## 3. Segurança: FLS & Sharing

- Toda classe que acessa dados de usuário final deve declarar `with sharing` ou `inherited sharing`.
- Para mutações DML sensíveis, verificar `Schema.sObjectType.MyObject__c.isCreateable()` ou usar `stripInaccessible()`.

```apex
SObjectAccessDecision decision = Security.stripInaccessible(
    AccessType.CREATABLE,
    recordsToInsert
);
insert decision.getRecords();
```

---

## 4. Estratégia de Testes (`@isTest`)

- Usar `TestDataFactory` centralizado para geração de dados válidos.
- Sempre envolver chamadas assíncronas/regras complexas entre `Test.startTest()` e `Test.stopTest()`.
- Validar comportamento com no mínimo 200 registros (`bulk test`).
- Testar tanto casos positivos (comportamento esperado) quanto negativos (erros de validação e exceções esperadas).
