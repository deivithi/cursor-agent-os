#!/bin/bash
# Run Diagnostic — Coleta diagnóstico genérico do ambiente
# Uso: bash run-diagnostic.sh [projeto]
# Projetos: aria, landing, all (default)

set -euo pipefail

PROJECT="${1:-all}"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
REPORT_DIR="/tmp/diagnostic-$TIMESTAMP"

mkdir -p "$REPORT_DIR"

echo "🔍 Diagnóstico iniciado — $(TZ='America/Sao_Paulo' date '+%d/%m/%Y %H:%M BRT')"
echo "   Projeto: $PROJECT"
echo "   Relatório: $REPORT_DIR/"
echo "==="

# 1. Ambiente local
echo ""
echo "📦 1. Ambiente Local"
echo "   Node: $(node --version 2>/dev/null || echo 'N/A')"
echo "   npm: $(npm --version 2>/dev/null || echo 'N/A')"
echo "   Git branch: $(git branch --show-current 2>/dev/null || echo 'N/A')"
echo "   Git status: $(git status --porcelain 2>/dev/null | wc -l) arquivos modificados"

# 2. Conectividade
echo ""
echo "🌐 2. Conectividade"
for SERVICE in "api.vercel.com" "supabase.co" "api.github.com"; do
    HTTP=$(curl -s -o /dev/null -w "%{http_code}" "https://$SERVICE" 2>/dev/null || echo "000")
    STATUS=$([ "$HTTP" = "200" ] || [ "$HTTP" = "301" ] || [ "$HTTP" = "302" ] && echo "✅" || echo "❌")
    echo "   $STATUS $SERVICE (HTTP $HTTP)"
done

# 3. Projeto específico
if [ "$PROJECT" = "aria" ] || [ "$PROJECT" = "all" ]; then
    echo ""
    echo "🤖 3. Aria"
    if [ -d "Aria" ]; then
        echo "   Diretório: ✅ encontrado"
        echo "   package.json: $([ -f 'Aria/package.json' ] && echo '✅' || echo '❌')"
        echo "   node_modules: $([ -d 'Aria/node_modules' ] && echo '✅' || echo '❌ (npm install necessário)')"

        # Vercel deploy status
        if command -v vercel &>/dev/null || command -v npx &>/dev/null; then
            echo "   Último deploy Vercel:"
            (cd Aria && npx vercel ls 2>/dev/null | head -5) || echo "   ⚠️  Não foi possível checar Vercel"
        fi
    else
        echo "   Diretório: ❌ não encontrado"
    fi
fi

if [ "$PROJECT" = "landing" ] || [ "$PROJECT" = "all" ]; then
    echo ""
    echo "🎯 4. Landing Page"
    if [ -d "ai-powered-landing" ]; then
        echo "   Diretório: ✅ encontrado"
    else
        echo "   Diretório: ❌ não encontrado"
    fi
fi

# 4. Disk e Memory
echo ""
echo "💾 5. Recursos"
echo "   Disco: $(df -h . 2>/dev/null | tail -1 | awk '{print $4}' || echo 'N/A') livre"

echo ""
echo "=== Diagnóstico concluído ==="
echo "📁 Relatório salvo em: $REPORT_DIR/"
