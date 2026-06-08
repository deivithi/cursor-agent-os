#!/bin/bash
# Sanitize Leads — Pipeline de sanitização de dados de leads
# Uso: bash sanitize-leads.sh [input.csv] [output.csv]
# Espera CSV com colunas: Id,Name,Email,Phone,LeadSource,Status

set -euo pipefail

INPUT="${1:?Uso: sanitize-leads.sh <input.csv> [output.csv]}"
OUTPUT="${2:-sanitized-$(date '+%Y%m%d').csv}"

if [ ! -f "$INPUT" ]; then
    echo "❌ Arquivo não encontrado: $INPUT"
    exit 1
fi

echo "🧹 Sanitização de leads iniciando..."
echo "   Input: $INPUT"
echo "   Output: $OUTPUT"

TOTAL=$(wc -l < "$INPUT")
echo "   Total de linhas: $TOTAL"
echo "---"

# Contadores
EMPTY_EMAIL=0
EMPTY_PHONE=0
EMPTY_SOURCE=0
FIXED=0

# Processar CSV (pula header)
HEAD=$(head -1 "$INPUT")
echo "$HEAD" > "$OUTPUT"

tail -n +2 "$INPUT" | while IFS=',' read -r ID NAME EMAIL PHONE SOURCE STATUS REST; do
    ISSUES=""

    # Email: lowercase, trim
    CLEAN_EMAIL=$(echo "$EMAIL" | tr '[:upper:]' '[:lower:]' | xargs 2>/dev/null || echo "$EMAIL")
    if [ -z "$CLEAN_EMAIL" ] || [ "$CLEAN_EMAIL" = "null" ]; then
        ISSUES="${ISSUES}[no-email]"
        EMPTY_EMAIL=$((EMPTY_EMAIL + 1))
    fi

    # Phone: remover caracteres não numéricos exceto + e -
    CLEAN_PHONE=$(echo "$PHONE" | sed 's/[^0-9+()-]//g' 2>/dev/null || echo "$PHONE")
    if [ -z "$CLEAN_PHONE" ] || [ "$CLEAN_PHONE" = "null" ]; then
        ISSUES="${ISSUES}[no-phone]"
        EMPTY_PHONE=$((EMPTY_PHONE + 1))
    fi

    # Lead Source
    if [ -z "$SOURCE" ] || [ "$SOURCE" = "null" ]; then
        ISSUES="${ISSUES}[no-source]"
        EMPTY_SOURCE=$((EMPTY_SOURCE + 1))
    fi

    # Output
    echo "$ID,$NAME,$CLEAN_EMAIL,$CLEAN_PHONE,$SOURCE,$STATUS" >> "$OUTPUT"

    if [ -n "$ISSUES" ]; then
        FIXED=$((FIXED + 1))
    fi
done

echo ""
echo "📊 Resultado da Sanitização"
echo "   Total processados: $((TOTAL - 1))"
echo "   Sem email: $EMPTY_EMAIL"
echo "   Sem telefone: $EMPTY_PHONE"
echo "   Sem LeadSource: $EMPTY_SOURCE"
echo "   Com issues: $FIXED"
echo "   Output: $OUTPUT"
