---
name: spec-verify
description: >
  Verifica implementação contra spec/plano original. Classifica issues por severidade
  (Critical/Major/Minor) e categoria (Bug/Performance/Security/Clarity). Auto-fix
  opcional via subagentes. Re-verify incremental ou fresh. Inspirado no Traycer.ai Verification.
domain: spec-driven-development
subdomain: verification
version: 1.0.0
author: deivithi
tags:
  - spec-driven
  - verification
  - acceptance-criteria
  - severity-scoring
  - auto-fix
  - traycer
---

# ✅ Spec Verify — Verificação Implementation vs Spec

> **"Verification confirms the agent's changes match the spec, pass checks, and introduce no regressions."**
> — Inspirado no Traycer.ai Verification System

## 📁 File Structure
- `SKILL.md` — Você está aqui. Protocolo completo.
- `gotchas.md` — Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `spec-planner` — Gera os planos que esta skill verifica
- `spec-phases` — Verificação entre fases
- `code-review` — Base do sistema de review (Severity Scoring)
- `clean-code-rules` — Standards de código para categoria Clarity
- `security-audit` — Verificação profunda para categoria Security
- `alpha-loop` — Loop iterativo quando auto-fix é ativado

---

## 🧠 Insight Central

> **Verificação ≠ Code Review.**
> Code review analisa qualidade geral. Verificação compara implementação contra uma spec específica.
> A pergunta central é: **"O que foi implementado corresponde ao que foi planejado?"**

---

## 1. Input da Verificação

| Campo | Obrigatório | Fonte |
|-------|-------------|-------|
| **Plano/Spec original** | ✅ | Output de `spec-planner`, `spec-phases`, ou spec manual |
| **Código implementado** | ✅ | Git diff, arquivos modificados, ou branch inteira |
| **Acceptance criteria** | ✅ | Do plano original (checklist verificável) |
| **Contexto adicional** | ⬜ | Testes, logs de erro, screenshots |

### Como obter o diff

```bash
# Uncommitted changes
git diff

# Against main
git diff main...HEAD

# Specific commit
git diff <commit-hash>

# Specific files
git diff -- path/to/file1.ext path/to/file2.ext
```

---

## 2. Sensores Obrigatórios (Harness — Feedback Layer)

> **Regra fundamental:** O agente NÃO julga qualidade — sensores julgam.
> Inspirado no Harness Engineering (OpenAI, Anthropic, Martin Fowler).
> "O que força não é a instrução, o que força são os sensores." — Waldemar Neto

### O que são sensores?

Comandos externos que retornam resultado objetivo (pass/fail). O agente **deve executar** estes comandos e usar o output como evidência, em vez de auto-avaliar olhando o código.

### Sensores padrão

| Sensor | Comando típico | O que verifica |
|--------|---------------|----------------|
| **Lint** | `npm run lint` / `eslint .` / `ruff check .` | Estilo, convenções, erros estáticos |
| **Tests** | `npm test` / `pytest` / `vitest run` | Comportamento funcional |
| **Typecheck** | `tsc --noEmit` / `mypy .` | Consistência de tipos |
| **Build** | `npm run build` / `vite build` | Compilação sem erros |

### Protocolo de execução

1. **Detectar sensores disponíveis** — verificar package.json scripts, Makefile, pyproject.toml
2. **Executar cada sensor** — rodar o comando real, capturar output
3. **Registrar resultado** como evidência objetiva:

```markdown
### Sensor Results
| Sensor | Comando | Status | Output (resumo) |
|--------|---------|--------|-----------------|
| Lint | `npm run lint` | ✅ Pass | 0 errors, 2 warnings |
| Tests | `npm test` | ❌ Fail | 3 passed, 1 failed (auth.test.ts:42) |
| Typecheck | `tsc --noEmit` | ✅ Pass | No errors |
| Build | `npm run build` | ✅ Pass | Built in 3.2s |
```

4. **Se sensor não disponível** — registrar "⚠️ N/A — [motivo]" (sem penalizar no score)
5. **Sensor falhou** — incluir output do erro como contexto para auto-fix

**Regra inviolável:** Não declarar verificação "aprovada" se algum sensor falhou, independente da avaliação subjetiva do código.

---

## 3. Scoring System (Harness — Evaluation)

> **Avaliação quantitativa, não apenas qualitativa.**
> Cada acceptance criteria e sensor recebe score numérico.

### Score por item

| Resultado | Score |
|-----------|-------|
| Passou | 1.0 |
| Parcial | 0.5 |
| Falhou | 0.0 |

### Ponderação por severidade

| Severidade | Peso | Justificativa |
|-----------|------|---------------|
| CRITICAL | 3x | Bloqueia funcionalidade core |
| MAJOR | 2x | Impacto significativo |
| MINOR | 1x | Polish, não obstrui |

### Cálculo do score agregado

```
Score = Σ(score_item × peso_severidade) / Σ(peso_severidade)
```

### Thresholds de decisão

| Score | Veredicto | Ação |
|-------|-----------|------|
| **≥ 0.90** | ✅ APROVADO | Prosseguir para próxima fase |
| **0.85-0.89** | ✅ APROVADO COM RESSALVAS | Prosseguir, gaps menores registrados |
| **0.60-0.84** | ❌ REPROVADO | Fix obrigatório + re-verify |
| **< 0.60** | ⛔ PARADA | Escalação para review humano |

### Evaluation Report (gerado ao final de cada sprint/fase)

```markdown
## Evaluation Report — [Sprint/Fase N]

### Score Final: [X.XX]/1.00
### Veredicto: [APROVADO / REPROVADO / PARADA]

### Sensors
| Sensor | Status | Score |
|--------|--------|-------|
| Lint | ✅ | 1.0 |
| Tests | ❌ (1 fail) | 0.5 |
| Build | ✅ | 1.0 |

### Contract Items (se sprint contract existir)
| # | Item | Status | Score |
|---|------|--------|-------|
| 1 | [entregável] | ✅ | 1.0 |
| 2 | [entregável] | ❌ | 0.0 |

### Acceptance Criteria
| # | Critério | Severidade | Status | Score |
|---|----------|-----------|--------|-------|
| 1 | [critério] | CRITICAL | ✅ | 1.0 × 3 |
| 2 | [critério] | MAJOR | ❌ | 0.0 × 2 |

### Resumo
- Sensors: [N]/[total] passed
- Contract: [N]/[total] items delivered
- Acceptance: [N]/[total] criteria met
- Score: [X.XX] ([veredicto])
```

---

## 4. Workflow de Verificação

### Step 1: 📋 Carregar Spec

1. Ler o plano/spec original completo
2. Extrair acceptance criteria como checklist
3. Extrair lista de arquivos que deveriam ser modificados
4. Extrair sequência de implementação esperada

### Step 2: 📂 Carregar Implementação

1. Obter diff completo (git diff ou leitura de arquivos)
2. Listar arquivos que foram efetivamente modificados
3. Comparar lista de arquivos: esperados vs efetivos

### Step 3: 🔍 Análise Comparativa

Para cada acceptance criteria do plano:

```markdown
| # | Critério | Status | Evidência | Issue? |
|---|----------|--------|-----------|--------|
| 1 | [critério] | ✅ Atendido / ❌ Não atendido / ⚠️ Parcial | [onde no código] | [se não, descrever] |
```

Para cada arquivo esperado:

```markdown
| Arquivo | Esperado | Implementado | Delta |
|---------|----------|-------------|-------|
| `path/file.ext` | Criar/Modificar | Criado/Modificado/Ausente | [diferenças] |
```

### Step 4: 🏷️ Classificação de Issues

#### Severidade (4 níveis)

| Nível | Emoji | Critério | Ação Requerida |
|-------|-------|----------|----------------|
| **CRITICAL** | 🔴 | Bloqueia funcionalidade core ou viola acceptance criteria principal | Fix obrigatório antes de prosseguir |
| **MAJOR** | 🟠 | Impacto significativo em behavior/UX, workarounds possíveis | Fix recomendado fortemente |
| **MINOR** | 🟡 | Polish, otimização, legibilidade — não obstrui funcionalidade | Fix opcional, sugerir melhoria |
| **OUTDATED** | ⚪ | Issue que já foi resolvida por mudança subsequente | Ignorar, apenas registrar |

#### Categoria (4 tipos)

| Categoria | Emoji | O que captura |
|-----------|-------|---------------|
| **Bug** | 🐛 | Erros lógicos, implementação incorreta, comportamento inesperado |
| **Performance** | ⚡ | Gargalos, queries N+1, re-renders, loops desnecessários |
| **Security** | 🔒 | Vulnerabilidades, dados expostos, input não validado, OWASP |
| **Clarity** | 📖 | Legibilidade, naming, documentação, padrões do projeto |

### Step 5: 📊 Relatório de Verificação

Gerar relatório estruturado:

```markdown
# 📊 Relatório de Verificação

## Resumo
- **Spec:** [título do plano]
- **Data:** [DD/MM/YYYY HH:MM BRT]
- **Status Geral:** ✅ APROVADO / ⚠️ APROVADO COM RESSALVAS / ❌ REPROVADO

## Acceptance Criteria
- ✅ [X] de [Y] critérios atendidos
- ❌ [Z] critérios não atendidos (listados abaixo)

## Scorecard

| Severidade | Quantidade |
|------------|-----------|
| 🔴 Critical | N |
| 🟠 Major | N |
| 🟡 Minor | N |
| ⚪ Outdated | N |

## Issues Encontradas

### 🔴 CRITICAL

#### [C1] Título da issue
- **Categoria:** Bug/Performance/Security/Clarity
- **Arquivo:** `path/to/file.ext:42`
- **Spec esperava:** [o que o plano dizia]
- **Implementação fez:** [o que o código faz]
- **Fix sugerido:** [como corrigir]

### 🟠 MAJOR
...

### 🟡 MINOR
...

## Arquivos — Cobertura
| Arquivo Esperado | Status |
|-----------------|--------|
| `file1.ext` | ✅ Implementado |
| `file2.ext` | ❌ Ausente |

## Veredicto
[Aprovação condicional? Quais issues bloquear merge? Próximos passos?]
```

---

## 3. Status Geral — Critérios

| Status | Condição |
|--------|----------|
| ✅ **APROVADO** | 0 Critical, 0 Major, todos acceptance criteria ✅ |
| ⚠️ **APROVADO COM RESSALVAS** | 0 Critical, ≤2 Major com workaround, ≥80% acceptance criteria ✅ |
| ❌ **REPROVADO** | Qualquer Critical, OU ≥3 Major, OU <80% acceptance criteria |

---

## 4. Auto-Fix (Opcional)

Quando o usuário solicitar auto-fix:

### Fix Individual
1. Selecionar issue específica
2. Spawnar subagente worker com contexto:
   - Arquivo afetado
   - Issue description + fix sugerido
   - Acceptance criteria original
3. Verificar fix (mini re-verify)

### Fix Batch
1. Selecionar issues por severidade (ex: "fix all CRITICAL")
2. Agrupar por arquivo
3. Spawnar subagente(s) worker por arquivo
4. Re-verify completo após fixes

### Fix All
1. Ordenar issues: Critical → Major → Minor
2. Fix sequencial (Critical primeiro para não criar cascata)
3. Re-verify completo
4. **Max 3 loops** — se ainda houver Critical após 3 loops, parar e reportar

---

## 5. Re-Verify — Dois Modos

### 5.1 Re-Verify Incremental
- Foco apenas em issues previamente reportadas
- Verifica se fixes resolveram os problemas
- Mais rápido (não re-analisa tudo)
- **Quando usar:** Após fix individual ou batch

### 5.2 Fresh Verify
- Análise completa do zero, ignora issues anteriores
- Descobre novos problemas introduzidos por fixes
- Mais completo, mais lento
- **Quando usar:** Após fix all, ou quando implementação mudou significativamente

---

## 6. Progressive Disclosure

| Complexidade | Comportamento |
|-------------|---------------|
| **Simples** (1-3 critérios) | Checklist inline, sem relatório formal |
| **Médio** (4-10 critérios) | Relatório completo com scorecard |
| **Complexo** (10+ critérios) | Relatório + subagentes para análise paralela por arquivo |

---

## 7. Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Issues CRITICAL de segurança | `security-audit` | Análise profunda com Semgrep + OWASP Top 10 |
| Issues de Clarity/estilo | `clean-code-rules` | Enforcement de convenções por linguagem |
| Issues persistentes após 2 re-verificações | `alpha-loop` | Loop iterativo test→fix→retest (max 5 iterações) |
| Verificação entre fases | `spec-phases` | Retornar resultado para orquestrador de fases |
| Todos issues resolvidos, pronto para review | `code-review` | Review final antes de merge/deploy |

---

## 8. Gotchas

⚠️ Consulte `gotchas.md` para problemas conhecidos. Principais:

1. **Verificar contra spec errada** → sempre confirmar qual plano é a referência
2. **Auto-fix introduz novo bug** → max 3 loops, depois parar e reportar
3. **Acceptance criteria vago** → impossível verificar "funciona corretamente"
4. **Diff incompleto** → usar `git diff main...HEAD` para capturar todas as mudanças
5. **False positive em OUTDATED** → issue marcada outdated pode ter voltado
