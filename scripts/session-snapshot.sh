#!/bin/bash
# Session Snapshot — Salva snapshot estruturado para resume/fork
# Chamado pelo session-tracker.sh ao final da sessão

SESSIONS_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/data/sessions"
MEMORY_DIR="$HOME/.claude/projects/C--Users-PC-OneDrive-Documents-VS-CODE/memory"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M')
SNAPSHOT_FILE="$SESSIONS_DIR/session-$TIMESTAMP.json"

mkdir -p "$SESSIONS_DIR"
cd "$(dirname "$0")/../../" 2>/dev/null || cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

# Coleta dados
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
MODIFIED=$(git diff --name-only 2>/dev/null | head -20 | tr '\n' ',' | sed 's/,$//')
STAGED=$(git diff --cached --name-only 2>/dev/null | head -20 | tr '\n' ',' | sed 's/,$//')
DIFF_STAT=$(git diff --stat 2>/dev/null | tail -1 | sed 's/"/\\"/g')
LAST_COMMITS=$(git log --oneline -5 2>/dev/null | sed 's/"/\\"/g' | tr '\n' '|' | sed 's/|$//')

# Tarefas pendentes (se existir todo.md)
OPEN_ITEMS=""
if [ -f "tasks/todo.md" ]; then
    OPEN_ITEMS=$(grep -c '^\- \[ \]' "tasks/todo.md" 2>/dev/null || echo "0")
fi

# Monta JSON (sem jq)
cat > "$SNAPSHOT_FILE" << EOJSON
{
  "timestamp": "$TIMESTAMP",
  "branch": "$BRANCH",
  "commit": "$HASH",
  "modified": "$MODIFIED",
  "staged": "$STAGED",
  "diff_stat": "$DIFF_STAT",
  "recent_commits": "$LAST_COMMITS",
  "open_items": "$OPEN_ITEMS",
  "resumable": true
}
EOJSON

# Limpa snapshots antigos (mantém últimos 20)
ls -t "$SESSIONS_DIR"/session-*.json 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null

echo "$SNAPSHOT_FILE"
