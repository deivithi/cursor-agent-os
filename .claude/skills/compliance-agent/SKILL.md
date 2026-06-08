---
name: compliance-agent
description: >
  Agentes conversacionais com guidelines comportamentais determinísticas (Parlant pattern).
  Regras de negócio como behavioral policies, state-based journeys, compliance enforcement.
  Keywords: compliance, guidelines, behavioral rules, parlant, state machine, onboarding, loan, audit.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, Agent
metadata:
  author: deivithi
  version: "1.0"
  source: "patchy631/ai-engineering-hub (parlant-conversational-agent, guidelines-vs-traditional-prompt)"
---

# Compliance Agent — Guidelines Determinísticas para Agentes

Padrão para construir agentes conversacionais onde regras de negócio são **behavioral policies separadas do prompt**, verificáveis e determinísticas. Em vez de um prompt monolítico esperando que o LLM "se comporte bem", as regras são estruturadas como guidelines que o agente DEVE seguir — com state machine, boundary maintenance e conflito entre regras resolvido por prioridade.

## Quando Usar

- Processos com regras de compliance obrigatórias (financeiro, jurídico, RH, vendas)
- Agentes que conduzem usuário por jornada estruturada (onboarding, qualificação, auditoria)
- Cenários onde o agente NÃO pode improvisar — respostas devem seguir regras determinísticas
- Chatbots Febracis: atendimento, qualificação de leads, processos de vendas Salesforce

## Quando NÃO Usar (→ Handoff)

- Agente de pesquisa livre sem regras rígidas → usar `deep-research-workspace`
- Validação de input/output genérica → usar `guardrails`
- Agent builder genérico → usar `agent-builder`

## Conceito: Guidelines vs Prompts Tradicionais

| Aspecto | Prompt Tradicional | Guidelines (Parlant) |
|---------|-------------------|----------------------|
| Estrutura | Monolítico, tudo junto | Separado: prompt base + guidelines individuais |
| Verificabilidade | Difícil — embedded no prompt | Cada guideline é testável isoladamente |
| Conflito | LLM decide sozinho | Prioridade explícita entre guidelines |
| Manutenção | Editar prompt gigante | Adicionar/remover guidelines individualmente |
| Boundary | Implícito | Explícito — guideline define o que está fora do escopo |
| Auditoria | Impossível | Cada resposta rastreável à guideline que a gerou |

## Workflow

### Fase 1 — Definir Guidelines como Policies

```yaml
# Cada guideline é uma regra isolada com:
guidelines:
  - id: GL-001
    name: "Aviso de substituição de apólice"
    condition: "Quando cliente menciona trocar apólice existente"
    action: "SEMPRE avisar sobre período de carência e riscos"
    priority: CRITICAL  # CRITICAL > HIGH > MEDIUM > LOW
    
  - id: GL-002
    name: "Cálculo de cobertura"
    condition: "Quando cliente pede valor de cobertura"
    action: "Solicitar: idade, renda, dependentes, dívidas. Calcular com fórmula padrão"
    priority: HIGH
    
  - id: GL-003
    name: "Boundary: fora do escopo"
    condition: "Quando pergunta não é sobre o produto/serviço"
    action: "Redirecionar educadamente. NÃO responder sobre outros temas"
    priority: MEDIUM
```

### Fase 2 — Definir State Machine da Jornada

```
┌──────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────┐
│  INÍCIO  │───→│ QUALIFICAÇÃO │───→│  DOCUMENTOS  │───→│ APROVAÇÃO│
└──────────┘    └──────────────┘    └──────────────┘    └──────────┘
     │                │                    │                   │
     │           pode voltar          pode voltar              │
     │                │                    │                   │
     └────────────────┴────────────────────┴───────────────────┘
                    (qualquer estado → CANCELAMENTO)

Estados:
    INÍCIO → Saudação + identificação do cliente
    QUALIFICAÇÃO → Perguntas de elegibilidade (guidelines GL-001 a GL-005)
    DOCUMENTOS → Coleta de documentos necessários
    APROVAÇÃO → Decisão + próximos passos
    CANCELAMENTO → Registro do motivo + despedida
    
Transições:
    - Só avança quando TODOS os requisitos do estado atual estão preenchidos
    - Pode voltar a estados anteriores para corrigir informação
    - Timeout: se inativo por X minutos → lembrete → CANCELAMENTO
```

### Fase 3 — Implementar Compliance Enforcement

```
Para cada resposta do agente:
    1. Identificar estado atual na jornada
    2. Selecionar guidelines aplicáveis ao estado + ao input do usuário
    3. Se guidelines conflitam → usar prioridade (CRITICAL > HIGH > MEDIUM > LOW)
    4. Gerar resposta seguindo guidelines selecionadas
    5. Verificar: resposta viola alguma guideline? Se sim → regenerar
    
Log de auditoria:
    {
        "timestamp": "2026-04-14T12:00:00-03:00",
        "state": "QUALIFICAÇÃO",
        "user_input": "quero trocar meu plano",
        "guidelines_triggered": ["GL-001", "GL-003"],
        "response": "...",
        "compliance_check": "PASS"
    }
```

### Fase 4 — Testes de Compliance (5 Cenários Padrão)

| Cenário | O Que Testa | Expectativa |
|---------|------------|-------------|
| **Policy replacement** | Guidelines de aviso crítico | Agente DEVE avisar riscos antes de prosseguir |
| **Cálculo com parâmetros** | Lógica determinística | Resultado consistente com mesmos inputs |
| **Condição especial** | Guidelines de exceção | Agente trata caso edge corretamente |
| **Mixed topics** | Boundary maintenance | Agente redireciona sem responder fora do escopo |
| **Regras conflitantes** | Prioridade entre guidelines | Guideline de maior prioridade prevalece |

## Progressive Disclosure

| Complexidade | Comportamento |
|-------------|---------------|
| **Simples** | Definir 3-5 guidelines + resposta com compliance check básico |
| **Médio** | State machine completa + guidelines priorizadas + 5 cenários de teste |
| **Complexo** | + Log de auditoria + conflito entre guidelines + boundary testing + rollback de estado |

## Adaptação para Febracis

| Processo Febracis | Como Aplicar |
|-------------------|-------------|
| Qualificação de leads | State machine: Contato → Qualificação → Agendamento → Follow-up |
| Onboarding de evento | Guidelines de documentação + regras do Método CIS |
| Auditoria de comissões | Guidelines de cálculo + verificação contra regras do programa |
| Atendimento Salesforce | Boundary: só responder sobre produtos/serviços Febracis |

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Validação de input/output | `guardrails` | Proteção genérica |
| Auditoria de leads | `lead-audit` | Processo específico Febracis |
| Auditoria de comissões | `commission-audit` | Processo específico Febracis |
| Construir o agente | `agent-builder` | Implementação técnica |

## Gotchas

1. **Guidelines demais = prompt gigante de novo** → Max 15-20 guidelines por agente. Se precisa de mais, decompor em sub-agentes por estado
2. **Prioridade ambígua** → Definir prioridade ANTES de implementar. Conflito sem prioridade = LLM decide sozinho (derrota o propósito)
3. **State machine rígida demais** → Permitir voltar a estados anteriores. Usuários não seguem fluxo linear
4. **Boundary muito agressivo** → "Isso não é meu escopo" repetido frustra. Redirecionar com empatia

## Referências

- `patchy631/ai-engineering-hub/parlant-conversational-agent` — Loan approval com Parlant framework
- `patchy631/ai-engineering-hub/guidelines-vs-traditional-prompt` — Comparação guidelines vs prompt monolítico (5 cenários)
- [Parlant](https://github.com/emcie-co/parlant) — Framework de agentes compliance-driven
- Conceito: Guidelines separadas > Prompt monolítico — testabilidade e auditabilidade
