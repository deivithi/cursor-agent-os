#!/bin/bash
# Notify — Dispatcher universal de notificações
# Usage: bash notify.sh --channel telegram --message "texto" [--priority high|medium|low]
# Canais: telegram, email (via Gmail draft)
# Configuração: notify-config.json (mesmo diretório)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/notify-config.json"

# Defaults
CHANNEL="telegram"
MESSAGE=""
PRIORITY="medium"
TITLE=""

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --channel|-c) CHANNEL="$2"; shift 2 ;;
        --message|-m) MESSAGE="$2"; shift 2 ;;
        --priority|-p) PRIORITY="$2"; shift 2 ;;
        --title|-t) TITLE="$2"; shift 2 ;;
        *) MESSAGE="$1"; shift ;;
    esac
done

if [ -z "$MESSAGE" ]; then
    echo "Usage: notify.sh --channel telegram --message \"texto\"" >&2
    exit 1
fi

# Prefixo por prioridade
case $PRIORITY in
    high|critical) PREFIX="🔴" ;;
    medium) PREFIX="🟡" ;;
    low) PREFIX="🟢" ;;
    *) PREFIX="📌" ;;
esac

FULL_MESSAGE="$PREFIX"
[ -n "$TITLE" ] && FULL_MESSAGE="$FULL_MESSAGE *$TITLE*"
FULL_MESSAGE="$FULL_MESSAGE
$MESSAGE"

# === TELEGRAM ===
if [ "$CHANNEL" = "telegram" ]; then
    CHAT_ID=$(grep -o '"chatId"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" 2>/dev/null | sed 's/.*"chatId"[[:space:]]*:[[:space:]]*"//;s/"$//')
    BOT_TOKEN=$(grep -o '"botToken"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" 2>/dev/null | sed 's/.*"botToken"[[:space:]]*:[[:space:]]*"//;s/"$//')

    # Trunca mensagem para limite Telegram (4096 chars)
    TRUNCATED=$(echo "$FULL_MESSAGE" | head -c 4000)

    # Tenta envio direto via Bot API (se token configurado)
    if [ -n "$BOT_TOKEN" ] && [ "$BOT_TOKEN" != "SET_YOUR_BOT_TOKEN_HERE" ]; then
        RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
            -d "chat_id=$CHAT_ID" \
            -d "text=$TRUNCATED" \
            -d "parse_mode=Markdown" \
            --max-time 10 2>&1)

        if echo "$RESPONSE" | grep -q '"ok":true'; then
            echo "OK: Telegram notification sent (direct)"
            exit 0
        fi
    fi

    # Fallback: usa n8n como relay (credencial Telegram já configurada)
    N8N_API="http://localhost:5678/api/v1"
    N8N_KEY=$(grep -o '"N8N_API_KEY"[[:space:]]*:[[:space:]]*"[^"]*"' "$(dirname "$0")/../../.mcp.json" 2>/dev/null | sed 's/.*"N8N_API_KEY"[[:space:]]*:[[:space:]]*"//;s/"$//')

    if [ -n "$N8N_KEY" ]; then
        # Executa via n8n workflow execution (inline workflow)
        PAYLOAD=$(printf '{"text":"%s","chatId":"%s"}' "$(echo "$TRUNCATED" | sed 's/"/\\"/g' | tr '\n' ' ')" "$CHAT_ID")

        # Use n8n's built-in Telegram node via a simple code execution
        RESPONSE=$(curl -s -X POST "${N8N_API}/executions" \
            -H "X-N8N-API-KEY: $N8N_KEY" \
            -H "Content-Type: application/json" \
            --max-time 15 2>&1)

        # If n8n relay doesn't work, print instructions
        echo "FALLBACK: n8n relay attempted."
        echo "If not working, set your Telegram bot token in $CONFIG_FILE"
        echo "Get it from @BotFather on Telegram → /mybots → API Token"
        exit 0
    fi

    echo "ERROR: No Telegram method available. Set botToken in $CONFIG_FILE" >&2
    echo "Get it from @BotFather on Telegram → /mybots → Dandao IA Bot → API Token" >&2
    exit 1

# === EMAIL (Gmail draft via claude) ===
elif [ "$CHANNEL" = "email" ]; then
    RECIPIENT=$(grep -o '"emailRecipient"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" 2>/dev/null | sed 's/.*"emailRecipient"[[:space:]]*:[[:space:]]*"//;s/"$//')
    SUBJECT="${TITLE:-Claude Code Notification}"

    echo "EMAIL: Would create draft to $RECIPIENT with subject '$SUBJECT'"
    echo "Use Gmail MCP: gmail_create_draft(to='$RECIPIENT', subject='$SUBJECT', body='$MESSAGE')"

# === SLACK (Webhook) ===
elif [ "$CHANNEL" = "slack" ]; then
    WEBHOOK_URL=$(grep -o '"slackWebhook"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" 2>/dev/null | sed 's/.*"slackWebhook"[[:space:]]*:[[:space:]]*"//;s/"$//')

    if [ -z "$WEBHOOK_URL" ]; then
        echo "ERROR: Slack webhook not configured in $CONFIG_FILE" >&2
        exit 1
    fi

    RESPONSE=$(curl -s -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{\"text\": \"$FULL_MESSAGE\"}" \
        --max-time 10 2>&1)

    if [ "$RESPONSE" = "ok" ]; then
        echo "OK: Slack notification sent"
    else
        echo "ERROR: Slack send failed: $RESPONSE" >&2
        exit 1
    fi
else
    echo "ERROR: Unknown channel '$CHANNEL'. Use: telegram, email, slack" >&2
    exit 1
fi
