# Modelos BDD / Gherkin para Salesforce Febracis

Modelos de cenários de aceite estruturados para os principais fluxos de negócio da Febracis (Captação, Conversão, Matrículas e Comissionamento).

---

## 1. Modelo: Conversão e Distribuição de Leads

```gherkin
Feature: Distribuição Automática de Leads Febracis
  Como Consultor Comercial
  Quero receber leads qualificados de eventos
  Para que eu possa iniciar o contato de vendas em menos de 15 minutos

  Background:
    Given existem 3 consultores ativos na fila "Comercial - Formação em Coaching"
    And a regra de Round-Robin está ativa para a Unidade "São Paulo"

  Scenario: Lead quente de Landing Page com preenchimento completo
    Given um lead entra com:
      | Campo         | Valor                          |
      | Name          | João Silva                     |
      | Email         | joao.silva@exemplo.com.br      |
      | Phone         | +5511999998888                 |
      | LeadSource    | Evento Presencial              |
      | EventoID__c   | EVT-2026-SP                    |
    When o lead é inserido no Salesforce
    Then o status do lead deve ser "Novo"
    And o proprietário (OwnerId) deve ser atribuído via Round-Robin
    And uma tarefa "Primeiro Contato Comercial" deve ser criada com vencimento em 15 minutos

  Scenario: Tentativa de inserção de lead duplicado por CPF ou E-mail
    Given já existe um contato ativo com e-mail "joao.silva@exemplo.com.br"
    When um novo lead com o mesmo e-mail é inserido
    Then o sistema deve vincular o lead ao contato existente
    And registrar uma atividade no histórico sem criar um novo registro órfão
```

---

## 2. Modelo: Matrícula de Aluno e Bloqueio de Inadimplência

```gherkin
Feature: Validação de Matrícula de Aluno
  Como Operador Financeiro / Comercial
  Quero registrar a matrícula de um aluno em um curso
  Para liberar o acesso à plataforma e ao material didático

  Scenario: Matrícula com pagamento aprovado no gateway
    Given um aluno "Maria Santos" com status financeiro "Regular"
    And o curso "Método CIS" possui vagas disponíveis
    When uma nova "Matricula__c" é criada com status de pagamento "Aprovado"
    Then o registro de matrícula deve ser alterado para "Ativo"
    And o número de vagas restantes do curso deve ser decrementado em 1
    And um Platform Event "MatriculaConfirmada__e" deve ser disparado

  Scenario: Bloqueio de matrícula para aluno com pendência financeira grave
    Given um aluno "Carlos Oliveira" possui 2 parcelas em atraso há mais de 60 dias
    When o consultor tenta criar uma nova "Matricula__c" sem autorização da diretoria
    Then o sistema deve bloquear o salvamento com a mensagem "Aluno possui restrição financeira ativa"
```
