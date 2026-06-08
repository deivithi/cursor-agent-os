#!/bin/bash
# Deploy Vercel — Build + Test + Deploy com verificação
# Uso: bash deploy-vercel.sh [projeto] [--prod]
# Default: preview deploy. Use --prod para produção (◆ Diamond Gate)

set -euo pipefail

PROJECT_DIR="${1:-.}"
PROD_FLAG="${2:-}"

echo "🚀 Deploy Vercel iniciando..."
echo "   Diretório: $PROJECT_DIR"
echo "   Modo: $([ "$PROD_FLAG" = '--prod' ] && echo '🔴 PRODUÇÃO' || echo '🟢 Preview')"
echo "==="

# ─── PRE-FLIGHT CHECKS ──────────────────────────────────────
echo ""
echo "✈️  Pre-flight checks..."

# Check 1: Branch correta
CURRENT_BRANCH=$(cd "$PROJECT_DIR" && git branch --show-current 2>/dev/null || echo "unknown")
echo "   Branch: $CURRENT_BRANCH"

if [ "$PROD_FLAG" = "--prod" ] && [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "   ⚠️  AVISO: Deploy de produção na branch '$CURRENT_BRANCH' (não é main/master)"
    echo "   ◆ DIAMOND GATE: Confirme se deseja continuar"
fi

# Check 2: Sem alterações não commitadas
DIRTY_FILES=$(cd "$PROJECT_DIR" && git status --porcelain 2>/dev/null | wc -l)
if [ "$DIRTY_FILES" -gt 0 ]; then
    echo "   ⚠️  $DIRTY_FILES arquivos não commitados"
fi

# Check 3: Vercel CLI disponível
if ! command -v npx &>/dev/null; then
    echo "   ❌ npx não encontrado"
    exit 1
fi
echo "   ✅ npx disponível"

# ─── BUILD ───────────────────────────────────────────────────
echo ""
echo "🔨 Build..."
(cd "$PROJECT_DIR" && npm run build 2>&1 | tail -10)
BUILD_STATUS=$?

if [ $BUILD_STATUS -ne 0 ]; then
    echo "   ❌ Build falhou! Abortando deploy."
    exit 1
fi
echo "   ✅ Build OK"

# ─── DEPLOY ──────────────────────────────────────────────────
echo ""
echo "📦 Deploy..."
if [ "$PROD_FLAG" = "--prod" ]; then
    DEPLOY_OUTPUT=$(cd "$PROJECT_DIR" && npx vercel --prod --yes 2>&1)
else
    DEPLOY_OUTPUT=$(cd "$PROJECT_DIR" && npx vercel --yes 2>&1)
fi

DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -oE 'https://[^ ]+\.vercel\.app' | head -1)
echo "   URL: ${DEPLOY_URL:-'N/A'}"

# ─── SMOKE TEST ──────────────────────────────────────────────
if [ -n "$DEPLOY_URL" ]; then
    echo ""
    echo "🧪 Smoke test..."
    sleep 5  # Aguardar propagação
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL" 2>/dev/null || echo "000")

    if [ "$HTTP_CODE" = "200" ]; then
        echo "   ✅ HTTP $HTTP_CODE — Deploy acessível"
    else
        echo "   ❌ HTTP $HTTP_CODE — Deploy pode ter problemas!"
    fi
fi

# ─── RELATÓRIO ───────────────────────────────────────────────
echo ""
echo "=== Relatório de Deploy ==="
echo "   Data: $(TZ='America/Sao_Paulo' date '+%d/%m/%Y %H:%M BRT')"
echo "   Branch: $CURRENT_BRANCH"
echo "   Modo: $([ "$PROD_FLAG" = '--prod' ] && echo 'Produção' || echo 'Preview')"
echo "   URL: ${DEPLOY_URL:-'N/A'}"
echo "   HTTP: ${HTTP_CODE:-'N/A'}"
echo "   Status: $([ "${HTTP_CODE:-000}" = "200" ] && echo '✅ OK' || echo '⚠️  Verificar')"
