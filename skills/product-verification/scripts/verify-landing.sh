#!/bin/bash
# Verify Landing Page — Teste da landing page de eventos Febracis
# Uso: bash verify-landing.sh [url]

set -euo pipefail

URL="${1:-https://example.netlify.app}"
EVIDENCE_DIR="${2:-/tmp/landing-verification}"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')

mkdir -p "$EVIDENCE_DIR"

echo "🧪 Iniciando verificação da Landing Page..."
echo "   URL: $URL"
echo "---"

# Step 1: HTTP Check
echo "📡 Step 1: Acessibilidade..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ HTTP $HTTP_CODE"
else
    echo "   ❌ HTTP $HTTP_CODE — Landing inacessível!"
    exit 1
fi

# Step 2: Verificar elementos críticos no HTML
echo "🔍 Step 2: Elementos críticos..."
PAGE_HTML=$(curl -s "$URL" 2>/dev/null)

# Verificar form
if echo "$PAGE_HTML" | grep -qi "<form"; then
    echo "   ✅ Formulário de captação encontrado"
else
    echo "   ❌ Formulário NÃO encontrado!"
fi

# Verificar campos obrigatórios
for FIELD in "name\|nome" "email" "phone\|telefone\|whatsapp"; do
    if echo "$PAGE_HTML" | grep -qi "$FIELD"; then
        echo "   ✅ Campo '$FIELD' presente"
    else
        echo "   ⚠️  Campo '$FIELD' pode estar ausente"
    fi
done

# Step 3: Responsividade (se agent-browser disponível)
if command -v agent-browser &>/dev/null; then
    echo "📱 Step 3: Screenshot para verificação visual..."
    agent-browser open "$URL" --session "verify-landing-$TIMESTAMP" 2>/dev/null
    sleep 2
    agent-browser screenshot "$EVIDENCE_DIR/landing-$TIMESTAMP.png" 2>/dev/null
    agent-browser close 2>/dev/null
    echo "   ✅ Screenshot salvo"
fi

# Relatório
echo "---"
echo "📋 Relatório: Landing Page"
echo "   Data: $(TZ='America/Sao_Paulo' date '+%d/%m/%Y %H:%M BRT')"
echo "   HTTP: $HTTP_CODE"
echo "   Status: $([ "$HTTP_CODE" = "200" ] && echo '✅ PASS' || echo '❌ FAIL')"
