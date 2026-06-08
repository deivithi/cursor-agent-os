# Automations — Tarefas Agendadas com Review Queue

Operação solicitada: **$ARGUMENTS**

## Subcomandos

### `/automations list`
Lista todas as automações registradas em `.claude/data/automations/registry.json`.
Mostrar: ID, nome, schedule (cron), status (enabled/disabled), última execução.

### `/automations add`
Adiciona nova automação ao registry.
Coletar do usuário:
- **name:** Nome descritivo
- **schedule:** Expressão cron (ex: `0 8 * * 1-5` = 8h dias úteis)
- **command:** Comando Claude ou slash command a executar
- **notify:** Canais de notificação (telegram, email, slack)
- **review_required:** Se o resultado precisa de aprovação humana

Gerar ID incremental (`auto-NNN`) e adicionar ao registry.json.

### `/automations review`
Mostra itens pendentes na review queue (`.claude/data/automations/review-queue.md`).
Para cada item pendente:
1. Mostrar resumo do resultado
2. Perguntar: **Aprovar**, **Rejeitar**, ou **Investigar**
3. Marcar como processado

### `/automations pause <id>` / `/automations resume <id>`
Alterna o campo `enabled` da automação no registry.

### `/automations remove <id>`
Remove automação do registry (com confirmação Diamond Gate).

## Como Funciona

```
registry.json (definições)
    ↓
n8n "Automations Dispatcher" (a cada 5 min, checa crons)
    ↓
claude -p "{command}" (executa)
    ↓
review-queue.md (se review_required=true)
    ↓
notify.sh (telegram/email/slack)
```

## Exemplos de Automações Úteis

| Nome | Cron | Comando |
|------|------|---------|
| Lead hygiene check | `0 8 * * 1-5` | `/lead-audit --mode quick` |
| PR review backlog | `0 9 * * 1-5` | Verificar PRs sem review via `gh pr list` |
| Skill health check | `0 3 * * 0` | `/skill-health` |
| Aria smoke test | `0 7 * * *` | `/browser testar Aria` |
| Newsletter digest | Já configurado via n8n | Newsletter Summarizer |

## Registry Location
`.claude/data/automations/registry.json`

## Review Queue Location
`.claude/data/automations/review-queue.md`
