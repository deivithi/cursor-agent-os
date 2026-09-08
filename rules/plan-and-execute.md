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

## Resolve, não transfere (ADR-010)

O operador não é o depurador. Erro, falha, gap ou instrução subótima →
o agente corrige/escolhe o caminho certo e segue. Sem lista de problemas,
sem "challenge", sem "você decide". Relato = resultado feito.

## Proibido

- Perguntar "posso executar?" / "prossigo?" em trabalho reversível no workspace
- Entregar só o plano e esperar "pode ir"
- Sair editando sem ter entendido o pedido
- Usar Plan Mode como gate de aprovação humana (plano interno + execução, não espera de OK)
- Apontar erros/falhas/desafios para o operador resolver no lugar do agente

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
- ADR-010 substitui challenge `[s/n]` de `anti-sycophancy.md` — resolve a alternativa correta
- Não enfraquece gauntlet, test-integrity (não apagar teste), nem o gate humano de irreversibilidade
