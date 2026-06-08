#!/bin/bash
# Session Start Context — Injeta contexto + timezone + sinais recentes
# Chamado pelo hook SessionStart para dar continuidade
# v2: maxProfileItems — injeta top-N sinais high-priority da sessão anterior
# NOTA: Zero dependência de jq — usa sed/grep para parsing

MEMORY_DIR="$HOME/.claude/projects/C--Users-PC-OneDrive-Documents-VS-CODE/memory"
SESSION_LOG="$MEMORY_DIR/session-log.md"
TRACK_FILE="$MEMORY_DIR/.session-files-touched.tmp"
DATA_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/data"
CONFIG_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/scripts/signal-config.json"
SIGNALS_PREV="$DATA_DIR/session-signals-prev.jsonl"
DATE_TODAY=$(date '+%Y-%m-%d')
TIME_NOW=$(date '+%H:%M BRT')
TZ_OFFSET="-03:00"

# Limpa tracking de arquivos da sessão anterior
rm -f "$TRACK_FILE" 2>/dev/null

# Inicializa CLAUDE_PLUGIN_DATA (diretório de dados persistentes por skill)
PLUGIN_DATA_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/data"
bash "${CLAUDE_PROJECT_DIR:-.}/.claude/scripts/init-plugin-data.sh" 2>/dev/null
export CLAUDE_PLUGIN_DATA="$PLUGIN_DATA_DIR"

# Sempre injeta timezone e hora local
CONTEXT="Timezone: America/Sao_Paulo (BRT, UTC-3). Hora local: $TIME_NOW. Data: $DATE_TODAY. REGRA: Sempre converter UTC para BRT (-3h) antes de mostrar horarios ao usuario."

# === maxProfileItems: Injeta top-N sinais high da sessão anterior ===
MAX_ITEMS=5
if [ -f "$CONFIG_FILE" ]; then
    CFG_MAX=$(grep -o '"maxProfileItems"[[:space:]]*:[[:space:]]*[0-9]*' "$CONFIG_FILE" | grep -o '[0-9]*$')
    if [ -n "$CFG_MAX" ] && [ "$CFG_MAX" -gt 0 ] 2>/dev/null; then
        MAX_ITEMS="$CFG_MAX"
    fi
fi

if [ -f "$SIGNALS_PREV" ] && [ -s "$SIGNALS_PREV" ]; then
    # Extrai últimos N sinais high-priority (sem jq — grep/sed)
    HIGH_LINES=$(grep '"priority":"high"' "$SIGNALS_PREV" 2>/dev/null | tail -"$MAX_ITEMS")

    if [ -n "$HIGH_LINES" ]; then
        # Extrai category: file de cada linha
        HIGH_SIGNALS=""
        while IFS= read -r LINE; do
            [ -z "$LINE" ] && continue
            CAT=$(echo "$LINE" | grep -o '"category":"[^"]*"' | sed 's/"category":"//;s/"$//')
            FILE=$(echo "$LINE" | grep -o '"file":"[^"]*"' | sed 's/"file":"//;s/"$//')
            ITEM="$CAT: $FILE"
            if [ -n "$HIGH_SIGNALS" ]; then
                HIGH_SIGNALS="$HIGH_SIGNALS; $ITEM"
            else
                HIGH_SIGNALS="$ITEM"
            fi
        done <<< "$HIGH_LINES"

        if [ -n "$HIGH_SIGNALS" ]; then
            CONTEXT="$CONTEXT Sinais importantes da sessao anterior: $HIGH_SIGNALS."
        fi
    fi

    # Conta total de sinais por prioridade
    TOTAL_HIGH=$(grep -c '"priority":"high"' "$SIGNALS_PREV" 2>/dev/null || echo "0")
    TOTAL_MED=$(grep -c '"priority":"medium"' "$SIGNALS_PREV" 2>/dev/null || echo "0")
    TOTAL_LOW=$(grep -c '"priority":"low"' "$SIGNALS_PREV" 2>/dev/null || echo "0")

    if [ "$TOTAL_HIGH" -gt 0 ] || [ "$TOTAL_MED" -gt 0 ] 2>/dev/null; then
        CONTEXT="$CONTEXT Resumo: ${TOTAL_HIGH} high, ${TOTAL_MED} medium, ${TOTAL_LOW} low."
    fi
elif [ -f "$SESSION_LOG" ]; then
    # Fallback: sem sinais estruturados, informa que log existe
    RECENT=$(tail -5 "$SESSION_LOG" 2>/dev/null)
    if [ -n "$RECENT" ]; then
        CONTEXT="$CONTEXT Sessao anterior disponivel em memory/session-log.md."
    fi
fi

# === Foresight Check: Detecta foresights ativos e próximos do vencimento ===
FORESIGHT_ALERTS=""
FORESIGHT_EXPIRED=""
if [ -d "$MEMORY_DIR" ]; then
    for MEM_FILE in "$MEMORY_DIR"/foresight_*.md; do
        [ -f "$MEM_FILE" ] || continue
        FNAME=$(basename "$MEM_FILE")

        # Extrai "Válido até:" ou "valid_until:" do arquivo
        VALID_UNTIL=$(grep -i -m1 'lido at\|valid.until' "$MEM_FILE" 2>/dev/null | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
        [ -z "$VALID_UNTIL" ] && continue

        # Compara datas (YYYY-MM-DD string comparison works for ISO dates)
        if [[ "$VALID_UNTIL" < "$DATE_TODAY" ]]; then
            FORESIGHT_EXPIRED="${FORESIGHT_EXPIRED}${FORESIGHT_EXPIRED:+, }$FNAME"
        elif [[ "$VALID_UNTIL" < $(date -d "+3 days" '+%Y-%m-%d' 2>/dev/null || date -v+3d '+%Y-%m-%d' 2>/dev/null || echo "9999-99-99") ]]; then
            # Próximo do vencimento (3 dias)
            DESC=$(grep -m1 'description:' "$MEM_FILE" 2>/dev/null | sed 's/description:[[:space:]]*//')
            FORESIGHT_ALERTS="${FORESIGHT_ALERTS}${FORESIGHT_ALERTS:+; }$FNAME($VALID_UNTIL): $DESC"
        fi
    done
fi

if [ -n "$FORESIGHT_EXPIRED" ]; then
    CONTEXT="$CONTEXT FORESIGHTS EXPIRADOS (remover): $FORESIGHT_EXPIRED."
fi
if [ -n "$FORESIGHT_ALERTS" ]; then
    CONTEXT="$CONTEXT FORESIGHTS PROXIMOS: $FORESIGHT_ALERTS."
fi

cat << EOF
{
  "systemMessage": "$CONTEXT"
}
EOF

exit 0
