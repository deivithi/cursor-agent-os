# Slack App Setup — @claude Mentions

## Passo a Passo

### 1. Criar Slack App
1. Ir para https://api.slack.com/apps
2. "Create New App" → "From scratch"
3. Nome: "Claude Code Bot"
4. Workspace: selecionar o workspace

### 2. Configurar Permissions
Em "OAuth & Permissions", adicionar scopes:
- `app_mentions:read` — Ler menções @claude
- `chat:write` — Responder em canais
- `channels:history` — Ler histórico (para contexto)

### 3. Configurar Event Subscriptions
Em "Event Subscriptions":
- Enable Events: ON
- Request URL: `<n8n-webhook-url>` (quando disponível)
- Subscribe to events: `app_mention`

### 4. Instalar no Workspace
Em "Install App" → "Install to Workspace"

### 5. Configurar notify-config.json
Copiar o "Incoming Webhook URL" para `.claude/scripts/notify-config.json`:
```json
{
  "slack": {
    "slackWebhook": "https://hooks.slack.com/services/T.../B.../..."
  }
}
```

### 6. Testar
```bash
bash .claude/scripts/notify.sh --channel slack --message "Hello from Claude Code!"
```
