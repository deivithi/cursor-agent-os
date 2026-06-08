---
name: alpha-loop
description: Flow multi-estágio test-iterate-refine inspirado no AlphaCodium. Gera código → testa → analisa falha → refina → repete. Aumenta accuracy de 19% para 44%+ em tarefas complexas. Use para qualquer implementação não-trivial onde qualidade é crítica.
license: Custom (pattern extraction)
metadata:
    skill-author: Deivithi (extracted from Codium-ai/AlphaCodium)
    source: https://github.com/Codium-ai/AlphaCodium
    paper: https://arxiv.org/abs/2401.08500
    version: 1.0.0
    extracted: 2026-03-23
---

# 🔄 Alpha Loop — Test-Iterate-Refine Flow

## 📁 File Structure
- `SKILL.md` — Você está aqui. Protocolo completo do flow.
- `references/provenance.md` — Fontes e paper original.
- `gotchas.md` — Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `test-driven-development` — TDD estrito (Red-Green-Refactor). Alpha Loop é complementar: TDD define os testes, Alpha Loop itera até todos passarem.
- `autonomous-agent-loop` — Para loops autônomos de longa duração. Alpha Loop é para uma task específica.
- `code-review` — Revisão pós-loop para validar qualidade além dos testes.
- `clean-code-rules` — Aplicar no passo de Refine para garantir qualidade do código.

---

## 🧠 Insight Central

> **"Gerar testes adicionais é mais fácil que gerar código correto."**
> — AlphaCodium paper (arXiv 2401.08500)

O AlphaCodium aumentou accuracy de **19% → 44%** (GPT-4, pass@5) usando um flow de 2 fases com iteração baseada em testes. O segredo: não iterar no código diretamente, mas usar testes como âncora de validação.

---

## 🏗️ O Flow (2 Fases, 7 Passos)

### FASE A — Pré-Processamento (Pensar antes de codar)

> Acumular conhecimento do fácil para o difícil. Cada passo alimenta o próximo.

#### Passo 1: 🔍 Problem Reflection

Antes de qualquer código, entender profundamente o problema:

```markdown
## Problem Reflection
- **Objetivo:** [O que precisa ser alcançado]
- **Inputs:** [O que é recebido — tipos, formato, constraints]
- **Outputs:** [O que deve ser entregue — tipos, formato, critérios]
- **Regras/Constraints:** [Limites, edge cases, invariantes]
- **Complexidade estimada:** [Simple | Medium | Complex]
```

**Quando pular:** Tasks triviais (1-2 linhas de mudança). Se a solução é óbvia, ir direto para Passo 3.

#### Passo 2: 🧪 Public Tests Reasoning

Analisar os testes existentes (ou criar se não houver):

```markdown
## Tests Reasoning
Para cada teste existente:
- **Test:** [nome/descrição]
- **Input:** [valores]
- **Expected Output:** [valores]
- **Racional:** [POR QUE este input gera este output — a lógica, não só o resultado]
```

**Insight:** Entender o *porquê* de cada teste revela a lógica do problema melhor que ler a spec.

#### Passo 3: 💡 Solution Candidates

Propor 2-3 abordagens em linguagem natural (não código):

```markdown
## Solution Candidates
1. **[Nome]:** [Descrição da abordagem, trade-offs]
2. **[Nome]:** [Descrição da abordagem, trade-offs]
3. **[Nome]:** [Descrição da abordagem, trade-offs]

**Escolhida:** #N — [justificativa: mais simples, mais eficiente, mais testável]
```

**Regra:** Escolher a solução mais simples que resolve o problema. Não a mais elegante.

#### Passo 4: 🧪 AI-Generated Tests

Gerar testes adicionais que cobrem edge cases não cobertos pelos testes existentes:

```markdown
## Additional Tests
- **Edge case 1:** [input extremo → expected output]
- **Edge case 2:** [input vazio/null → expected output]
- **Edge case 3:** [input no limite → expected output]
- **Boundary:** [input no exato ponto de transição]
```

**Por que funciona:** Gerar testes requer entender o problema, não resolvê-lo. É mais fácil que gerar código correto, e os testes servem como âncora de validação no loop.

---

### FASE B — Iteração de Código (Gerar → Testar → Analisar → Refinar)

> O coração do flow. Máximo **5 iterações** (configurable). Se não resolver em 5, repensar a abordagem.

#### Passo 5: 🛠️ Generate

Gerar código **modular** (funções pequenas com nomes descritivos):

```
REGRAS DE GERAÇÃO:
- Dividir em sub-funções (main + helpers)
- Nomes descritivos para cada função
- Uma responsabilidade por função
- Erros tratados explicitamente
```

**Por que modular:** O paper mostra que LLMs geram código melhor quando modularizam, e iterações subsequentes são mais eficazes quando podem focar em uma sub-função.

#### Passo 6: 🧪 Test & Analyze

Executar TODOS os testes (públicos + AI-generated):

```
PARA CADA TESTE:
  resultado = executar(código, teste.input)
  SE resultado !== teste.expected:
    REGISTRAR:
      - Qual teste falhou
      - Output real vs esperado
      - Hipótese da causa (qual sub-função?)
      - Tipo de falha: [logic | edge-case | type | off-by-one | missing-case]
```

**Análise de falha é OBRIGATÓRIA.** Nunca refinar às cegas — sempre diagnosticar antes.

#### Passo 7: 🔧 Refine

Com base na análise de falha, refinar o código:

```
PARA CADA FALHA:
  1. Identificar sub-função responsável
  2. Corrigir APENAS a sub-função (não reescrever tudo)
  3. Verificar se a correção não quebra testes que passavam
```

**Anti-pattern:** Reescrever do zero a cada iteração. A iteração deve ser **cirúrgica**.

Após refinar → voltar ao **Passo 6** (Test & Analyze).

---

## 🔁 Loop Control

```
iteration = 0
MAX_ITERATIONS = 5

WHILE iteration < MAX_ITERATIONS:
    IF iteration === 0:
        Generate (Passo 5)
    ELSE:
        Refine (Passo 7)

    results = Test & Analyze (Passo 6)

    IF all_tests_pass(results):
        → EXIT: SUCCESS

    IF no_progress(results, previous_results):
        → EXIT: STUCK (repensar abordagem — voltar ao Passo 3)

    iteration++

IF iteration >= MAX_ITERATIONS:
    → EXIT: MAX_ITERATIONS_REACHED
    → Reportar: quais testes ainda falham, hipótese de causa raiz
```

### Exit Criteria

| Condição | Ação |
|----------|------|
| ✅ Todos os testes passam | **SUCCESS** — prosseguir para quality check |
| 🔄 Progresso a cada iteração | Continuar iterando |
| 🟡 Sem progresso por 2 iterações | **STUCK** — voltar a Solution Candidates (Passo 3), escolher abordagem diferente |
| 🔴 MAX_ITERATIONS atingido | **TIMEOUT** — reportar estado, pedir input humano |
| 💥 Erro de ambiente (import, tool) | **ERROR** — diagnosticar ambiente, não código |

---

## 📊 Métricas do Loop

Registrar para cada task processada com Alpha Loop:

```json
{
  "task": "Descrição curta",
  "iterations": 3,
  "tests_total": 8,
  "tests_passed_iter_1": 5,
  "tests_passed_final": 8,
  "exit_condition": "SUCCESS",
  "approach_changes": 0,
  "duration_seconds": 120,
  "improvement_per_iteration": [0, 0.625, 0.875, 1.0]
}
```

---

## ⚡ Quick Reference — Quando Usar

| Situação | Usar Alpha Loop? | Motivo |
|----------|-----------------|--------|
| Bug fix simples (1-2 linhas) | ❌ | Overkill — corrigir direto |
| Feature nova com lógica complexa | ✅ | Testes como âncora reduzem iterations |
| Refactor com risco de regressão | ✅ | PASS_TO_PASS garante não-regressão |
| Data analysis / relatório | ❌ | Não é code — usar evals diretamente |
| Código com muitos edge cases | ✅✅ | AI-generated tests capturam edges que você esqueceria |
| Algorithm implementation | ✅✅ | Caso de uso original do paper |

---

## 🔌 Integração com Ecossistema

### Com TDD
```
TDD define os testes (Red) → Alpha Loop itera até passar (Green) → Refine aplica clean code (Refactor)
```

### Com Benchmark
```
Benchmark task → Alpha Loop como execution strategy → Score coletado → Ouroboros analisa
```

### Com Code Review
```
Alpha Loop gera código → Code Review (Reviewer agent) valida → Se rejeitar, volta ao loop
```

### Com Ouroboros
```
Ouroboros identifica skill fraca → Alpha Loop como strategy de melhoria → Medir se iterações ajudam
```

---

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Loop concluído com sucesso | `code-review` | Validar qualidade além dos testes automatizados |
| Passo Refine — aplicar standards | `clean-code-rules` | Enforcement de convenções por linguagem |
| MAX_ITERATIONS atingido sem resolver | `spec-planner` | Replanejar abordagem — loop não está convergindo |
| TDD estrito define testes primeiro | `test-driven-development` | Testes definem contrato, alpha-loop itera até passar |
| Ouroboros identifica skill fraca | `ouroboros` | Motor de auto-aprimoramento alimenta alpha-loop |

---

## 🎛️ Configuração

| Parâmetro | Default | Descrição |
|-----------|---------|-----------|
| `MAX_ITERATIONS` | 5 | Máximo de ciclos test-refine |
| `STUCK_THRESHOLD` | 2 | Iterações sem progresso antes de mudar abordagem |
| `SOLUTION_CANDIDATES` | 2-3 | Número de abordagens a considerar |
| `MODULAR_THRESHOLD` | 20 | Linhas de código acima das quais modularizar é obrigatório |
| `AI_TESTS_COUNT` | 3-5 | Testes adicionais gerados por AI |
