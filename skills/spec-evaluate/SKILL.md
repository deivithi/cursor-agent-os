---
name: spec-evaluate
description: >
  Gate obrigatorio pre-desenvolvimento: valida specs antes de enviar para execucao.
  Verifica 12 criterios de completude, identifica gaps e edge cases, faz perguntas
  estrategicas, gera score de completude (0-100, threshold 80). Nenhuma spec vai para
  implementacao sem passar por aqui. Inspirado no Breno/Lion Lab (spec validator),
  Addy Osmani (6 core areas + 3-tier boundaries) e GitHub Spec-Kit.
  Palavras-chave: validar spec, avaliar spec, spec completa, spec review, pre-dev,
  quality gate, edge cases, acceptance criteria, spec score.
domain: spec-driven-development
subdomain: validation
version: 1.0.0
author: deivithi
tags:
  - spec-driven
  - validation
  - quality-gate
  - acceptance-criteria
  - edge-cases
  - harness-engineering
---

# Spec Evaluate — Gate Pre-Desenvolvimento

> **"Se voce nao falou para o agente exatamente o que ele tem que fazer, ele vai fazer da cabeca dele."**
> — Breno, Lion Lab

> **"Most agent files fail because they're too vague."**
> — GitHub Analysis (2,500+ agent configurations)

## File Structure
- `SKILL.md` — Voce esta aqui. Protocolo completo.
- `gotchas.md` — Problemas conhecidos. Consulte quando algo falhar.

## Related Skills
- `spec-epic` — Gera os Epic Briefs que esta skill valida
- `spec-planner` — Gera planos que se beneficiam de specs validadas
- `spec-phases` — Decomposicao que depende de specs completas
- `spec-driven-core` — Orquestrador que roteia para ca antes de execucao
- `code-review` — Complementar: review pos-implementacao

---

## Insight Central

> **Spec incompleta = retrabalho garantido.**
> A IA desenvolve pensando no caminho feliz. Os caminhos alternativos sao o problema
> e sao os principais que precisam estar dentro da spec. Se nao esta escrito,
> o agente vai inventar — e na maioria das vezes vai errar.
>
> **3 horas planejando, 30 minutos codando** e melhor que 10 minutos planejando
> e 3 horas debugando.

---

## 1. Gatilhos de Ativacao

Ativar **automaticamente** quando:

- Uma spec (MD ou JSON) esta prestes a ser enviada para implementacao
- `spec-driven-core` roteia para Phases, Plan ou YOLO (evaluate e gate obrigatorio)
- Usuario pede para "validar", "avaliar", "revisar" uma spec antes de desenvolver
- Um Epic Brief (`spec-epic`) foi aprovado e vai para decomposicao

**Nao ativar** quando:
- Bug fix pontual (sem spec formal)
- Prototipo descartavel
- Spec ja passou por evaluate nesta sessao (sem mudancas)

---

## 2. Input

| Campo | Obrigatorio | Fonte |
|-------|-------------|-------|
| **Spec document** | Sim | Arquivo MD, JSON, ou inline |
| **Tipo de spec** | Sim | Epic Brief / Tech Spec / Sprint Spec |
| **Codebase access** | Nao | Para validar file hints e stack contra realidade |

---

## 3. Os 12 Criterios de Completude

Cada criterio recebe: **Sim** (2 pts), **Parcial** (1 pt), **Nao** (0 pts).
Score maximo: 24 pontos → normalizado para 0-100.

### Bloco A — Definicao (o que construir)

| # | Criterio | O que verificar |
|---|----------|----------------|
| **C1** | Acceptance Criteria por feature | Cada feature/sprint tem criterios verificaveis (sim/nao, nao subjetivos)? |
| **C2** | Edge cases e caminhos alternativos | Cenarios de erro, validacao, estados invalidos cobertos? Nao so happy path? |
| **C3** | API Spec com cenarios de erro | Endpoints, metodos, payloads, E respostas de erro (401, 404, 500) definidos? |
| **C4** | Data Models | Schemas, migracoes, relacoes definidos? Ou indicado "sem DB"? |

### Bloco B — Contexto tecnico (como construir)

| # | Criterio | O que verificar |
|---|----------|----------------|
| **C5** | Stack e dependencias com versoes | Frameworks, libs, versoes explicitas? (nao so "React", mas "React 18.3 + TypeScript 5.x") |
| **C6** | File hints | Quais arquivos serao criados/modificados? Paths confirmados via Glob? |
| **C7** | Arquitetura documentada | Diagrama Mermaid ou notas de arquitetura? Padroes do codebase respeitados? |
| **C8** | Boundaries 3-tier | Definido o que o agente Always faz, Ask First, e Never faz? |

### Bloco C — Execucao (como entregar)

| # | Criterio | O que verificar |
|---|----------|----------------|
| **C9** | Sprints/fases com complexidade | Trabalho dividido em sprints? Cada um com estimativa (Simples/Medio/Complexo)? |
| **C10** | Sequencia com dependencias | Ordem de execucao clara? Dependencias entre sprints explicitas? |
| **C11** | Agent ID por sprint | Qual agente/persona executa cada sprint? (ou "default" se unico) |
| **C12** | Criterios de aceite verificaveis | Criterios sao testavel por sensor (lint/test/build)? Ou precisam de validacao manual? |

---

## 4. Workflow — 4 Steps

### Step 1: Carregar e Classificar

1. Ler spec completa (MD ou JSON)
2. Classificar tipo: Epic Brief / Tech Spec / Sprint Spec
3. Identificar formato: Markdown estruturado / JSON / Texto livre

### Step 2: Avaliar 12 Criterios

Para cada criterio (C1-C12):

```markdown
| # | Criterio | Score | Evidencia | Gap |
|---|----------|-------|-----------|-----|
| C1 | Acceptance Criteria | Sim/Parcial/Nao | [onde na spec] | [o que falta] |
```

**Regras de avaliacao:**
- **Sim (2 pts):** Criterio plenamente atendido com evidencia na spec
- **Parcial (1 pt):** Presente mas incompleto (ex: acceptance criteria so para happy path)
- **Nao (0 pts):** Ausente ou impossivel de verificar

### Step 3: Perguntas Estrategicas

Para cada gap encontrado (score Parcial ou Nao), formular **1 pergunta especifica**:

- Nao perguntar coisas genericas ("quer adicionar edge cases?")
- Perguntar cenarios concretos ("Quando o usuario digita email invalido no login, qual mensagem deve aparecer?")
- Maximo **6 perguntas** por avaliacao (priorizar gaps mais criticos)
- Se nenhum gap: zero perguntas, spec aprovada direto

**Formato das perguntas:**
```
Pergunta [N] de [total] — [Criterio afetado]
[Pergunta concreta com opcoes quando possivel]
```

### Step 4: Gerar Relatorio + Score

```markdown
# Spec Evaluate Report

## Spec: [titulo]
## Data: [DD/MM/YYYY HH:MM BRT]
## Tipo: [Epic Brief / Tech Spec / Sprint Spec]

## Scorecard

| # | Criterio | Score | Detalhe |
|---|----------|-------|---------|
| C1 | Acceptance Criteria | Sim (2) | Todas features com AC verificaveis |
| C2 | Edge Cases | Parcial (1) | Login cobre erro, mas signup nao |
| ... | ... | ... | ... |

## Score Final: [X]/100

| Faixa | Significado |
|-------|-------------|
| 90-100 | Spec excelente — pronta para execucao |
| 80-89 | Spec boa — gaps menores, pode prosseguir |
| 60-79 | Spec incompleta — corrigir gaps antes de executar |
| < 60 | Spec insuficiente — retrabalho significativo necessario |

## Gaps Encontrados
[Lista de gaps com severidade]

## Perguntas (se houver)
[Perguntas formuladas no Step 3]

## Veredicto
- APROVADA (score >= 80, zero gaps criticos)
- APROVADA COM RESSALVAS (score >= 80, gaps menores aceitos)
- REPROVADA (score < 80 OU gaps criticos sem resposta)
```

---

## 5. Regras de Decisao

| Score | Acao |
|-------|------|
| **>= 90** | Aprovada. Prosseguir para execucao. |
| **80-89** | Aprovada com ressalvas. Listar gaps menores como notas para o builder. |
| **60-79** | Reprovada. Fazer perguntas, aguardar respostas, re-avaliar. |
| **< 60** | Reprovada. Spec precisa de retrabalho significativo. Sugerir voltar para spec-epic ou elicitacao. |

**Regra inviolavel:** Nenhuma spec com score < 80 avanca para implementacao.
**Excecao:** Usuario pode forcar bypass com "prosseguir mesmo assim" — registrar como "Gate bypassed — risco aceito pelo usuario".

---

## 6. Adaptacao por Tipo de Spec

| Tipo | Criterios obrigatorios | Criterios opcionais |
|------|----------------------|-------------------|
| **Epic Brief** | C1, C2, C8, C9, C10 | C3, C4, C5, C6 (detalhados no Tech Plan) |
| **Tech Spec** | Todos (C1-C12) | Nenhum |
| **Sprint Spec** | C1, C2, C3, C5, C6, C12 | C7, C8, C9, C10, C11 (ja definidos no epic) |

Criterios opcionais recebem **Sim** automaticamente se o tipo nao os exige.

---

## 7. Progressive Disclosure

| Complexidade da Spec | Comportamento |
|---------------------|---------------|
| **Pequena** (1-2 features, < 50 linhas) | Avaliacao inline, sem relatorio formal |
| **Media** (3-7 features, 50-300 linhas) | Relatorio completo com scorecard |
| **Grande** (8+ features, 300+ linhas) | Relatorio + sugerir divisao em sub-specs |

---

## 8. Handoff Points

| Quando | Repassar para | Condicao |
|--------|--------------|----------|
| Spec aprovada (>= 80) | `spec-phases` ou `spec-planner` | Prosseguir com execucao |
| Spec reprovada, gaps de negocio | `spec-epic` (Comando 1-2) | Voltar para elicitacao |
| Spec reprovada, gaps tecnicos | `spec-planner` (Step 2) | Analise de codebase necessaria |
| Spec precisa de pesquisa | `deep-research-workspace` | Dominio desconhecido |
| Bypass forcado pelo usuario | `spec-phases` | Registrar risco no ledger |

---

## 9. Integracao com Pipeline Harness

```
spec-epic (PRD + Brief)
    |
    v
>>> spec-evaluate <<< (VOCE ESTA AQUI)
    |
    |-- Score >= 80 --> spec-phases (Contracts + Execucao)
    |-- Score < 80  --> Perguntas --> Re-evaluate
    |-- Bypass      --> spec-phases (risco registrado)
```

Esta skill e o **primeiro gate de qualidade** do pipeline.
O segundo gate e `spec-verify` (pos-implementacao com sensores).

---

## 10. Gotchas

Consulte `gotchas.md` para problemas conhecidos. Principais:

1. **Spec em texto livre sem estrutura** → pedir para reformatar antes de avaliar
2. **Criterios subjetivos** ("codigo limpo", "boa UX") → rejeitar, pedir criterio mensuravel
3. **Score inflado por criterios opcionais** → adaptar por tipo de spec (secao 6)
4. **Perguntas genericas** → sempre formular com cenario concreto e opcoes
5. **Re-evaluate infinito** → max 2 rodadas de perguntas; na 3a, aprovar com ressalvas ou escalar
