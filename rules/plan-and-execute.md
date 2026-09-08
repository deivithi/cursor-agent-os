# ▶️ Entender → Plano → Executar (auto-approve)

> Declaração direta do operador (08/09/2026). Confiança 0.95. ADR-009.

## Ciclo travado (toda sessão, todo agente)

```
Pedido → entender → match skill → plano curto → executar (máxima autonomia)
```

1. **Entender** — objetivo, restrições, fora de escopo. Sem isso, não edita.
2. **Skill** — ADR-011. Toda ação consulta o catálogo. Match → carregar `SKILL.md` e seguir o protocolo. Sem perguntar "uso a skill X?".
3. **Plano** — passos verificáveis (todo visível ou bullets). Não é opcional em tarefa 2+ passos.
4. **Executar** — no mesmo turno, máxima autonomia. Pediu → faz.
5. **Gauntlet** — ADR-008 antes de declarar done.

## Resolve, não transfere (ADR-010)

O operador não é o depurador. Erro, falha, gap ou instrução subótima →
o agente corrige/escolhe o caminho certo e segue. Sem lista de problemas,
sem "challenge", sem "você decide". Relato = resultado feito.

## Skill em toda ação (ADR-011)

Antes de agir, casar o pedido com o catálogo:

1. `SKILLS_INDEX.md` (custom / cyber / scientific)
2. Skills já no contexto da sessão
3. Agency agents (`.claude/agents/agency/`) se o tema bater — skill interna vence

Match → ler o `SKILL.md` e potencializar. Sem match → seguir direto.
Não listar skills para o operador escolher. Usar.

## Proibido

- Perguntar "posso executar?" / "prossigo?" em trabalho reversível no workspace
- Entregar só o plano e esperar "pode ir"
- Sair editando sem ter entendido o pedido
- Usar Plan Mode como gate de aprovação humana (plano interno + execução, não espera de OK)
- Apontar erros/falhas/desafios para o operador resolver no lugar do agente
- Agir sem checar se uma skill do catálogo potencializa a ação
- Perguntar se deve usar uma skill quando o match é óbvio

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
- ADR-011 torna o match de skill passo obrigatório do ciclo
- Não enfraquece gauntlet, test-integrity (não apagar teste), nem o gate humano de irreversibilidade
