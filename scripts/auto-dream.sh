#!/usr/bin/env bash
# Auto-Dream — Consolidação Periódica de Memória
# Inspirado em Boris Cherny: "Auto-dream roda subagente revisando sessões passadas,
# mantendo o que importa, removendo o que não importa — inspirado em sono REM."
#
# Uso: bash auto-dream.sh [--dry-run]
#   --dry-run: mostra o que seria feito sem executar
#
# Agendar via Task Scheduler (Windows) ou /schedule:
#   Diário às 23:00 BRT ou semanal aos domingos

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$HOME/OneDrive/Documents/VS CODE}"
MEMORY_DIR="$HOME/.claude/projects/C--Users-PC-OneDrive-Documents-VS-CODE/memory"
SESSION_LOG="$MEMORY_DIR/session-log.md"
DREAM_LOG="$MEMORY_DIR/dream-log.md"
DRY_RUN="${1:-}"

echo "🌙 Auto-Dream starting at $(date '+%Y-%m-%d %H:%M BRT')"
echo "=================================================="

# 1. Check for expired foresights
echo ""
echo "🔮 Checking expired foresights..."
TODAY=$(date '+%Y-%m-%d')
FORESIGHT_COUNT=0

for f in "$MEMORY_DIR"/foresight_*.md; do
  [ -f "$f" ] || continue
  # Extract "Válido até" date
  VALID_UNTIL=$(grep -i "válido até" "$f" 2>/dev/null | grep -oP '\d{4}-\d{2}-\d{2}' | head -1)
  if [ -n "$VALID_UNTIL" ] && [[ "$TODAY" > "$VALID_UNTIL" ]]; then
    FORESIGHT_COUNT=$((FORESIGHT_COUNT + 1))
    echo "  ⏰ EXPIRED: $(basename "$f") (válido até: $VALID_UNTIL)"
    if [ "$DRY_RUN" != "--dry-run" ]; then
      rm "$f"
      echo "    🗑️ Removed"
      # Remove from MEMORY.md index
      FNAME=$(basename "$f")
      sed -i "/$FNAME/d" "$MEMORY_DIR/MEMORY.md" 2>/dev/null || true
    fi
  fi
done
echo "  📊 Foresights expirados: $FORESIGHT_COUNT"

# 2. Check memory file count and size
echo ""
echo "📊 Memory stats:"
TOTAL_FILES=$(find "$MEMORY_DIR" -name "*.md" -not -name "MEMORY.md" -not -name "dream-log.md" -not -name "session-log.md" | wc -l)
TOTAL_SIZE=$(du -sh "$MEMORY_DIR" 2>/dev/null | cut -f1)
MEMORY_INDEX_LINES=$(wc -l < "$MEMORY_DIR/MEMORY.md" 2>/dev/null || echo 0)
echo "  📁 Total memory files: $TOTAL_FILES"
echo "  💾 Total size: $TOTAL_SIZE"
echo "  📋 MEMORY.md lines: $MEMORY_INDEX_LINES (max recommended: 200)"

if [ "$MEMORY_INDEX_LINES" -gt 200 ]; then
  echo "  ⚠️ WARNING: MEMORY.md exceeds 200 lines — consider pruning"
fi

# 3. Check for orphaned memory files (in dir but not in MEMORY.md)
echo ""
echo "🔍 Checking for orphans..."
ORPHAN_COUNT=0
for f in "$MEMORY_DIR"/*.md; do
  [ -f "$f" ] || continue
  FNAME=$(basename "$f")
  [ "$FNAME" = "MEMORY.md" ] || [ "$FNAME" = "dream-log.md" ] || [ "$FNAME" = "session-log.md" ] && continue
  if ! grep -q "$FNAME" "$MEMORY_DIR/MEMORY.md" 2>/dev/null; then
    ORPHAN_COUNT=$((ORPHAN_COUNT + 1))
    echo "  👻 Orphan: $FNAME (not indexed in MEMORY.md)"
  fi
done
echo "  📊 Orphaned files: $ORPHAN_COUNT"

# 4. Check session-log freshness
echo ""
echo "📝 Session log:"
if [ -f "$SESSION_LOG" ]; then
  LOG_LINES=$(wc -l < "$SESSION_LOG")
  LOG_SIZE=$(du -sh "$SESSION_LOG" | cut -f1)
  echo "  📏 Lines: $LOG_LINES | Size: $LOG_SIZE"
  if [ "$LOG_LINES" -gt 500 ]; then
    echo "  ⚠️ Session log is large — consider running /recap to consolidate"
  fi
else
  echo "  (no session log found)"
fi

# 5. Write dream log
echo ""
echo "📝 Writing dream log..."
cat >> "$DREAM_LOG" << EOF

---
## 🌙 Dream $(date '+%Y-%m-%d %H:%M BRT')
- Memory files: $TOTAL_FILES | Size: $TOTAL_SIZE
- MEMORY.md lines: $MEMORY_INDEX_LINES
- Foresights expired & removed: $FORESIGHT_COUNT
- Orphaned files: $ORPHAN_COUNT
- Mode: ${DRY_RUN:-live}
EOF

echo ""
echo "✅ Auto-Dream complete!"
echo "💡 For deep consolidation, run: claude -p 'Review my memory files and consolidate duplicates, remove stale entries, update outdated info.'"
