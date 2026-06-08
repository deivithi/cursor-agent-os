---
name: spec-epic
description: >
  Pipeline completo de intent a código: captura intenção → gera Epic Brief (PRD) →
  mapeia Core Flows → cria Tech Plan → decompõe em Tickets → executa via spec-phases.
  Elicitação ativa de requisitos. Inspirado no Traycer.ai Epic Mode.
domain: spec-driven-development
subdomain: epic-orchestration
version: 1.0.0
author: deivithi
tags:
  - spec-driven
  - epic
  - prd
  - tech-plan
  - tickets
  - orchestration
  - traycer
---

# 🏗️ Spec Epic — Pipeline Intent → Código

> **"Epic Mode captures the why, constraints, edge cases, and unspoken rules that typically live in scattered messages or incomplete plans."**
> — Inspirado no Traycer.ai Epic Mode

## 📁 File Structure

- `SKILL.md` — Você está aqui. Protocolo completo.
- `gotchas.md` — Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills

- `spec-enrich` — Enriquece spec com edge cases, contradições e gaps (pós-evaluate)
- `spec-planner` — Gera planos file-level (usado nos tickets)
- `spec-phases` — Executa tickets como fases verificáveis
- `spec-evaluate` — Gate obrigatório pré-desenvolvimento (score >= 80)
- `spec-verify` — Verificação em cada etapa
- `spec-yolo` — Automação completa do epic
- `mermaid-diagrams` — Diagramas em todos os artefatos
- `deep-research-workspace` — Pesquisa profunda quando contexto é insuficiente

---

## 🧠 Insight Central

> **Mini-specs > Monolitos.**
> Um PRD de 50 páginas fica desatualizado antes de ser lido.
> O Epic Mode produz **artefatos pequenos, scoped e revisáveis**: brief, flows, tech plan, tickets.
> Cada artefato responde UMA pergunta e permanece estável.

---

## 1. Workflow — 5 Comandos Sequenciais

O Epic segue um pipeline de 5 artefatos, cada um alimentando o próximo:

```mermaid
flowchart LR
    A[🎯 Discovery] --> B[📋 Epic Brief]
    B --> C[🔄 Core Flows]
    C --> D[🏗️ Tech Decisions]
    D --> D2[📄 PRD Consolidado]
    D2 --> E[🎫 Tickets]
    E --> F[⚙️ Execução]
```

---

### Comando 1: 🎯 Discovery Estruturado — Captura de Intenção

> **"Tudo que você deixa pro agente inventar da cabeça dele dá errado."** — Breno, LionLab

**Input:** Descrição livre do usuário (1 frase a 1 parágrafo).

**Processo — 5 Blocos Temáticos (sequenciais, 1 bloco por vez):**

Cada bloco contém 1-2 perguntas. Só avançar para o próximo bloco quando o anterior estiver respondido.

#### Bloco 1: Visão

- Qual problema específico esta ferramenta resolve?
- Quem são os usuários-alvo? (personas concretas, não genéricas)

#### Bloco 2: Funcionalidades

- O que o usuário pode fazer na ferramenta? (listar features core)
- O que está FORA do escopo? (escopo negativo explícito)

#### Bloco 3: Monetização

- Qual o modelo de receita? (assinatura, freemium, one-time, marketplace)
- Integrações de pagamento? (Stripe, Mercado Pago, etc.)

#### Bloco 4: Técnico

- Stack preferida? (framework, linguagem, banco de dados)
- Plataforma? (web, mobile, desktop, API)
- Integrações externas? (APIs de terceiros, serviços)

#### Bloco 5: Contexto

- Referências visuais? (prints, links, produtos similares)
- Restrições? (prazo, compliance, compatibilidade, budget)
- Como o sucesso será medido? (métricas concretas)

**Output:** Intenção clarificada com todas as respostas organizadas por bloco.

**Regra:** Múltiplas rodadas por bloco são normais. Não prossiga com ambiguidade. Se o usuário não souber responder um bloco (ex: monetização), registrar como "A definir" e seguir — não bloquear o pipeline.

---

### Comando 2: 📋 Epic Brief — PRD Resumido

**Input:** Intenção clarificada do Comando 1.

**Gerar artefato:**

```markdown
# 📋 Epic Brief: [Título]

## Problema

[Qual problema estamos resolvendo e para quem]

## Objetivo

[O que o sistema faz quando estiver pronto — em termos de comportamento observável]

## Personas / Usuários

| Persona | Necessidade     | Prioridade       |
| ------- | --------------- | ---------------- |
| [quem]  | [o que precisa] | Alta/Média/Baixa |

## Escopo

### ✅ Dentro

- [funcionalidade 1]
- [funcionalidade 2]

### ❌ Fora

- [o que NÃO será feito]
- [o que fica para futuro]

## Critérios de Sucesso

- [ ] [Critério mensurável 1]
- [ ] [Critério mensurável 2]

## Restrições

- [Técnicas: linguagem, framework, compatibilidade]
- [Negócio: prazo, compliance, dependências]
- [UX: padrões existentes, acessibilidade]

## Riscos

| Risco | Probabilidade    | Impacto          | Mitigação |
| ----- | ---------------- | ---------------- | --------- |
| ...   | Alta/Média/Baixa | Alto/Médio/Baixo | ...       |

## Boundaries (3-Tier)

> Derivado do Addy Osmani / GitHub analysis de 2500+ agent configurations.
> Define o que o agente pode e nao pode fazer durante a implementacao.

### Always Do (sem perguntar)

- [ex: Rodar testes antes de commitar]
- [ex: Seguir naming conventions do projeto]

### Ask First (requer aprovacao humana)

- [ex: Modificar schema do banco]
- [ex: Adicionar nova dependencia]

### Never Do (proibicoes absolutas)

- [ex: Commitar secrets ou API keys]
- [ex: Remover testes sem aprovacao]
```

---

### Comando 3: 🔄 Core Flows — Mapeamento de Fluxos

**Input:** Epic Brief do Comando 2.

**Gerar artefato:**

```markdown
# 🔄 Core Flows: [Título do Epic]

## Fluxo Principal (Happy Path)

[Diagrama Mermaid — sequenceDiagram ou flowchart]

**Steps:**

1. Usuário [ação]
2. Sistema [resposta]
3. ...

## Fluxos Alternativos

### [Nome do fluxo alternativo]

[Diagrama Mermaid]
**Trigger:** [Quando este fluxo é ativado]
**Steps:** ...

## Edge Cases

| #   | Cenário     | Comportamento Esperado | Prioridade        |
| --- | ----------- | ---------------------- | ----------------- |
| 1   | [edge case] | [o que acontece]       | Must/Should/Could |

## Integrações

| Sistema           | Direção | Dados     | Protocolo            |
| ----------------- | ------- | --------- | -------------------- |
| [sistema externo] | →/←     | [payload] | REST/GraphQL/Webhook |
```

---

### Comando 4: 🏗️ Tech Decisions — Decisões Técnicas Conversacionais

> **Inspirado no LionLab:** 4 sub-etapas conversacionais. A cada aprovação, o resultado é inserido no Tech Plan. O usuário decide — o agente não inventa.

**Input:** Epic Brief + Core Flows + Discovery (Comando 1).

**Processo — 4 Sub-etapas (conversa dedicada por bloco):**

Cada sub-etapa: apresentar opções → perguntas → decisão do usuário → aprovação → inserir no Tech Plan.

#### 4a. Database

- Modelo de dados (tabelas, relações, constraints)
- Migrations e schema
- Banco escolhido + justificativa
- [Diagrama Mermaid — erDiagram]

#### 4b. Backend

- Arquitetura (monolito, microserviços, serverless, edge functions)
- Framework + linguagem + versão
- APIs e endpoints principais
- Autenticação (método, provider)

#### 4c. Frontend

- Framework + versão
- Componentes UI (library, design system)
- UX patterns e cores
- Responsividade e plataformas

#### 4d. Segurança

- Auth/AuthZ (RLS, JWT, sessions)
- CORS e headers
- Secrets management
- Compliance (LGPD, etc.)

**Output — Tech Plan consolidado:**

```markdown
# 🏗️ Tech Plan: [Título do Epic]

## Diagrama de Arquitetura

[Diagrama Mermaid — graph ou C4]

## Stack & Dependências

| Camada   | Tecnologia  | Versão | Justificativa |
| -------- | ----------- | ------ | ------------- |
| Frontend | [framework] | [ver]  | [por quê]     |
| Backend  | [framework] | [ver]  | [por quê]     |
| Database | [DB]        | [ver]  | [por quê]     |

## Modelo de Dados

[Diagrama Mermaid — erDiagram gerado na sub-etapa 4a]

## APIs / Interfaces

| Endpoint/Interface | Método       | Input     | Output     |
| ------------------ | ------------ | --------- | ---------- |
| [path]             | GET/POST/... | [payload] | [response] |

## Componentes a Criar/Modificar

| Componente          | Ação            | Responsabilidade |
| ------------------- | --------------- | ---------------- |
| [path/to/component] | Criar/Modificar | [o que faz]      |

## Decisões Técnicas

| Decisão   | Alternativas         | Justificativa |
| --------- | -------------------- | ------------- |
| [escolha] | [opções descartadas] | [por quê]     |

## Segurança

| Aspecto | Decisão    | Implementação |
| ------- | ---------- | ------------- |
| Auth    | [método]   | [como]        |
| CORS    | [política] | [config]      |
| Secrets | [gestão]   | [onde]        |

## Impacto em Sistemas Existentes

| Sistema   | Impacto          | Ação Necessária |
| --------- | ---------------- | --------------- |
| [sistema] | [como é afetado] | [o que fazer]   |
```

**Regra:** Cada sub-etapa requer aprovação explícita antes de avançar. Se o usuário não souber decidir, apresentar recomendação com justificativa e pedir confirmação.

---

### Comando 4.5: 📄 PRD Consolidado

> Gera documento PRD completo unificando todos os artefatos anteriores.

**Input:** Discovery (Cmd 1) + Epic Brief (Cmd 2) + Core Flows (Cmd 3) + Tech Plan (Cmd 4).

**Gerar artefato:**

```markdown
# 📄 PRD: [Título do Produto]

## Resumo Executivo

[2-3 parágrafos: problema, solução, valor]

## Personas

| Persona | Necessidade     | Prioridade       |
| ------- | --------------- | ---------------- |
| [quem]  | [o que precisa] | Alta/Média/Baixa |

## User Stories

[Consolidado do Cmd 2 — todos os user stories com acceptance criteria]

## Requisitos Funcionais

[Consolidado do Cmd 2 — agrupados por feature/módulo]

## Requisitos Não-Funcionais

[Performance, segurança, escalabilidade, acessibilidade]

## Arquitetura Técnica

[Resumo do Tech Plan — Cmd 4]

## Modelo de Dados

[erDiagram do Cmd 4a]

## Métricas de Sucesso

[Do Discovery — Bloco 5]

## Escopo Negativo

[Do Discovery — Bloco 2]

## Dependências e Riscos

| Risco | Probabilidade | Impacto | Mitigação |
| ----- | ------------- | ------- | --------- |
| ...   | ...           | ...     | ...       |
```

**Regra:** Este documento é o input para `spec-planner` (Spec Generation) e `spec-enrich` (Spec Enricher). Não avançar sem PRD consolidado aprovado.

---

### Comando 5: 🎫 Ticket Breakdown — Decomposição em Tickets

**Input:** Todos os artefatos anteriores.

**Gerar artefato:**

```markdown
# 🎫 Tickets: [Título do Epic]

## Visão Geral

[Diagrama Mermaid — gantt ou graph mostrando dependências]

## Ticket 1: [Título curto e actionable]

- **Tipo:** Feature / Bugfix / Refactor / Infra
- **Prioridade:** P0 / P1 / P2
- **Intenção (porquê):** [1 linha — por que existe, impacto no usuário. Sem isto, a IA interpreta mal — Akita/Galego]
- **Arquivos:** [lista de arquivos]
- **Boundaries (fronteiras):**
  - **Input:** [o que entra — tipos, formato, origem]
  - **Output:** [o que sai — tipos, formato, destino]
  - **Contrato/Erros:** [casos de erro, validações, invariantes]
  - **Migração de dados:** [quem faz? este ticket ou outro? Nenhuma]
- **Dependências:** Nenhuma / Ticket N
- **Acceptance Criteria:**
  - [ ] [Critério verificável]
  - [ ] [Critério verificável]
- **Tamanho-alvo:** ~300 linhas (máx 500). Estourou? → quebrar em sub-tickets
- **Estimativa:** Simples / Médio / Complexo

## Ticket 2: [Título]

...

## Ordem de Execução

1. Ticket [X] — fundação
2. Ticket [Y] — core logic (depende de X)
3. Ticket [Z] — integração (depende de X, Y)
4. ...
```

**Regras de tickets:**

- Cada ticket = **1 PR** (idealmente), tamanho-alvo ~300 linhas (máx 500)
- **Boundaries explícitas** (input/output/contrato/migração) — fronteira ambígua = retrabalho garantido (Akita/Galego)
- Para tickets de **API**: gerar/atualizar **OpenAPI spec** via skill `api-forge` e anexar como contexto da implementação
- Acceptance criteria verificáveis (sim/não)
- Dependências explícitas
- Max 10 tickets por epic — se mais, dividir em sub-epics

---

## 2. Execução — Handoff para spec-phases

Após aprovação dos tickets:

1. Converter tickets em fases (1 ticket = 1 fase)
2. Usar `spec-phases` para executar sequencialmente
3. Cada fase usa `spec-planner` para plano detalhado
4. Verificação via `spec-verify` entre fases
5. Ou usar `spec-yolo` para automação completa

---

## 3. Artefatos — Regras Gerais

| Regra             | Descrição                                                     |
| ----------------- | ------------------------------------------------------------- |
| **Revisáveis**    | Cada artefato apresentado para aprovação antes de prosseguir  |
| **Incrementais**  | Cada artefato constrói sobre o anterior                       |
| **Independentes** | Cada artefato responde UMA pergunta                           |
| **Diagramados**   | Mermaid em todos os artefatos que envolvem fluxo ou estrutura |
| **Versionados**   | Se artefato muda, registrar o que mudou e por quê             |

---

## 4. Agent Modes

| Mode         | Quando Usar                            | Comportamento                                       |
| ------------ | -------------------------------------- | --------------------------------------------------- |
| **Planner**  | Comandos 1-4 (gerar artefatos)         | Reasoning estendido, exploração profunda, perguntas |
| **Reviewer** | Comando 5 (decomposição) + verificação | Validação detalhada, edge cases, completude         |

---

## 5. Progressive Disclosure

| Complexidade do Epic      | Comportamento                            |
| ------------------------- | ---------------------------------------- |
| **Pequeno** (1-3 tickets) | Skip Core Flows, Tech Plan simplificado  |
| **Médio** (4-7 tickets)   | Pipeline completo, todos os artefatos    |
| **Grande** (8-10 tickets) | Pipeline completo + sugerir sub-epics    |
| **Massivo** (10+ tickets) | Dividir em 2-3 epics antes de prosseguir |

---

## 6. Gotchas

⚠️ Consulte `gotchas.md` para problemas conhecidos. Principais:

1. **Pular elicitação** → epic mal definido, retrabalho garantido
2. **Artefatos monolíticos** → PRD de 50 linhas sem estrutura é inútil
3. **Tickets sem acceptance criteria** → impossível verificar conclusão
4. **Ignorar "Fora do Escopo"** → scope creep permanente
5. **Tech Plan sem verificação de fatos** → propor stack que não existe no projeto
