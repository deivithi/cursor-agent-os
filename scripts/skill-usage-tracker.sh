#!/bin/bash
# Skill Usage Tracker — Rastreia qual skill foi ativada e quando
# Chamado pelo hook PreToolUse para Read
# Lê o JSON de stdin e verifica se é leitura de SKILL.md

INPUT=$(cat)

# Extrai file_path do tool_input (sem jq — regex simples)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Só loga se for leitura de SKILL.md (ativação de skill)
case "$FILE_PATH" in
    */SKILL.md)
        ;;
    *)
        exit 0
        ;;
esac

# Extrai nome da skill a partir do path
# Padrão: .../skills/nome-da-skill/SKILL.md
SKILL_NAME=$(echo "$FILE_PATH" | sed -E 's|.*/skills/([^/]+)/SKILL\.md|\1|')

if [ -z "$SKILL_NAME" ] || [ "$SKILL_NAME" = "$FILE_PATH" ]; then
    exit 0
fi

# Determina o ecossistema
case "$FILE_PATH" in
    *cybersecurity-skills*)
        ECOSYSTEM="cybersecurity"
        ;;
    *scientific-skills*)
        ECOSYSTEM="scientific"
        ;;
    *)
        ECOSYSTEM="custom"
        ;;
esac

# Diretório de dados
DATA_DIR="$CLAUDE_PROJECT_DIR/.claude/data"
mkdir -p "$DATA_DIR" 2>/dev/null

LOG_FILE="$DATA_DIR/skill-usage-log.jsonl"

# Timestamp em BRT
TIMESTAMP=$(TZ='America/Sao_Paulo' date '+%Y-%m-%dT%H:%M:%S-03:00' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')

# Append ao log (formato JSONL)
echo "{\"timestamp\":\"$TIMESTAMP\",\"skill\":\"$SKILL_NAME\",\"ecosystem\":\"$ECOSYSTEM\",\"file\":\"$FILE_PATH\"}" >> "$LOG_FILE"

exit 0
