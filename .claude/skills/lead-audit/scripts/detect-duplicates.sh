#!/bin/bash
# Detect Duplicates — Identifica leads duplicados por email
# Uso: bash detect-duplicates.sh [input.csv]
# Espera CSV com colunas que incluem Email

set -euo pipefail

INPUT="${1:?Uso: detect-duplicates.sh <input.csv>}"
OUTPUT="duplicates-$(date '+%Y%m%d').csv"

if [ ! -f "$INPUT" ]; then
    echo "❌ Arquivo não encontrado: $INPUT"
    exit 1
fi

echo "🔍 Detecção de duplicados iniciando..."
echo "   Input: $INPUT"
echo "---"

# Encontrar coluna de email (assume header na primeira linha)
HEADER=$(head -1 "$INPUT")
EMAIL_COL=$(echo "$HEADER" | tr ',' '\n' | grep -ni "email" | head -1 | cut -d: -f1)

if [ -z "$EMAIL_COL" ]; then
    echo "❌ Coluna 'Email' não encontrada no header"
    echo "   Header: $HEADER"
    exit 1
fi

echo "   Coluna Email: #$EMAIL_COL"

# Extrair emails, normalizar, contar duplicados
TOTAL=$(tail -n +2 "$INPUT" | wc -l)

# Emails duplicados (aparecem mais de 1 vez)
DUPES=$(tail -n +2 "$INPUT" | cut -d',' -f"$EMAIL_COL" | tr '[:upper:]' '[:lower:]' | xargs -I{} echo {} | sort | uniq -cd | sort -rn)

DUPE_COUNT=$(echo "$DUPES" | grep -c '[^ ]' 2>/dev/null || echo 0)

if [ "$DUPE_COUNT" -gt 0 ]; then
    DUPE_LEADS=$(echo "$DUPES" | awk '{sum+=$1} END{print sum}')
    DUPE_PCT=$(echo "scale=1; $DUPE_LEADS * 100 / $TOTAL" | bc 2>/dev/null || echo "N/A")

    echo ""
    echo "📊 Resultado"
    echo "   Total de leads: $TOTAL"
    echo "   Emails únicos duplicados: $DUPE_COUNT"
    echo "   Leads afetados: $DUPE_LEADS ($DUPE_PCT%)"
    echo ""
    echo "   Top 10 mais duplicados:"
    echo "$DUPES" | head -10 | while read COUNT EMAIL; do
        echo "   $COUNT × $EMAIL"
    done

    # Exportar lista completa
    echo "email,count" > "$OUTPUT"
    echo "$DUPES" | awk '{print $2","$1}' >> "$OUTPUT"
    echo ""
    echo "   Lista completa: $OUTPUT"

    # Avaliar severidade
    if [ "$DUPE_PCT" != "N/A" ]; then
        PCT_INT=$(echo "$DUPE_PCT" | cut -d. -f1)
        if [ "$PCT_INT" -gt 10 ]; then
            echo "   ⚠️  ALERTA: Taxa > 10% — investigar fonte imediatamente!"
        elif [ "$PCT_INT" -gt 5 ]; then
            echo "   🟡 ATENÇÃO: Taxa > 5% — revisar form e integração"
        else
            echo "   ✅ Taxa aceitável (< 5%)"
        fi
    fi
else
    echo ""
    echo "✅ Nenhum duplicado encontrado em $TOTAL leads"
fi
