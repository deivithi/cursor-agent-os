# Resume — Continuar Sessão Anterior

Retomando contexto da sessão anterior.

## Protocolo

1. **Ler último snapshot** de `.claude/data/sessions/` (mais recente)
2. **Ler session-log.md** para mudanças recentes
3. **Ler tasks/todo.md** para itens pendentes (se existir)
4. **Apresentar resumo estruturado:**

```
## Sessão Anterior
- **Branch:** {branch}
- **Último commit:** {hash}
- **Arquivos modificados:** {lista}
- **Itens pendentes:** {count}
- **Resumo de commits recentes:** {lista}
```

5. **Perguntar:** "Continuar de onde parou ou iniciar nova tarefa?"

## Fonte de Dados

```bash
# Encontrar snapshot mais recente
LATEST=$(ls -t .claude/data/sessions/session-*.json 2>/dev/null | head -1)

# Ler session log
cat memory/session-log.md | tail -30

# Ler tarefas pendentes
grep '^\- \[ \]' tasks/todo.md 2>/dev/null
```

## Integração

- Ativado por `/resume` ou quando o assistente detecta que o usuário quer retomar trabalho anterior
- O SessionStart hook já injeta sinais prioritários — `/resume` complementa com contexto completo
- Combina com `/fork` para criar branch alternativo a partir do estado anterior
