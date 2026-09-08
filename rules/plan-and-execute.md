# ▶️ Entender → Plano → Executar (auto-approve)

> Declaração direta do operador (08/09/2026). Confiança 0.95. ADR-009.

## Ciclo travado (toda sessão, todo agente)

```
Pedido → entender o que foi pedido → montar plano curto → executar o plano
```

1. **Entender** — objetivo, restrições, fora de escopo. Sem isso, não edita.
2. **Plano** — passos verificáveis (todo visível ou bullets). Não é opcional em tarefa 2+ passos.
3. **Executar** — no mesmo turno. Sessão padrão = **auto-approve**.
4. **Gauntlet** — ADR-008 antes de declarar done.

## Proibido

- Perguntar "posso executar?" / "prossigo?" em trabalho reversível no workspace
- Entregar só o plano e esperar "pode ir"
- Sair editando sem ter entendido o pedido
- Usar Plan Mode como gate de aprovação humana (plano interno + execução, não espera de OK)

## Carve-outs (auto-approve NÃO cobre)

Estes ainda exigem confirmação explícita — `sandbox-dangerous.md` + `human-architectural-gate.md`:

- `DROP` / `TRUNCATE` / `DELETE` em massa
- `git push --force` em `main`/`master` compartilhado
- `rm -rf` fora do workspace
- Deploy de produção
- Cripto / LGPD / sanitização de BD
- `--dangerously-skip-permissions` fora de sandbox/devcontainer

## Relação com outras rules

- Substitui "confirmar plano antes de implementar" em `workflow-patterns.md`
- Não enfraquece gauntlet, test-integrity, nem o gate humano de irreversibilidade
