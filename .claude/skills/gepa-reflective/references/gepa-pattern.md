# 📄 GEPA Pattern — Documentação Detalhada

## Origem

**Paper:** gepa-ai/gepa — "Reflective Text Evolution via LLM Agents"
**Venue:** ICLR 2026 (Oral presentation)
**Conceito central:** Em vez de usar recompensas escalares (como RL/GRPO), o agente lê o **trace textual completo** da execução para evoluir seus outputs de forma direcionada.

**Resultado-chave do paper:** Evolução reflexiva baseada em texto supera RL (RLHF, GRPO, DPO) em tarefas de otimização de texto onde o espaço de soluções é grande e as métricas são multi-dimensionais.

---

## Como Difere de RLHF / GRPO / DPO

| Aspecto | RLHF / GRPO / DPO | GEPA Reflective |
|---------|-------------------|-----------------|
| **Signal** | Recompensa escalar (número) | Trace textual completo (logs, diffs, erros) |
| **Informação por iteração** | "Score foi 0.73" | "Score caiu porque item 3 falhou: arquivo X não existe no path Y" |
| **Mecanismo de melhoria** | Gradient update / sampling | Diagnóstico causal + correção direcionada |
| **Requisito de infra** | Reward model treinado | Apenas LLM + mecanismo de logging |
| **Escalabilidade** | Precisa de muitas amostras | Converge com poucas iterações (evidência > volume) |
| **Interpretabilidade** | Baixa (pesos do modelo) | Alta (diagnóstico em linguagem natural) |

### Por que trace textual > recompensa escalar

Uma recompensa escalar (ex: 7/10) diz **quanto** melhorou ou piorou, mas não **por quê**.

O trace textual contém:
- **O que aconteceu** (logs de execução)
- **O que mudou** (git diff)
- **Onde quebrou** (stack trace, linha específica)
- **O que era esperado vs o que ocorreu** (assertion failures)

Com essa informação, o LLM pode fazer **diagnóstico causal** em vez de exploração cega.

---

## Implementação para Contexto Claude Code

### Arquitetura do Loop GEPA no Claude Code

```
┌─────────────────────────────────────────────────┐
│              GEPA Loop (Claude Code)            │
│                                                 │
│  Estado: git repo com skill + eval script       │
│                                                 │
│  1. [G] Ler diagnóstico anterior (se houver)    │
│     → Formular hipótese baseada em evidência    │
│     → Git commit: snapshot pré-mudança          │
│                                                 │
│  2. [E] Implementar mudança na skill            │
│     → Rodar eval script                         │
│     → Capturar: stdout, stderr, exit code       │
│     → Capturar: git diff da mudança             │
│     → Capturar: scores por item do checklist    │
│                                                 │
│  3. [P] Analisar trace completo                 │
│     → Comparar scores antes/depois por item     │
│     → Identificar padrão de falha (Tipo 1/2/3)  │
│     → Formular diagnóstico com citação do trace │
│     → Time-box: máx 20% do tempo do experimento │
│                                                 │
│  4. [A] Decidir ação baseada no diagnóstico     │
│     → Score melhorou: KEEP + registrar o que    │
│       funcionou no commit msg                   │
│     → Score piorou: NÃO descartar cegamente     │
│       → Usar diagnóstico para correção          │
│       → Git revert + aplicar fix direcionado    │
│     → Crash: classificar Tipo 3 se recorrente   │
│       → Registrar limitação e pivotar           │
│                                                 │
│  5. Repetir a partir de [G]                     │
└─────────────────────────────────────────────────┘
```

### Estrutura de Dados do Trace

```markdown
## Trace — Iteração N

### Metadata
- **Timestamp:** 2026-03-22 14:30 BRT
- **Skill:** gepa-reflective
- **Commit pré:** abc1234
- **Commit pós:** def5678

### Hipótese
"Adicionar seção de anti-patterns para cobrir checklist item 7"

### Git Diff (resumo)
+ 25 linhas adicionadas em SKILL.md (seção Anti-Patterns)
+ 0 arquivos criados/removidos

### Scores por Item
| # | Item | Antes | Depois | Delta |
|---|------|-------|--------|-------|
| 1 | Frontmatter válido | ✅ | ✅ | = |
| 2 | < 300 linhas | ✅ | ❌ | -1 |
| 3 | gotchas.md presente | ✅ | ✅ | = |
| 7 | Anti-patterns documentados | ❌ | ✅ | +1 |
**Total:** 7/10 → 7/10 (delta: 0)

### Logs
[stdout do eval script completo]

### Erros
"WARNING: SKILL.md has 312 lines, exceeds 300 line limit"
```

### Template de Diagnóstico

```markdown
## Diagnóstico — Iteração N

**Resultado:** ADAPT (score neutro, mas trade-off detectado)
**Classificação:** Tipo 2 — melhoria em um eixo, piora em outro

**Evidência do trace:**
- Item 7 passou (anti-patterns adicionados) ✅
- Item 2 falhou (312 linhas > 300 limite) ❌
- Log: "WARNING: SKILL.md has 312 lines"

**Causa raiz:** Conteúdo adicionado (+25 linhas) sem compensar
removendo conteúdo redundante de outras seções.

**Ação para próxima iteração:**
Condensar seção de Comparação (tabela tem redundância com
texto descritivo acima) para liberar ~15 linhas, mantendo
anti-patterns completo.
```

---

## Exemplo Completo: Trace → Diagnóstico → Fix

### Situação
Ouroboros está otimizando a skill `lead-audit`. Score atual: 6/10.

### Trace mostra
```
Item 3 FAIL: "gotchas.md — arquivo não encontrado"
Item 5 FAIL: "references/ — diretório vazio"
Item 8 PASS: "quality checklist presente"
```

### Diagnóstico (fase Plan)
```
Classificação: Tipo 1 (itens 3 e 5 falham desde iteração 1)
Causa raiz: A skill foi criada com estrutura mínima.
gotchas.md e references/ nunca foram populados porque
o autor focou apenas no SKILL.md principal.

Evidência: git log mostra 4 commits, todos editando SKILL.md.
Nenhum commit toca gotchas.md ou references/.
```

### Correção Direcionada (fase Adapt)
```
Ação: Criar gotchas.md a partir de padrões reais de uso.
- Analisar traces anteriores para identificar problemas recorrentes
- Documentar cada gotcha com: sintoma, causa raiz, solução, prevenção
- Criar references/ com documentação de proveniência da skill

Predição: Items 3 e 5 devem passar. Score esperado: 8/10 (+2).
```

### Resultado
```
Score: 6/10 → 8/10 (delta: +2) — KEEP ✅
Commit: "gepa(lead-audit): iter 5 — KEEP — gotchas + references"
```

**Contraste com keep/discard simples:** Sem o diagnóstico, o agente teria descartado a iteração 4 e tentado algo aleatório (talvez reescrever o SKILL.md inteiro), sem perceber que o problema era a ausência de arquivos complementares.

---

## Quando Usar GEPA vs Keep/Discard Simples

| Cenário | Recomendação |
|---------|-------------|
| Espaço de soluções pequeno (< 10 opções) | Keep/Discard é suficiente |
| Métrica unidimensional (um número) | Keep/Discard é suficiente |
| Espaço grande + múltiplas dimensões | **GEPA** — diagnóstico direciona a busca |
| Falhas recorrentes no mesmo ponto | **GEPA** — identifica Tipo 1 e força mudança radical |
| Otimização de skills (Ouroboros) | **GEPA** — cada skill tem ~10 critérios de avaliação |
| Debug de workflows n8n | **GEPA** — traces de execução são naturalmente ricos |

---

## Referências

- **gepa-ai/gepa** — GitHub repo + paper ICLR 2026 Oral
- **Karpathy autoresearch** — Loop autônomo base (2025)
- **Ouroboros** — Motor de auto-aprimoramento que integra GEPA como evolução do keep/discard
- **CALM patterns** — Compressão semântica complementar (arXiv 2510.27688)
