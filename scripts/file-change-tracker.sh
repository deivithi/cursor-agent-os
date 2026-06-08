#!/bin/bash
# File Change Tracker — Registra edições/escritas + classificação por sinal
# Chamado pelo hook PostToolUse para Edit e Write
# v2: Signal Extraction — classifica mudanças por categoria/prioridade
# NOTA: Zero dependência de jq — usa sed/grep para parsing

INPUT=$(cat)

# Extrai file_path do tool_input (sem jq — regex simples)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# === TRACKING ORIGINAL (retrocompatível) ===
TRACK_FILE="$HOME/.claude/projects/C--Users-PC-OneDrive-Documents-VS-CODE/memory/.session-files-touched.tmp"

if [ ! -f "$TRACK_FILE" ] || ! grep -qF "$FILE_PATH" "$TRACK_FILE" 2>/dev/null; then
    echo "$(date '+%H:%M') | $FILE_PATH" >> "$TRACK_FILE"
fi

# === SIGNAL EXTRACTION (novo) ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/signal-config.json"
DATA_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/data"
SIGNALS_FILE="$DATA_DIR/session-signals.jsonl"

# Se config não existe, sai silenciosamente
if [ ! -f "$CONFIG_FILE" ]; then
    exit 0
fi

# Verifica se signal extraction está ativo (sem jq)
ENABLED=$(grep -o '"signalExtraction"[[:space:]]*:[[:space:]]*[a-z]*' "$CONFIG_FILE" | grep -o 'true\|false')
if [ "$ENABLED" != "true" ]; then
    exit 0
fi

# Normaliza path: remove prefixo absoluto para comparação com patterns
# Converte C:/Users/.../VS CODE/Aria/foo.ts → Aria/foo.ts
# Ou /c/Users/.../VS CODE/Aria/foo.ts → Aria/foo.ts
# Ou C:/Users/PC/.claude/projects/.../memory/x.md → memory/x.md
REL_PATH=$(echo "$FILE_PATH" | sed -E 's|\\|/|g; s|^.*VS CODE/||; s|^.*VS%20CODE/||; s|^.*/memory/|memory/|')

# Classifica por categoria/prioridade
CATEGORY="uncategorized"
PRIORITY="low"

# Matching direto por prefixo/sufixo — rápido e sem jq
# Ordem: high primeiro, depois medium, depois low (first match wins)
case "$REL_PATH" in
    memory/*.md|memory/*)
        CATEGORY="memory"; PRIORITY="high" ;;
    CLAUDE.md|AGENTS.md)
        CATEGORY="config"; PRIORITY="high" ;;
    .claude/settings*.json|.claude/scripts/*)
        CATEGORY="config"; PRIORITY="high" ;;
    .claude/skills/*/SKILL.md|.claude/commands/*.md|.claude/skills/*)
        CATEGORY="skill"; PRIORITY="medium" ;;
    Aria/*|ai-powered-landing/*|ouroboros/*)
        CATEGORY="project"; PRIORITY="medium" ;;
    automacoes/*|scripts/*|.mcp.json)
        CATEGORY="automation"; PRIORITY="low" ;;
esac

# Garante diretório existe
mkdir -p "$DATA_DIR" 2>/dev/null

# Timestamp em BRT
TIMESTAMP=$(TZ='America/Sao_Paulo' date '+%Y-%m-%dT%H:%M:%S-03:00' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')

# Grava sinal (JSONL append-only)
echo "{\"ts\":\"$TIMESTAMP\",\"file\":\"$REL_PATH\",\"category\":\"$CATEGORY\",\"priority\":\"$PRIORITY\"}" >> "$SIGNALS_FILE"

exit 0
