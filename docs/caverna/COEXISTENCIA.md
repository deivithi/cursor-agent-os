# 🤝 Caverna × Token-Efficiency — Coexistência

> A `caverna` e a rule `.claude/rules/token-efficiency.md` são **complementares**, não concorrentes.
> Cobrem camadas diferentes do pipeline de economia de tokens.

## Mapa de responsabilidades

```
┌─────────────────────────────────────────────────────────────┐
│                    🔧 Token Efficiency (rule)                │
│  ─ Cache awareness (screenshots, modo, CLAUDE.md)            │
│  ─ Model routing (haiku/sonnet/opus por task)                │
│  ─ Extended thinking budget                                  │
│  ─ Effort mode (/fast, normal, /careful)                     │
│  ─ Context hygiene (subagentes, /compact)                    │
│  ─ Deferred tools (ToolSearch)                               │
└─────────────────────────────────────────────────────────────┘
                           ↓ complementa
┌─────────────────────────────────────────────────────────────┐
│                   🪨 Caverna (skill + hooks)                  │
│  ─ Compressão de OUTPUT (resposta do Claude)                 │
│  ─ Dropa artigos, filler, pleasantries, hedging              │
│  ─ Fragmentos, abreviações, setas de causalidade             │
│  ─ PT-BR Ultra com acentos + emojis preservados              │
│  ─ Safety carve-outs (segurança, deploy, Supabase)           │
└─────────────────────────────────────────────────────────────┘
```

## Camada por camada

| Camada | Token Efficiency | Caverna |
|--------|-----------------|---------|
| **Input (contexto)** | ✅ Cache, CLAUDE.md estável, subagentes absorvem | — |
| **Modelo** | ✅ Haiku p/ explorer, Sonnet p/ impl, Opus p/ arquitetura | — |
| **Thinking** | ✅ Budget por tipo de task | — |
| **Effort mode** | ✅ /fast, normal, /careful | — |
| **Output (resposta)** | — | ✅ **Compressão ~75%** |
| **Output (código)** | — | 💻 Preservado normal |
| **Output (commits)** | — | ✅ caverna-commit format |
| **Output (reviews)** | — | ✅ caverna-review format |

## Juntos: economia multiplicativa

Exemplo concreto — tarefa "explica diferença entre useMemo e useCallback":

**Sem nenhuma otimização:**
- Input: 800 tokens (contexto completo)
- Output: 53 palavras × 1.3 = 69 tokens
- Total: **869 tokens**

**Com Token Efficiency:**
- Input: 800 → 80 tokens (cache hit, 90% off)
- Output: 69 tokens (sem mudança)
- Total: **149 tokens** (83% economia)

**Com Token Efficiency + Caverna Ultra:**
- Input: 80 tokens (cache hit)
- Output: 69 → 15 tokens (compressão 78%)
- Total: **95 tokens** (89% economia vs baseline)

## Regras de prioridade

Quando regras conflitam (raro):

1. **Safety sempre ganha** — Token Efficiency e Caverna ambos pausam para segurança
2. **Caverna respeita cache** — não muda mid-session (trocar `/caverna leve` ↔ `ultra` invalida cache se hook reforço injetar contexto diferente a cada turno — mitigar: hook emite JSON estável)
3. **Token Efficiency é passivo, Caverna é ativa** — Token Efficiency é mindset, Caverna é enforcement via hook

## Falsos conflitos (não são conflito)

### ❌ "Caverna droppa artigos, mas código precisa artigos"
**Resolução:** Caverna tem regra inviolável **"Código/commits/PRs: normal"**. Zero compressão dentro de blocos técnicos.

### ❌ "Token Efficiency diz screenshots quebram cache, mas emojis do Caverna também são tokens"
**Resolução:** Emojis são 1-2 tokens cada, mas semanticamente DENSOS (substituem 5-10 palavras de descrição de severidade). Caverna + cache são compatíveis.

### ❌ "Subagentes absorvem verbose — por que preciso de Caverna se já uso subagente?"
**Resolução:** Subagente reduz contexto principal. Caverna reduz SUA resposta final ao user. Complementares. Subagente → explorer (haiku) → resumo 200 linhas → Claude principal → Caverna comprime resposta final em 50 linhas.

## Observabilidade

**Como medir que ambas estão funcionando:**

```bash
# Cache hit rate (Token Efficiency)
# — visível no dashboard de uso Anthropic
# — ideal: ≥70% hit em sessões longas

# Compressão Caverna
# — medir tokens saída vs baseline equivalente
# — ver .claude/docs/caverna/BENCHMARK.md
# — meta: ≥70% compressão média em Ultra

# Ambas combinadas
# — tokens totais de sessão / tarefa
# — comparar 2026-04 (só Token Efficiency) vs 2026-05 (+ Caverna)
```

## Evolução conjunta

Ambas são rules "vivas" — evoluem com uso:

| Gatilho | Atualizar Token Efficiency | Atualizar Caverna |
|---------|---------------------------|-------------------|
| Novo modelo Anthropic | ✅ model routing table | — |
| Nova feature cache | ✅ cache awareness | — |
| Cliente quer resposta formal | — | ✅ trocar default p/ `leve` |
| Novo padrão de commit no projeto | — | ✅ caverna-commit exemplos |
| Novo stack (e.g., Rust) | — | ✅ glossário termos técnicos |

## Decisão final

**NUNCA remover uma pela outra.** Ambas ficam. Ecossistema Deivithi = Token Efficiency (infraestrutura) + Caverna (interface).

Ref:
- `.claude/rules/token-efficiency.md`
- `.claude/skills/caverna/SKILL.md`
- `.claude/docs/caverna/BENCHMARK.md`
