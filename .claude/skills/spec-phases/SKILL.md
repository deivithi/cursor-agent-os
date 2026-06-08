---
name: spec-phases
description: >
  Decompõe objetivos complexos em fases verificáveis com contexto herdado.
  Cada fase usa spec-planner para gerar plano, executa via subagente, verifica
  via spec-verify, e passa contexto para a próxima. Inspirado no Traycer.ai Phases Mode.
domain: spec-driven-development
subdomain: decomposition
version: 1.0.0
author: deivithi
tags:
  - spec-driven
  - phases
  - decomposition
  - milestones
  - iterative
  - traycer
---

# 🔄 Spec Phases — Decomposição em Fases Verificáveis

> **"Break work into manageable, logical chunks with milestones. Each phase starts with the most relevant context and minimal noise."**
> — Inspirado no Traycer.ai Phases Mode

## 📁 File Structure
- `SKILL.md` — Você está aqui. Protocolo completo.
- `gotchas.md` — Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `spec-enrich` — Enriquece spec antes de decompor em sprints
- `spec-evaluate` — Usado no Step 3.5 para validar sprints (tipo Sprint Spec)
- `spec-planner` — Gera plano detalhado por fase
- `spec-verify` — Verifica cada fase contra seu plano
- `spec-epic` — Usa spec-phases para executar tickets
- `spec-yolo` — Automação completa do ciclo de fases
- `alpha-loop` — Loop iterativo dentro de cada fase
- `agent-harness` — Progress tracking para sessões longas

---

## 🧠 Insight Central

> **Fases ≠ Steps.**
> Steps são instruções sequenciais dentro de um plano.
> Fases são **unidades de entrega independentes** — cada uma produz valor verificável.
> Se uma fase não pode ser verificada isoladamente, ela não é uma fase.

---

## 1. Workflow Completo — 7 Steps

### Step 1: 📥 Captura de Objetivo

Coletar objetivo de alto nível:

```markdown
## Objetivo
[O que precisa ser alcançado — feature completa, migração, refactoring]

## Resultado Final Esperado
[Como o sistema se comporta quando TUDO estiver pronto]

## Restrições
[Compatibilidade, prazo, dependências externas, budget de mudanças]
```

### Step 2: 🎯 Elicitação de Requisitos

**Fazer 3-5 perguntas estratégicas** para resolver ambiguidade ANTES de decompor:

Perguntas-tipo:
- Qual é a prioridade: velocidade de entrega ou cobertura completa?
- Existem partes que podem ser entregues incrementalmente?
- Há dependências externas que bloqueiam alguma parte?
- Qual o nível de backward-compatibility necessário?
- Existem edge cases que devem ser cobertos desde a fase 1?

**Regra:** Não decompor antes de ter clareza. Perguntas evitam retrabalho.

### Step 3: 📊 Decomposição em Fases

Gerar fases seguindo este template:

```markdown
# 📊 Decomposição em Fases

## Visão Geral
[Diagrama Mermaid mostrando sequência de fases e dependências]

## Fase 1: [Nome descritivo]
- **Objetivo:** O que esta fase entrega
- **Entregáveis:** Arquivos/funcionalidades concretas
- **Dependências:** O que precisa estar pronto antes
- **Milestone:** Como saber que está completo
- **Estimativa de complexidade:** Simples / Médio / Complexo

## Fase 2: [Nome descritivo]
...

## Fase N: [Nome descritivo]
...

## Sequência de Execução
[Diagrama Mermaid com dependências entre fases]
```

**Regras de decomposição:**
- Cada fase deve ter **1 milestone claro e verificável**
- Fases devem ser **o mais independentes possível**
- Ordem lógica: fundações primeiro, features depois, polish por último
- **Max 7 fases** — se precisar de mais, agrupar em épicos

### Step 3.5: 🛡️ Sprint Validation Gate

> **"Você tem sempre que colocar um validador com contexto limpo do lado para poder validar o trabalho do cara anterior."** — Breno, LionLab

Após decomposição (Step 3), validar sprints contra a spec antes de planejar cada fase.

**Como funciona:** Invocar `spec-evaluate` com tipo **"Sprint Spec"** (já suportado na seção 6 de spec-evaluate).

**Input:**
- Sprints geradas no Step 3
- Spec enriched (output de `spec-enrich`) como referência

**Critérios de validação (Sprint Spec):**

| Critério | O que verifica |
|----------|---------------|
| **Cobertura** | Tudo que está na spec está coberto por algum sprint? |
| **Dependências** | Ordem respeita dependências técnicas? |
| **Sizing** | Complexidade equilibrada entre sprints? (sem sprint monstro) |
| **Acceptance criteria** | Cada sprint tem critérios verificáveis (sim/não)? |
| **Completude** | Nenhum módulo/feature da spec ficou órfão? |

**Gate:** Score >= 80 para prosseguir. Se < 80, ajustar sprints e re-validar (max 2 rodadas).

**Diferença de Step 3.5 vs Step 4.5 (Sprint Contract):**
- **Step 3.5** = "As sprints cobrem tudo que a spec pede?" → validação de **completude**
- **Step 4.5** = "O que exatamente o builder vai entregar nesta sprint?" → **contrato de execução**

---

### Step 4: 📋 Planejamento por Fase

Para cada fase, usar `spec-planner`:
1. Gerar plano file-level detalhado
2. Incluir acceptance criteria específicos
3. Incluir diagrama se necessário
4. Apresentar plano para aprovação

### Step 4.5: Sprint Contract (Harness — PBQ)

> **Conceito:** Contrato entre o agente builder e o agente evaluator.
> Inspirado no PBQ (Plan-Build-QA) e nos blog posts da OpenAI/Anthropic sobre Harness Engineering.

Antes de executar, gerar **contrato da fase**:

```markdown
## Sprint Contract — Fase [N]: [Nome]

### Concordado em: [DD/MM/YYYY HH:MM BRT]

### Entregaveis do Builder
| # | Entregavel | Arquivo(s) | Criterio de Aceite |
|---|-----------|-----------|-------------------|
| 1 | [o que sera implementado] | [path/to/file] | [como verificar] |
| 2 | ... | ... | ... |

### Sensores Obrigatorios
| Sensor | Comando | Obrigatorio |
|--------|---------|-------------|
| Lint | [comando do projeto] | Sim/N.A. |
| Tests | [comando do projeto] | Sim/N.A. |
| Typecheck | [comando do projeto] | Sim/N.A. |
| Build | [comando do projeto] | Sim/N.A. |

### Regras
- Builder implementa APENAS o que esta no contrato
- Evaluator verifica 1-a-1 contra o contrato (nao inventa requisitos extras)
- Se builder precisa mudar escopo: atualizar contrato ANTES de implementar
- Sensores rodam ANTES do evaluator julgar (evidencia objetiva primeiro)
```

**Por que contratos?**
- Sem contrato, o evaluator sugere coisas fora de escopo -> loop infinito
- Com contrato, a verificacao e binaria: "item X passou ou nao passou"
- O builder sabe exatamente o que precisa entregar
- O evaluator sabe exatamente o que precisa verificar

### Step 5: ⚙️ Execução da Fase

Executar via subagente worker ou diretamente:
1. Seguir plano da fase
2. Implementar step por step
3. Auto-testar quando possível

### Step 6: ✅ Verificação da Fase

Usar `spec-verify`:
1. Comparar implementação vs plano da fase
2. Classificar issues por severidade
3. Se CRITICAL → fix antes de avançar
4. Se MAJOR → fix ou registrar para fase futura
5. Se MINOR → registrar e seguir

### Step 7: ➡️ Próxima Fase

**Contexto carryover:**
```markdown
## Contexto da Fase Anterior
- **Fase [N-1] status:** ✅ Aprovado / ⚠️ Com ressalvas
- **Aprendizados:** [O que descobrimos durante implementação]
- **Issues pendentes:** [MAJOR/MINOR não resolvidos]
- **Ajustes no plano:** [Se o plano geral precisa adaptar]
```

**Adaptação:** Se a fase anterior revelou complexidade inesperada:
- Adicionar nova fase intermediária
- Reordenar fases restantes
- Ajustar escopo de fases futuras

---

## 2. Gestão de Fases

### Adicionar Fase
Quando implementação revela necessidade não prevista:
1. Definir nova fase com milestone
2. Inserir na posição correta da sequência
3. Ajustar dependências

### Reordenar Fases
Quando dependência muda ou prioridade shift:
1. Avaliar impacto da reordenação
2. Verificar que dependências continuam satisfeitas
3. Atualizar diagrama de sequência

### Pular Fase
Quando fase se torna desnecessária:
1. Registrar motivo do skip
2. Verificar que fases dependentes não são impactadas
3. Marcar como "⏭️ Skipped — [motivo]"

---

## 3. Progress Tracking

Manter estado atualizado:

```markdown
## Status das Fases

| # | Fase | Status | Issues | Notas |
|---|------|--------|--------|-------|
| 1 | Setup | ✅ Completa | 0C 0M 1m | — |
| 2 | Core Logic | 🔄 Em Progresso | — | Step 3/5 |
| 3 | API | ⏳ Pendente | — | Depende de Fase 2 |
| 4 | Tests | ⏳ Pendente | — | — |
| 5 | Polish | ⏳ Pendente | — | — |
```

Para sessões longas (3+ fases), usar `agent-harness` para checkpoints.

---

## 4. Progressive Disclosure

| Complexidade | Comportamento |
|-------------|---------------|
| **2-3 fases** | Decompor e executar inline |
| **4-5 fases** | Decompor, confirmar com usuário, executar sequencialmente |
| **6-7 fases** | Decompor, confirmar, sugerir `spec-yolo` para automação |
| **8+ fases** | Sugerir decomposição em épicos via `spec-epic` |

---

## 5. Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Cada fase precisa de plano file-level | `spec-planner` | Gerar plano detalhado com acceptance criteria por fase |
| Após execução de cada fase | `spec-verify` | Validar entregáveis contra milestone da fase |
| 6+ fases e automação desejada | `spec-yolo` | Ciclo Plan→Code→Verify→Fix autônomo |
| Loop iterativo dentro de cada fase | `alpha-loop` | Test→fix→retest quando implementação falha |
| 8+ fases com épico complexo | `spec-epic` | Decompor em épicos antes de fases |

---

## 6. Gotchas

⚠️ Consulte `gotchas.md` para problemas conhecidos. Principais:

1. **Fases muito granulares** → mais overhead que valor. Min 1 arquivo modificado por fase
2. **Fases sem milestone** → impossível verificar conclusão
3. **Dependência circular** → decompor de forma que fase A não dependa de B e vice-versa
4. **Contexto perdido entre fases** → sempre gerar contexto carryover explícito
5. **Scope creep** → cada nova descoberta vira "nova fase" ad infinitum. Max 7 fases
