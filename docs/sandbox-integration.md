# 🔒 /sandbox — Experimentação Isolada

## O que é

`/sandbox` roda Claude Code com isolação a nível de OS (Seatbelt no macOS, bubblewrap no Linux). No Windows, usar `--worktree` como equivalente funcional.

## Integração com /autonomous-agent-loop

O `/sandbox` + `--worktree` é o **blast radius zero** real para agentes autônomos:

```bash
# Criar worktree isolado para experimentação
claude --worktree experiment/scoring-v2

# Dentro do worktree: agente experimenta livremente
# Se der errado: deletar worktree, zero impacto no main
```

### Workflow recomendado

1. `claude --worktree experiment/[tag]` — criar ambiente isolado
2. Agente executa loop autônomo dentro do worktree
3. Se resultados bons → merge para branch principal
4. Se resultados ruins → deletar worktree (custo zero)

### Equivalência com Padrão 8 (Blast Radius)

| Sem sandbox | Com sandbox |
|-------------|-------------|
| Agente modifica código real | Agente modifica cópia isolada |
| Erro = rollback necessário | Erro = deletar worktree |
| Risco de side effects | Zero side effects |

### Quando usar

- `/autonomous-agent-loop` com escopo > 1 arquivo
- Experimentação em código de produção (Aria, landing pages)
- Testes de hipóteses que podem quebrar builds
