# 🔁 Manutenção contínua

Roda um ciclo de manutenção: coleta sinais, faz a triagem, corrige até o orçamento e manda o resumo. Uso: `/manutencao [<projeto>|triagem <projeto>|agendar <projeto>]`

Carregue a skill `manutencao-continua` (`~/.claude/skills/manutencao-continua/SKILL.md`) e siga o workflow. Funciona de qualquer pasta.

## Modos

| Comando | Efeito |
|---|---|
| `/manutencao <projeto>` | Fases 1 a 5: coleta, triagem, correção por agente, resto da fila e resumo ao PO |
| `/manutencao triagem <projeto>` | Só Fases 1 e 2: mostra a fila sem corrigir nada. Atualiza só a conciliação de PRs e as âncoras de CI no estado (idempotente) |
| `/manutencao agendar <projeto>` | Propõe a agenda do ciclo e pede confirmação antes de ligar |

## Limites

- O ciclo nunca mescla PR nem publica em prd.
- LGPD, cripto e dado em massa param no gate humano.
- Duas tentativas sem sucesso no mesmo item → escala para o PO.
- Issue de autor de fora só entra na correção com o rótulo `aprovado`.
