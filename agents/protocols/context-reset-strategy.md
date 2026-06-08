# Context Reset Strategy

> Fonte: [Anthropic Engineering — Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) (2026-03-24)
> "Some models exhibit 'context anxiety,' beginning to wrap up work prematurely as they approach what they believe is their context limit."

## O Problema: Context Anxiety

Em sessões longas (30+ min, muitas tool calls), o modelo pode:
1. **Perder coerência** — esquecer decisões tomadas no início
2. **Ansiedade de contexto** — começar a "encerrar" prematuramente
3. **Degradar qualidade** — respostas mais superficiais conforme a janela enche

## Duas Estratégias

### 1. Context Compaction (Padrão)
O sistema comprime mensagens anteriores automaticamente.

**Quando funciona:**
- Tarefas lineares (uma coisa de cada vez)
- Contexto acumulado é redundante (muitas leituras do mesmo arquivo)
- Modelo atual (Opus 4.6) que sustenta contexto longo

**Quando falha:**
- Tarefas com muitas interdependências
- Quando decisões do início são críticas para o final
- Se o modelo começar a "encerrar" prematuramente

### 2. Context Reset (Handoff Estruturado)
Limpar a janela e recomeçar com um briefing condensado.

**Quando usar:**
- Sessão ultrapassou ~100 tool calls
- Modelo mostra sinais de context anxiety (respostas encurtando, "vou encerrar por aqui")
- Transição entre fases distintas (planning → building → QA)
- Mudança de agente (Generator → Evaluator)

**Como fazer o handoff:**

```markdown
## Context Handoff — Sprint N → Sprint N+1

### Estado Atual
- **Branch:** feature/xyz
- **Último commit:** abc1234 "feat: implementa componente X"
- **Arquivos modificados:** [lista]
- **Testes:** X passing, Y failing

### Decisões Tomadas
1. Decisão A — motivo
2. Decisão B — motivo
3. Decisão C — motivo

### Problemas Conhecidos
- Bug X: descrição
- TODO Y: descrição

### Próximos Passos
1. Implementar feature Z
2. Corrigir bug X
3. Rodar QA final

### Contrato Ativo
[Sprint Contract atual, se houver]
```

## Protocolo de Decisão

```
Sessão em andamento
    ↓
Detectar sinais de degradação:
  - Respostas ficando menores?
  - Esquecendo contexto anterior?
  - Começando a "encerrar"?
  - Muitas tool calls acumuladas (>100)?
    ↓
  ├── SIM → Context Reset
  │         1. Gerar handoff document
  │         2. Salvar em .claude/data/handoff-{timestamp}.md
  │         3. Git commit checkpoint
  │         4. Nova sessão com handoff como contexto
  │
  └── NÃO → Continuar (compaction automática funciona)
```

## Integração com Agent Harness

O `agent-harness` skill já faz checkpoints via git. O Context Reset complementa:

| Mecanismo | O que Preserva | Quando |
|-----------|---------------|--------|
| Git checkpoint | Código e arquivos | A cada milestone |
| Session tracker (hook) | Diff e status | Ao encerrar sessão |
| **Context Reset** | **Decisões, estado e plano** | **Ao detectar degradação** |
| `/recap` | Observações da sessão | Manual, no final |

## Anti-Patterns

❌ **Nunca fazer reset no meio de uma operação atômica** (ex: durante um refactor multi-arquivo)
❌ **Nunca perder decisões arquiteturais** — sempre incluir no handoff
❌ **Nunca resetar sem git checkpoint** — código não commitado pode ser perdido
❌ **Nunca assumir que compaction é suficiente** para tarefas com 5+ features interdependentes

## Para Opus 4.6 (Modelo Atual)

O artigo nota que Opus 4.6 sustenta tarefas mais longas e planeja melhor. Ajuste:
- **Threshold de reset:** ~150 tool calls (era ~80 para modelos anteriores)
- **Compaction funciona melhor:** Confiar mais na compaction automática
- **Resets entre fases:** Ainda recomendado na transição Generator → Evaluator
- **Sprint construct opcional:** Para tarefas que o modelo gerencia bem sozinho, evaluator no final basta
