---
name: spec-review
description: >
  Code review profundo com exploração agentic e categorização por tipo
  (Bug/Performance/Security/Clarity) e severidade (Critical/Major/Minor).
  Auto-fix individual, batch ou total via subagentes. Inspirado no Traycer.ai Review Mode.
domain: spec-driven-development
subdomain: code-review
version: 1.0.0
author: deivithi
tags:
  - spec-driven
  - code-review
  - agentic-review
  - categorization
  - auto-fix
  - traycer
---

# 🔍 Spec Review — Code Review Agentic Profundo

> **"Agentic code review with thorough exploration and analysis — deep insights into implementation details, potential issues, and improvement opportunities."**
> — Inspirado no Traycer.ai Review Mode

## 📁 File Structure
- `SKILL.md` — Você está aqui. Protocolo completo.
- `gotchas.md` — Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `spec-verify` — Verifica contra spec específica (spec-review é review genérico)
- `code-review` — Base existente (Severity Scoring). Spec-review adiciona categorização e exploração profunda
- `clean-code-rules` — Standards aplicados na categoria Clarity
- `security-audit` — Análise profunda para categoria Security
- `spec-planner` — Gerar plano de fix para issues complexas

---

## 🧠 Insight Central

> **spec-review ≠ code-review ≠ spec-verify.**
> - `code-review` = review rápido com severity scoring (existente)
> - `spec-review` = review profundo com exploração agentic e categorização (esta skill)
> - `spec-verify` = comparação implementation vs spec (verificação contra plano)

---

## 1. Workflow — 3 Steps

### Step 1: 📥 Input do Review

**O que o usuário fornece:**

| Campo | Obrigatório | Exemplos |
|-------|-------------|----------|
| **Código/arquivos** | ✅ | Paths, diretórios, componentes |
| **Query de foco** | ⬜ | "Revisar segurança", "Verificar performance", "Review geral" |
| **Contexto** | ⬜ | Docs, configs, testes, mockups, screenshots |
| **Git diff** | ⬜ | Uncommitted, against main, specific branch/commit |

**Se query não fornecida:** Fazer review geral cobrindo todas as 4 categorias.

### Step 2: 🔬 Exploração Profunda

1. **Ler código completo** — não apenas diff, mas contexto ao redor
2. **Subagente(s) Explore** para:
   - Rastrear dependências e imports
   - Entender padrões do codebase
   - Identificar código similar para comparação
3. **Análise cross-file** — seguir fluxo de dados entre arquivos
4. **Verificar edge cases** — inputs extremos, null, concorrência

### Step 3: 📊 Relatório de Review

Gerar relatório categorizado:

```markdown
# 🔍 Code Review: [Escopo]

## Resumo
- **Data:** [DD/MM/YYYY HH:MM BRT]
- **Escopo:** [arquivos/diretórios revisados]
- **Foco:** [query do usuário ou "Review geral"]

## Scorecard

| Categoria | 🔴 Critical | 🟠 Major | 🟡 Minor | Total |
|-----------|-------------|----------|----------|-------|
| 🐛 Bug | N | N | N | N |
| ⚡ Performance | N | N | N | N |
| 🔒 Security | N | N | N | N |
| 📖 Clarity | N | N | N | N |
| **Total** | **N** | **N** | **N** | **N** |

## 🐛 Bug

### [B1] 🔴 Título do bug
- **Arquivo:** `path/to/file.ext:42`
- **Problema:** [Descrição clara do bug]
- **Impacto:** [O que acontece se não corrigir]
- **Fix sugerido:**
```[linguagem]
// código corrigido
```

### [B2] 🟠 Título do bug
...

## ⚡ Performance

### [P1] 🟠 Título do issue
- **Arquivo:** `path/to/file.ext:87`
- **Problema:** [Gargalo identificado]
- **Impacto:** [Métrica afetada — tempo, memória, queries]
- **Fix sugerido:** [Otimização proposta]

## 🔒 Security

### [S1] 🔴 Título da vulnerabilidade
- **Arquivo:** `path/to/file.ext:15`
- **CWE/OWASP:** [Referência se aplicável]
- **Problema:** [Vulnerabilidade descrita]
- **Impacto:** [Risco concreto]
- **Fix sugerido:** [Correção com código]

## 📖 Clarity

### [CL1] 🟡 Título do issue
- **Arquivo:** `path/to/file.ext:100`
- **Problema:** [Legibilidade, naming, documentação]
- **Sugestão:** [Como melhorar]

## Destaques Positivos
- ✅ [O que está bem feito — padrões seguidos, código limpo, boa arquitetura]

## Recomendações Gerais
1. [Recomendação de alto nível]
2. [Recomendação de alto nível]
```

---

## 2. Categorias — Detalhamento

### 🐛 Bug
O que captura:
- Erros lógicos, condições incorretas
- Off-by-one, null pointer, race conditions
- Implementação que não faz o que deveria
- Testes que passam mas testam a coisa errada

### ⚡ Performance
O que captura:
- Queries N+1
- Re-renders desnecessários (React)
- Loops O(n²) quando O(n) é possível
- Dados carregados mas nunca usados
- Missing indexes, full table scans
- Memory leaks, closures retendo referências

### 🔒 Security
O que captura:
- Input não validado / sanitizado
- SQL injection, XSS, CSRF
- Secrets em código ou logs
- CORS misconfiguration
- Auth/authz bypass
- Dados sensíveis expostos

### 📖 Clarity
O que captura:
- Naming confuso ou inconsistente
- Funções longas (>50 linhas)
- Código duplicado
- Comentários desatualizados
- Missing types / any abuse
- Inconsistência com padrões do projeto

---

## 3. Auto-Fix

### Fix Individual
Selecionar issue → spawnar subagente worker com contexto → aplicar fix → mini-verify.

### Fix por Categoria
"Fix all Security issues" → agrupar por arquivo → subagente(s) → re-review da categoria.

### Fix por Severidade
"Fix all Critical" → ordenar por categoria (Security > Bug > Performance > Clarity) → fix sequencial.

### Fix All
Ordenar: Critical Security → Critical Bug → Major Security → Major Bug → ... → Minor Clarity.
Max 3 loops. Se não convergir, parar e reportar.

---

## 4. Progressive Disclosure

| Escopo | Comportamento |
|--------|---------------|
| **1-2 arquivos** | Review inline, sem subagentes |
| **3-10 arquivos** | Review com subagente Explore |
| **10+ arquivos** | Subagentes paralelos por diretório/componente |
| **Review de PR** | Focar no diff, mas explorar contexto ao redor |

---

## 5. Diferença vs code-review Existente

| Aspecto | `code-review` | `spec-review` |
|---------|---------------|---------------|
| **Foco** | Qualidade geral | Exploração profunda + categorização |
| **Categorias** | 5 severidades | 4 categorias x 3 severidades |
| **Exploração** | Diff-based | Cross-file agentic |
| **Auto-fix** | Não | Individual, batch, all |
| **Quando usar** | PR review rápido | Análise profunda de qualidade |

---

## 6. Gotchas

⚠️ Consulte `gotchas.md` para problemas conhecidos.
