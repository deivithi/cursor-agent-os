#!/bin/bash
# Freeze Hook — Bloqueia operações de escrita no modo freeze
# Pode ser usado como referência — o bloqueio principal é via allowed-tools no comando
# Este script loga tentativas de escrita para auditoria

INPUT=$(cat)

TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Se for Bash, verificar se é write operation
if [ "$TOOL" = "Bash" ] && [ -n "$COMMAND" ]; then
    WRITE_PATTERNS=(
        "git add"
        "git commit"
        "git push"
        "git reset"
        "npm install"
        "npm update"
        "rm "
        "mv "
        "cp "
        "mkdir"
        "touch"
    )

    for PATTERN in "${WRITE_PATTERNS[@]}"; do
        if echo "$COMMAND" | grep -qi "$PATTERN"; then
            DATA_DIR="$CLAUDE_PROJECT_DIR/.claude/data"
            mkdir -p "$DATA_DIR" 2>/dev/null
            TIMESTAMP=$(TZ='America/Sao_Paulo' date '+%Y-%m-%dT%H:%M:%S-03:00' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')
            echo "{\"timestamp\":\"$TIMESTAMP\",\"type\":\"freeze-block\",\"pattern\":\"$PATTERN\",\"command\":\"$COMMAND\"}" >> "$DATA_DIR/freeze-log.jsonl"

            cat << EOF
{
  "decision": "block",
  "reason": "🧊 MODO FREEZE: Operação de escrita bloqueada ('$PATTERN'). Sessão em modo read-only."
}
EOF
            exit 0
        fi
    done
fi

exit 0
