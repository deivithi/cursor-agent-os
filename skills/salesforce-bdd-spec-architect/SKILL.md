---
name: salesforce-bdd-spec-architect
description: Transforma histórias de usuário e requisitos de produto Febracis em especificações de arquitetura Salesforce (Objetos, Campos, Flows, Apex, LWC, FLS) com cenários Gherkin/BDD rigorosos e esqueletos de testes automatizados @isTest. Use quando desenhar novas funcionalidades, refatorar processos em Sales/Service/Experience Cloud ou planejar entregas para o Gauntlet.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, Agent
metadata:
  author: deivithi
  version: "1.0.0"
---

# Salesforce BDD Spec Architect

Especialista em transformar requisitos de negócio e histórias de produto Febracis (Vendas, Educação, Franquias, Eventos) em **especificações técnicas de arquitetura Salesforce** completas, acompanhadas de critérios de aceite em **Gherkin / BDD** executáveis e matriz de testes unitários (`@isTest`).

---

## 🎯 Quando Usar

- Ao criar ou refatorar funcionalidades nas nuvens Salesforce (**Sales Cloud, Service Cloud, Marketing Cloud, Experience Cloud**).
- Ao definir novos **Custom Objects**, **Custom Fields**, **Validation Rules**, **Record Types** e regras de compartilhamento (**FLS & Sharing Rules**).
- Ao planejar arquiteturas com **Flows (Record-Triggered, Screen, Autolaunched)** vs **Apex Triggers (Trigger Handlers)**.
- Ao gerar matrizes de testes automatizados e cenários BDD antes da fase de desenvolvimento (Spec-First / Gauntlet Protocol).
- Ao auditar o impacto de novos requisitos sobre processos existentes (Leads, Oportunidades, Matrículas, Contratos, Comissões).

## 🚫 Quando NÃO Usar (→ Handoff)

| Cenário | Skill recomendada |
|---|---|
| Auditoria pura de conversão de Leads Febracis | `lead-audit` |
| Auditoria e cálculo de comissões de vendas | `commission-audit` |
| Especificações genéricas de software sem stack Salesforce | `spec-driven-core` / `spec-planner` |
| Verificação de código Apex/LWC já escrito | `code-review` / `security-audit` |

---

## 📐 Estrutura Obrigatória de um Spec Salesforce

Todo documento de especificação gerado deve conter:

```markdown
# [SF-SPEC-XXX] Nome da Funcionalidade

## 1. Contexto de Negócio & Objetivos
- Unidade de Negócio (ex: Febracis Matriz, Unidades Próprias, Franquias)
- Persona / Papel (ex: Consultor Comercial, Coordenador Pedagógico, Aluno)
- Problema Resolvido & KPI de Sucesso

## 2. Modelo de Dados & Segurança (Schema & Security)
- Objetos envolvidos (Standard: Lead, Account, Contact, Opportunity / Custom: Matricula__c, Evento__c, etc.)
- Novos campos (API Name, Type, Length, Required, FLS por Profile/Permission Set)
- Regras de Compartilhamento (OWD, Sharing Rules, Role Hierarchy)

## 3. Lógica de Automação & Arquitetura Técnica
- Trigger / Flow Strategy (Before Save vs After Save)
- Bulkification & Governor Limits Protection
- Integrações / Eventos de Plataforma (Platform Events / CDC)

## 4. Cenários BDD / Gherkin (Critérios de Aceite)
Feature: Nome da Funcionalidade
  Scenario: Caminho Feliz
    Given ...
    When ...
    Then ...

  Scenario: Validação de Regra Negativa / Erro de Negócio
    Given ...
    When ...
    Then ...

## 5. Matriz de Testes Apex / Gauntlet Check
- Classes de Teste requeridas (@isTest, seeAllData=false)
- Casos de Teste (Bulk 200+ registros, Usuários com diferentes Perfis, Casos de Borda)
- Critério de Aprovação: 100% de asserções positivas/negativas + cobertura >= 85%
```

---

## 🔄 Workflow Operacional

1. **Ingestão do Requisito:**
   - Analisar a necessidade de negócio, identificar os objetos impactados e levantar restrições de governança e segurança.
2. **Desenho de Dados & Segurança:**
   - Definir se a solução exige novos campos/objetos ou reaproveitamento de entidades padrão.
   - Definir permissões granulares via Permission Sets (evitar perfis customizados monolíticos).
3. **Mapeamento de Automações:**
   - Seguir a regra: *Flow-First para lógicas declarativas simples; Apex Trigger Handler Pattern para lógicas complexas, volumetria alta ou integrações críticas*.
4. **Redação dos Cenários BDD:**
   - Escrever critérios de aceite inequívocos no formato Gherkin (`Feature`, `Scenario`, `Given`, `When`, `Then`, `And`).
5. **Geração do Esqueleto de Testes:**
   - Criar a assinatura da classe `@isTest` com os métodos de teste mapeados 1:1 para cada cenário BDD.
6. **Validação Automática do Spec:**
   - Executar o validador:
     ```powershell
     python skills/salesforce-bdd-spec-architect/scripts/validate-salesforce-spec.py --spec caminho/para/spec.md
     ```

---

## ⚠️ Gotchas & Regras Críticas

1. **Bulkification Universal:** Toda especificação Apex/Flow DEVE suportar 200 registros simultâneos em lote (Governor Limits SOQL/DML).
2. **Isolamento de Testes:** Sempre usar `seeAllData=false` e criar dados de teste via Test Data Factory (`TestDataFactory.cls`).
3. **Princípio do Menor Privilégio:** Especificar FLS para campos sensíveis (dados financeiros, LGPD, CPF/dados pessoais).
4. **No SOQL/DML in Loops:** Explicitar que qualquer query ou mutação deve ser feita em coleções (`List`, `Map`, `Set`).

---

## 📚 Referências

- [`references/salesforce-patterns.md`](references/salesforce-patterns.md) — Padrões arquiteturais Apex, LWC, Trigger Handlers e FLS.
- [`references/gherkin-salesforce-templates.md`](references/gherkin-salesforce-templates.md) — Modelos prontos de Gherkin para vendas, matrículas e comissões.
