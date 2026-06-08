---
name: spec-planner
description: >
  Gera planos de implementação file-level detalhados a partir de uma query.
  Análise estrutural do codebase, diagramas Mermaid, acceptance criteria por step,
  e prompt pronto para handoff a qualquer agente. Inspirado no Plan Mode do Traycer.ai.
domain: spec-driven-development
subdomain: planning
version: 1.0.0
author: deivithi
tags:
  - spec-driven
  - planning
  - file-level-plan
  - mermaid
  - acceptance-criteria
  - traycer
---

# 📋 Spec Planner — Plano File-Level Detalhado

> **"Structured specs eliminate agent drift. The plan IS the product."**
> — Inspirado no Traycer.ai Plan Mode

## 📁 File Structure
- `SKILL.md` — Você está aqui. Protocolo completo.
- `gotchas.md` — Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `spec-verify` — Verificar implementação contra o plano gerado
- `spec-phases` — Decompor planos complexos em fases verificáveis
- `spec-epic` — Pipeline completo intent → specs → tickets
- `mermaid-diagrams` — Gera diagramas referenciados no plano
- `smart-explore` (comando) — Exploração progressiva do codebase
- `make-plan` (comando) — Planejamento com Gating Instructions (complementar)

---

## 🧠 Insight Central

> **O plano não é um rascunho — é a spec executável.**
> Cada step deve ter: arquivos, sequência, referências, e critérios de aceite.
> Se o plano é ambíguo, a implementação será ambígua.

---

## 1. Workflow — Plan Mode

### Step 1: 📥 Captura de Input

Coletar do usuário:

| Campo | Obrigatório | Descrição |
|-------|-------------|-----------|
| **Objetivo** | ✅ | O que precisa ser alcançado (resultado concreto) |
| **Resultado esperado** | ✅ | Como o usuário saberá que funcionou |
| **Restrições** | ⬜ | Limitações técnicas, compatibilidade, escopo |
| **Contexto adicional** | ⬜ | Arquivos-fonte, configs, docs, mockups, screenshots |
| **Git diff** | ⬜ | Uncommitted, against main, specific branch/commit |

**Se o objetivo for vago:** Fazer 2-3 perguntas estratégicas antes de prosseguir.
**Nunca assumir** — elicitar constraints e edge cases ativamente.

### Step 2: 🔍 Análise do Codebase

Explorar o codebase para construir contexto:

1. **Subagente Explore** (quick/medium conforme complexidade):
   - Buscar arquivos relevantes ao objetivo
   - Identificar padrões existentes, utilities reutilizáveis
   - Mapear dependências e imports

2. **Análise Estrutural** — Para cada arquivo relevante:
   ```markdown
   - **Arquivo:** path/to/file.ext
   - **Papel:** O que este arquivo faz no contexto do objetivo
   - **Símbolos relevantes:** funções, classes, exports que serão usados/modificados
   - **Dependências:** imports que este arquivo traz
   ```

3. **Verificação de Fatos** — Todo fato usado no plano DEVE ter fonte:
   - Arquivo existente → path confirmado via Glob
   - API/lib → versão verificada via docs ou package.json
   - Pattern → exemplo encontrado no codebase

### Step 3: 📐 Geração do Plano

Gerar plano estruturado seguindo este template:

```markdown
# 📋 Plano de Implementação: [Título]

## Objetivo
[1-2 frases do que será alcançado]

## Diagrama de Arquitetura
[Diagrama Mermaid mostrando fluxo/arquitetura — usar skill mermaid-diagrams]

## Arquivos Impactados

| # | Arquivo | Ação | Descrição |
|---|---------|------|-----------|
| 1 | `path/to/file.ext` | Criar/Modificar/Deletar | O que muda neste arquivo |
| 2 | ... | ... | ... |

## Steps de Implementação

### Step 1: [Nome descritivo]
**Arquivo(s):** `path/to/file.ext`
**Ação:** [O que fazer]
**Detalhes:**
- [Instrução específica 1]
- [Instrução específica 2]
**Referências:** [Símbolos, padrões, exemplos do codebase a seguir]
**Acceptance Criteria:**
- [ ] [Critério verificável 1]
- [ ] [Critério verificável 2]

### Step 2: [Nome descritivo]
...

## Sequência de Execução
[Diagrama Mermaid de sequência se houver dependências entre steps]

## Riscos e Mitigações
| Risco | Probabilidade | Mitigação |
|-------|---------------|-----------|
| ... | Alta/Média/Baixa | ... |

## Critérios de Aceite Globais
- [ ] [Critério 1 — cobertura end-to-end]
- [ ] [Critério 2 — sem regressões]
- [ ] [Critério 3 — padrões do projeto respeitados]
```

### Step 4: 🔄 Iteração no Plano

- Apresentar plano ao usuário
- Se desalinhado: ajustar e re-apresentar
- **Regra:** O plano não avança para execução até aprovação explícita

### Step 5: 🤖 Handoff (Opcional)

Se o usuário quiser entregar para agente externo:

1. Gerar prompt otimizado contendo:
   - Contexto do projeto (de AGENTS.md ou CLAUDE.md se existir)
   - Plano completo em Markdown
   - Acceptance criteria como checklist
2. Formatar para copy/paste ou clipboard

---

## 2. Diagramas Mermaid

Incluir diagramas Mermaid quando o plano envolver:
- **Fluxo de dados** → `flowchart TD`
- **Sequência de chamadas** → `sequenceDiagram`
- **Estrutura de componentes** → `graph LR`
- **Entidades/relações** → `erDiagram`

Usar a skill `mermaid-diagrams` como referência de syntax.

**Regra:** Diagrama DEVE ser renderizável (syntax válida). Validar mentalmente antes de entregar.

---

## 3. Acceptance Criteria — Padrão

Todo step DEVE ter acceptance criteria que são:

| Propriedade | Requisito |
|-------------|-----------|
| **Verificável** | Pode ser testado (sim/não, não subjetivo) |
| **Específico** | Referencia arquivo, função ou comportamento concreto |
| **Independente** | Pode ser verificado isoladamente |
| **Completo** | Cobre o que o step entrega |

**Anti-patterns:**
- ❌ "Código limpo" (subjetivo)
- ❌ "Funciona corretamente" (vago)
- ✅ "Função `createUser()` retorna objeto com `id`, `email`, `createdAt`"
- ✅ "Endpoint `POST /api/users` responde 201 com body contendo `id`"

---

## 4. Progressive Disclosure

| Complexidade | Comportamento |
|-------------|---------------|
| **Simples** (1-3 arquivos) | Plano inline, sem diagrama obrigatório |
| **Médio** (4-10 arquivos) | Plano completo com diagrama de arquitetura |
| **Complexo** (10+ arquivos) | Sugerir decomposição em `spec-phases` |

---

## 5. Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Plano gerado, pronto para verificar | `spec-verify` | Sempre após implementação — validar contra acceptance criteria |
| Objetivo complexo com 4+ entregas | `spec-phases` | Decompor em fases verificáveis antes de executar |
| Automação total desejada | `spec-yolo` | Plan→Code→Verify→Fix sem intervenção humana |
| Plano envolve diagramas de arquitetura | `mermaid-diagrams` | Visualizar dependências e fluxos antes de implementar |
| Plano requer pesquisa prévia | `deep-research-workspace` | Investigar antes de planejar quando domínio é desconhecido |

---

## 6. Gotchas

⚠️ Consulte `gotchas.md` para problemas conhecidos. Principais:

1. **Plano sem acceptance criteria** → implementação não verificável
2. **Arquivos não confirmados via Glob** → plano referencia arquivo que não existe
3. **Diagrama Mermaid com syntax inválida** → renderiza erro em vez de diagrama
4. **Plano muito granular** → micro-steps que confundem mais que ajudam
5. **Plano sem sequência** → agente executa steps em ordem errada
