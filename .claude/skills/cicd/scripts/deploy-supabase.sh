#!/bin/bash
# Deploy Supabase — Migrations + Edge Functions
# Uso: bash deploy-supabase.sh [migrations|functions|all]

set -euo pipefail

ACTION="${1:-all}"

echo "🗄️  Deploy Supabase..."
echo "   Ação: $ACTION"
echo "==="

# Check: supabase CLI
if ! command -v supabase &>/dev/null; then
    echo "❌ supabase CLI não encontrado"
    echo "   Instale: npm i -g supabase"
    exit 1
fi

# Migrations
if [ "$ACTION" = "migrations" ] || [ "$ACTION" = "all" ]; then
    echo ""
    echo "📄 Aplicando migrations..."

    # Listar pendentes
    echo "   Migrations pendentes:"
    supabase migration list 2>&1 | grep -i "pending\|not applied" || echo "   Nenhuma pendente"

    # ◆ Diamond Gate para produção
    echo ""
    echo "   ◆ DIAMOND GATE: Migrations alteram o schema do banco."
    echo "   Confirme que deseja aplicar."

    supabase db push 2>&1
    echo "   ✅ Migrations aplicadas"
fi

# Edge Functions
if [ "$ACTION" = "functions" ] || [ "$ACTION" = "all" ]; then
    echo ""
    echo "⚡ Deployando edge functions..."

    FUNCTIONS_DIR="./supabase/functions"
    if [ -d "$FUNCTIONS_DIR" ]; then
        for FUNC_DIR in "$FUNCTIONS_DIR"/*/; do
            FUNC_NAME=$(basename "$FUNC_DIR")
            echo "   → $FUNC_NAME..."
            supabase functions deploy "$FUNC_NAME" 2>&1 | tail -3
        done
        echo "   ✅ Edge functions deployadas"
    else
        echo "   ⚠️  Diretório $FUNCTIONS_DIR não encontrado"
    fi
fi

echo ""
echo "=== Deploy Supabase concluído ==="
echo "   Data: $(TZ='America/Sao_Paulo' date '+%d/%m/%Y %H:%M BRT')"
