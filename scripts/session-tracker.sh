#!/bin/bash
# Session Tracker — Captura estado inteligente ao final da sessão
# Chamado pelo hook Stop para registrar o que mudou
# v2: Signal-aware — agrupa por prioridade, dedup, context window
# NOTA: Zero dependência de jq — usa sed/grep para parsing

MEMORY_DIR="$HOME/.claude/projects/C--Users-PC-OneDrive-Documents-VS-CODE/memory"
SESSION_LOG="$MEMORY_DIR/session-log.md"
DATA_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/data"
SIGNALS_FILE="$DATA_DIR/session-signals.jsonl"
CONFIG_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/scripts/signal-config.json"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
DATE_TODAY=$(date '+%Y-%m-%d')

# Captura git status
cd "$(dirname "$0")/../../" 2>/dev/null || cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

MODIFIED=$(git diff --name-only 2>/dev/null | head -20)
STAGED=$(git diff --cached --name-only 2>/dev/null | head -20)
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | head -10)
DIFF_STAT=$(git diff --stat 2>/dev/null | tail -1)

# Se nada mudou E sem sinais, não registra
if [ -z "$MODIFIED" ] && [ -z "$STAGED" ] && [ -z "$UNTRACKED" ] && [ ! -s "$SIGNALS_FILE" ]; then
    exit 0
fi

# === DEDUP: Remove untracked já logados hoje ===
if [ -f "$SESSION_LOG" ] && [ -n "$UNTRACKED" ]; then
    if grep -q "^## $DATE_TODAY" "$SESSION_LOG" 2>/dev/null; then
        ALREADY_LOGGED=$(sed -n "/^## $DATE_TODAY/,/^## [0-9]/p" "$SESSION_LOG" 2>/dev/null | grep "^\*\*Novos:\*\*" | sed 's/\*\*Novos:\*\* //' | tr ',' '\n' | sed 's/^ //;s/ $//')

        if [ -n "$ALREADY_LOGGED" ]; then
            FILTERED_UNTRACKED=""
            while IFS= read -r UFILE; do
                [ -z "$UFILE" ] && continue
                if ! echo "$ALREADY_LOGGED" | grep -qF "$UFILE" 2>/dev/null; then
                    if [ -n "$FILTERED_UNTRACKED" ]; then
                        FILTERED_UNTRACKED="$FILTERED_UNTRACKED
$UFILE"
                    else
                        FILTERED_UNTRACKED="$UFILE"
                    fi
                fi
            done <<< "$UNTRACKED"
            UNTRACKED="$FILTERED_UNTRACKED"
        fi
    fi
fi

# Se após dedup nada resta e sem sinais, sai
if [ -z "$MODIFIED" ] && [ -z "$STAGED" ] && [ -z "$UNTRACKED" ] && [ ! -s "$SIGNALS_FILE" ]; then
    exit 0
fi

# === SIGNAL AGGREGATION ===
SIGNAL_SUMMARY=""
SIGNAL_HIGH=""
CONTEXT_DIFFS=""

if [ -s "$SIGNALS_FILE" ]; then
    # Conta sinais por prioridade (sem jq)
    HIGH_COUNT=$(grep -c '"priority":"high"' "$SIGNALS_FILE" 2>/dev/null || echo "0")
    MEDIUM_COUNT=$(grep -c '"priority":"medium"' "$SIGNALS_FILE" 2>/dev/null || echo "0")
    LOW_COUNT=$(grep -c '"priority":"low"' "$SIGNALS_FILE" 2>/dev/null || echo "0")

    # Monta resumo visual
    PARTS=""
    [ "$HIGH_COUNT" -gt 0 ] 2>/dev/null && PARTS="high($HIGH_COUNT)"
    [ "$MEDIUM_COUNT" -gt 0 ] 2>/dev/null && PARTS="$PARTS${PARTS:+ }medium($MEDIUM_COUNT)"
    [ "$LOW_COUNT" -gt 0 ] 2>/dev/null && PARTS="$PARTS${PARTS:+ }low($LOW_COUNT)"
    SIGNAL_SUMMARY="$PARTS"

    # Lista arquivos high-priority (sem jq — extrai via grep/sed)
    if [ "$HIGH_COUNT" -gt 0 ] 2>/dev/null; then
        SIGNAL_HIGH=$(grep '"priority":"high"' "$SIGNALS_FILE" 2>/dev/null | grep -o '"file":"[^"]*"' | sed 's/"file":"//;s/"$//' | sort -u | tr '\n' ', ' | sed 's/,$//')
    fi

    # === CONTEXT WINDOW: mini-diff para sinais high ===
    CONTEXT_WINDOW=3
    if [ -f "$CONFIG_FILE" ]; then
        CFG_CW=$(grep -o '"contextWindow"[[:space:]]*:[[:space:]]*[0-9]*' "$CONFIG_FILE" | grep -o '[0-9]*$')
        [ -n "$CFG_CW" ] && [ "$CFG_CW" -gt 0 ] 2>/dev/null && CONTEXT_WINDOW="$CFG_CW"
    fi

    if [ "$HIGH_COUNT" -gt 0 ] 2>/dev/null; then
        HIGH_FILES=$(grep '"priority":"high"' "$SIGNALS_FILE" 2>/dev/null | grep -o '"file":"[^"]*"' | sed 's/"file":"//;s/"$//' | sort -u | head -3)
        while IFS= read -r HFILE; do
            [ -z "$HFILE" ] && continue
            MINI_DIFF=$(git diff -- "$HFILE" 2>/dev/null | grep -E '^\+[^+]|^-[^-]' | head -"$CONTEXT_WINDOW")
            if [ -n "$MINI_DIFF" ]; then
                FIRST_LINE=$(echo "$MINI_DIFF" | head -1 | sed 's/^[+-]//')
                CONTEXT_DIFFS="$CONTEXT_DIFFS
  \`$HFILE\`: $FIRST_LINE"
            fi
        done <<< "$HIGH_FILES"
    fi
fi

# === MONTA ENTRADA ===
ENTRY="
### $TIMESTAMP"

if [ -n "$SIGNAL_SUMMARY" ]; then
    ENTRY="$ENTRY
**Sinais:** $SIGNAL_SUMMARY"
fi
if [ -n "$SIGNAL_HIGH" ]; then
    ENTRY="$ENTRY
**High:** $SIGNAL_HIGH"
fi
if [ -n "$DIFF_STAT" ]; then
    ENTRY="$ENTRY
**Stat:** $DIFF_STAT"
fi
if [ -n "$MODIFIED" ]; then
    ENTRY="$ENTRY
**Modificados:** $(echo "$MODIFIED" | tr '\n' ', ' | sed 's/,$//')"
fi
if [ -n "$STAGED" ]; then
    ENTRY="$ENTRY
**Staged:** $(echo "$STAGED" | tr '\n' ', ' | sed 's/,$//')"
fi
if [ -n "$UNTRACKED" ]; then
    ENTRY="$ENTRY
**Novos:** $(echo "$UNTRACKED" | tr '\n' ', ' | sed 's/,$//')"
fi
if [ -n "$CONTEXT_DIFFS" ]; then
    ENTRY="$ENTRY
**Context:**$CONTEXT_DIFFS"
fi

# === SESSION SCORECARD (para /evolve trends) ===
bash "${CLAUDE_PROJECT_DIR:-.}/ouroboros/scripts/session-scorecard.sh" 2>/dev/null

# === SESSION SNAPSHOT (para /resume e /fork) ===
bash "$(dirname "$0")/session-snapshot.sh" 2>/dev/null

# === GRAVA NO SESSION LOG ===
if [ -f "$SESSION_LOG" ] && grep -q "^## $DATE_TODAY" "$SESSION_LOG" 2>/dev/null; then
    echo "$ENTRY" >> "$SESSION_LOG"
else
    if [ ! -f "$SESSION_LOG" ]; then
        echo "---
name: session-log
description: Log automatico de mudancas por sessao — capturado via hook Stop (v2 signal-aware)
type: reference
---

# Session Log (Auto-capturado)

## $DATE_TODAY
$ENTRY" > "$SESSION_LOG"
    else
        echo "
## $DATE_TODAY
$ENTRY" >> "$SESSION_LOG"
    fi
fi

exit 0
