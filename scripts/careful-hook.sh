#!/bin/bash
# Careful Hook — Intercepta operações destrutivas no modo cauteloso
# Chamado pelo hook PostToolUse para Bash quando /careful está ativo
# Lê o JSON de stdin e verifica se o comando executado é destrutivo

INPUT=$(cat)

# Extrai o comando do tool_input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
    exit 0
fi

# Patterns destrutivos a bloquear
DANGEROUS_PATTERNS=(
    "rm -rf"
    "rm -r "
    "rmdir"
    "git reset --hard"
    "git push --force"
    "git push -f"
    "git clean -f"
    "git checkout \."
    "DROP TABLE"
    "DROP DATABASE"
    "TRUNCATE"
    "DELETE FROM"
    "kubectl delete"
    "kubectl drain"
    "supabase db reset"
)

# Verificar se o comando contém algum pattern perigoso
for PATTERN in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qi "$PATTERN"; then
        # Logar o alerta
        DATA_DIR="$CLAUDE_PROJECT_DIR/.claude/data"
        mkdir -p "$DATA_DIR" 2>/dev/null
        TIMESTAMP=$(TZ='America/Sao_Paulo' date '+%Y-%m-%dT%H:%M:%S-03:00' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')
        echo "{\"timestamp\":\"$TIMESTAMP\",\"type\":\"careful-alert\",\"pattern\":\"$PATTERN\",\"command\":\"$COMMAND\"}" >> "$DATA_DIR/careful-log.jsonl"

        # Emitir aviso (stdout é capturado pelo hook system)
        cat << EOF
{
  "decision": "block",
  "reason": "🛡️ MODO CAUTELOSO: Operação destrutiva detectada ('$PATTERN'). Confirme com o usuário antes de executar."
}
EOF
        exit 0
    fi
done

# Comando seguro — permitir
exit 0
