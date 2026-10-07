# 🔭 Zoom-Out — Anti-Narrowing Focus

> Ativa sempre. Complementa `adaptive-depth.md` (estagnação de loop) c/ drift de escopo.
> Problema: iterações sucessivas estreitam foco, fix pontual esquece quadro geral.

---

## 1. Triggers de zoom-out

Emitir mini-checkpoint quando QUALQUER:

- 3+ iterações consecutivas no mesmo arquivo/módulo
- 5+ arquivos editados na sessão
- User digita "parece q tá indo p/ outro lado" / "ficou confuso" / "perdi o fio"
- Task levou > 30 turnos sem checkpoint
- Pós `/compact` — re-estabelecer contexto

---

## 2. Formato checkpoint

Caverna terse, ≤5 linhas:

```
🔭 Zoom-out:
- Goal sessão: [1 linha — o q user pediu originalmente]
- Fiz: [bullet curto c/ 2-4 itens]
- Drift detectado: [sim/não — se sim, o q divergiu]
- Próx: [1 linha — próximo passo alinhado ao goal]
```

Exemplo:

```
🔭 Zoom-out:
- Goal sessão: fix bug de login Pulso
- Fiz: alterei middleware, refiz useAuth, adicionei retry
- Drift detectado: sim — retry ñ era pedido, adicionei por precaução
- Próx: remover retry, voltar foco ao middleware → validar c/ Supabase real
```

---

## 3. Ação se drift detectado

Quando `Drift: sim` → ANTES de continuar:

1. Perguntar user: "Drift detectado: [X]. Reverter ou manter?"
2. Se user quer reverter → git diff + reverter antes de avançar
3. Se user quer manter → registrar decisão (`[scope expand aprovado]`)
4. Se drift grande → oferecer `/compact` + replan via `spec-review`

---

## 4. Integração c/ adaptive-depth

`adaptive-depth.md` mede I(t) (ganho marginal). Zoom-out mede drift de escopo. Combinação:

| I(t) | Drift | Ação |
|---|---|---|
| Alto | Não | ✅ Continuar |
| Alto | Sim | ⚠️ Pausar, decidir escopo antes de prosseguir |
| Baixo | Não | ⚠️ Stagnation — EXIT ou replan |
| Baixo | Sim | 🛑 EXIT imediato + `spec-planner` replan |

---

## 5. Integração c/ caverna

Checkpoint é denso (4 linhas, cada uma é snapshot). Emojis preservados (🔭). Caverna ultra respeita — é sinal, ñ filler.

---

## 6. Quando NÃO zoom-out

- Task trivial (1-2 arquivos, 1 iteração)
- User já está direcionando iteração linear e curta
- Checkpoint recente (< 10 turnos atrás)
- Meio de operação atômica (migration em andamento, commit pendente)

---

## 7. Self-prompt p/ detectar drift

Antes de editar o 3º arquivo da sessão, pergunta interna:

```
- Este arquivo atende ao goal original?
- Estou resolvendo o q user pediu, ou criando feature nova q ñ foi pedida?
- A solução está convergindo ou espalhando?
```

Se 2 ou 3 respostas = "ñ" / "espalhando" → emitir zoom-out.

---

## 8. Anti-patterns

- ❌ Iterar 10× sem checkpoint — perde quadro geral silenciosamente
- ❌ Zoom-out virar cerimônia em cada turno — perde força
- ❌ Detectar drift e ignorar — violação de propósito da rule
- ❌ Usar zoom-out sem bullet "Próx:" — checkpoint s/ direção

---

## 9. Referência cruzada

- `adaptive-depth.md` — I(t), estagnação, overthinking guard
- `workflow-patterns.md` §1 — plan mode, replaneje se der errado
- `workflow-patterns.md` §10 — rule re-hidratação pós-compact
- CLAUDE.md `🧩 Integridade Conceitual` — zero Frankenstein, Brooks
- skill `spec-review` — revisão profunda quando drift grande
- skill `spec-planner` — replan quando I(t) baixo + drift
