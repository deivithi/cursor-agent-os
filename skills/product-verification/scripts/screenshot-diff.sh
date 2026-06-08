#!/bin/bash
# Screenshot Diff — Comparação visual antes/depois
# Uso: bash screenshot-diff.sh <url> <label>
# Salva screenshots com labels "before" e "after" para comparação manual

set -euo pipefail

URL="${1:?Uso: screenshot-diff.sh <url> <label>}"
LABEL="${2:-snapshot}"
EVIDENCE_DIR="${3:-/tmp/screenshot-diff}"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')

mkdir -p "$EVIDENCE_DIR"

if ! command -v agent-browser &>/dev/null; then
    echo "❌ agent-browser não encontrado. Instale com: npm i -g @anthropic-ai/agent-browser"
    exit 1
fi

# Determinar se é before ou after
BEFORE_FILE="$EVIDENCE_DIR/${LABEL}-before.png"
AFTER_FILE="$EVIDENCE_DIR/${LABEL}-after.png"

if [ ! -f "$BEFORE_FILE" ]; then
    TARGET="$BEFORE_FILE"
    PHASE="BEFORE"
else
    TARGET="$AFTER_FILE"
    PHASE="AFTER"
fi

echo "📸 Capturando screenshot ($PHASE)..."
echo "   URL: $URL"
echo "   Arquivo: $TARGET"

agent-browser open "$URL" --session "diff-$TIMESTAMP" 2>/dev/null
sleep 3
agent-browser screenshot "$TARGET" 2>/dev/null
agent-browser close 2>/dev/null

echo "   ✅ Screenshot salvo: $TARGET"

# Se temos ambos, reportar
if [ -f "$BEFORE_FILE" ] && [ -f "$AFTER_FILE" ]; then
    echo ""
    echo "📊 Comparação pronta!"
    echo "   BEFORE: $BEFORE_FILE"
    echo "   AFTER:  $AFTER_FILE"
    echo "   → Abra ambos lado a lado para comparar visualmente"
    echo "   → Ou use 'diff <(file before) <(file after)' se forem text-based"
fi
