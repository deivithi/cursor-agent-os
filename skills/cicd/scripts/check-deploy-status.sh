#!/bin/bash
# Check Deploy Status — Verifica status do último deploy
# Uso: bash check-deploy-status.sh [vercel|supabase|all]

set -euo pipefail

PLATFORM="${1:-all}"

echo "📊 Status de Deploy — $(TZ='America/Sao_Paulo' date '+%d/%m/%Y %H:%M BRT')"
echo "==="

# Vercel
if [ "$PLATFORM" = "vercel" ] || [ "$PLATFORM" = "all" ]; then
    echo ""
    echo "▲ Vercel"
    if command -v npx &>/dev/null; then
        echo "   Últimos deploys:"
        (cd Aria 2>/dev/null && npx vercel ls 2>&1 | head -8) || echo "   ⚠️  Não foi possível checar"
    else
        echo "   ❌ npx não disponível"
    fi
fi

# Supabase
if [ "$PLATFORM" = "supabase" ] || [ "$PLATFORM" = "all" ]; then
    echo ""
    echo "🗄️  Supabase"
    if command -v supabase &>/dev/null; then
        echo "   Migrations:"
        supabase migration list 2>&1 | tail -5 || echo "   ⚠️  Não foi possível checar"

        echo ""
        echo "   Edge Functions:"
        supabase functions list 2>&1 | tail -5 || echo "   ⚠️  Não foi possível checar"
    else
        echo "   ❌ supabase CLI não disponível"
    fi
fi

# Health Checks
if [ "$PLATFORM" = "all" ]; then
    echo ""
    echo "🏥 Health Checks"

    for URL in "https://aria-ai-phi.vercel.app"; do
        HTTP=$(curl -s -o /dev/null -w "%{http_code}" "$URL" 2>/dev/null || echo "000")
        STATUS=$([ "$HTTP" = "200" ] && echo "✅" || echo "❌")
        echo "   $STATUS $URL (HTTP $HTTP)"
    done
fi

echo ""
echo "=== Verificação concluída ==="
