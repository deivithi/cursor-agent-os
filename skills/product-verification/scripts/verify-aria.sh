#!/bin/bash
# Verify Aria — Smoke test completo do Aria SaaS
# Uso: bash verify-aria.sh [url]
# Default URL: https://aria-ai-phi.vercel.app

set -euo pipefail

URL="${1:-https://aria-ai-phi.vercel.app}"
EVIDENCE_DIR="${2:-/tmp/aria-verification}"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')

mkdir -p "$EVIDENCE_DIR"

echo "🧪 Iniciando verificação do Aria..."
echo "   URL: $URL"
echo "   Evidências: $EVIDENCE_DIR"
echo "---"

# Step 1: Health Check (API)
echo "📡 Step 1: Health Check API..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ HTTP $HTTP_CODE — Site acessível"
else
    echo "   ❌ HTTP $HTTP_CODE — Site inacessível!"
    echo "   ⚠️  Verificar Vercel dashboard ou usar runbook skill"
    exit 1
fi

# Step 2: Browser Test (se agent-browser disponível)
if command -v agent-browser &>/dev/null; then
    echo "🌐 Step 2: Browser test com agent-browser..."

    agent-browser open "$URL" --session "verify-aria-$TIMESTAMP" 2>/dev/null
    sleep 3

    # Capturar snapshot interativo
    agent-browser snapshot -i 2>/dev/null > "$EVIDENCE_DIR/snapshot-$TIMESTAMP.txt"

    # Screenshot como evidência
    agent-browser screenshot "$EVIDENCE_DIR/aria-$TIMESTAMP.png" 2>/dev/null

    echo "   ✅ Screenshot salvo: $EVIDENCE_DIR/aria-$TIMESTAMP.png"

    # Fechar sessão
    agent-browser close 2>/dev/null
else
    echo "⚠️  Step 2: agent-browser não encontrado — pulando browser test"
fi

# Step 3: Relatório
echo "---"
echo "📋 Relatório de Verificação"
echo "   Produto: Aria"
echo "   URL: $URL"
echo "   Data: $(TZ='America/Sao_Paulo' date '+%d/%m/%Y %H:%M BRT')"
echo "   HTTP: $HTTP_CODE"
echo "   Evidências: $EVIDENCE_DIR/"
echo "   Status: $([ "$HTTP_CODE" = "200" ] && echo '✅ PASS' || echo '❌ FAIL')"
