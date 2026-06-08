#!/bin/bash
# Scaffold Migration — Gera migration SQL para Supabase
# Uso: bash scaffold-migration.sh <descricao-curta>

set -euo pipefail

DESCRIPTION="${1:?Uso: scaffold-migration.sh <descricao-curta>}"
TIMESTAMP=$(date '+%Y%m%d%H%M%S')
MIGRATION_DIR="${2:-./supabase/migrations}"

# Normalizar nome (snake_case)
SAFE_DESC=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | tr ' -' '_' | tr -cd '[:alnum:]_')
MIGRATION_FILE="$MIGRATION_DIR/${TIMESTAMP}_${SAFE_DESC}.sql"

mkdir -p "$MIGRATION_DIR"

if ls "$MIGRATION_DIR"/*"$SAFE_DESC"*.sql 1>/dev/null 2>&1; then
    echo "⚠️  Já existe migration com descrição similar:"
    ls "$MIGRATION_DIR"/*"$SAFE_DESC"*.sql
    echo "   Continuar pode causar conflito. Use outra descrição."
    exit 1
fi

cat > "$MIGRATION_FILE" << TEMPLATE
-- Migration: $DESCRIPTION
-- Timestamp: $TIMESTAMP
-- Scaffolded: $(TZ='America/Sao_Paulo' date '+%d/%m/%Y %H:%M BRT')

-- ═══════════════════════════════════════════════════════════
-- TODO: Substituir 'nome_tabela' pelo nome real da tabela
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS nome_tabela (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

    -- TODO: Adicionar campos da tabela
    -- name TEXT NOT NULL,
    -- email TEXT UNIQUE NOT NULL,
    -- status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),

    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Trigger para auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS \$\$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON nome_tabela
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- ═══════════════════════════════════════════════════════════
-- RLS (Row Level Security) — OBRIGATÓRIO
-- ═══════════════════════════════════════════════════════════
ALTER TABLE nome_tabela ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can read their own data
CREATE POLICY "Users can read own data"
    ON nome_tabela
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- Policy: Authenticated users can insert
CREATE POLICY "Users can insert"
    ON nome_tabela
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- ═══════════════════════════════════════════════════════════
-- ROLLBACK (manter comentado — usar apenas se necessário)
-- ═══════════════════════════════════════════════════════════
-- DROP TABLE IF EXISTS nome_tabela CASCADE;
TEMPLATE

echo "✅ Migration scaffolded: $MIGRATION_FILE"
echo ""
echo "📋 Próximos passos:"
echo "   1. Substituir 'nome_tabela' pelo nome real"
echo "   2. Definir campos da tabela"
echo "   3. Ajustar RLS policies para seu caso de uso"
echo "   4. Testar: supabase db push (staging primeiro!)"
echo ""
echo "⚠️  NUNCA usar CASCADE em foreign keys de produção sem aprovação"
