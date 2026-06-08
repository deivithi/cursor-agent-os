-- =====================================================================
-- Migration: create_<TABELA>_in_<SCHEMA>
-- Schema:    <SCHEMA>
-- Tabela:    <TABELA>
-- Autor:     Deivithi
-- Data:      YYYY-MM-DD
-- Propósito: <1 linha — o que essa tabela armazena>
--
-- Rollback plan:
-- DROP TABLE <SCHEMA>.<TABELA>;   -- ⚠️ confirmação verbose se já tem dados
--
-- Multi-tenant: <sim/não>
-- Coluna de ownership: <user_id | franchise_id | org_id | NONE>
--
-- Testes pós-deploy:
-- SELECT rowsecurity FROM pg_tables WHERE schemaname='<SCHEMA>' AND tablename='<TABELA>';
-- SELECT policyname, cmd FROM pg_policies WHERE schemaname='<SCHEMA>' AND tablename='<TABELA>';
-- =====================================================================

BEGIN;

-- 1. Tabela
CREATE TABLE IF NOT EXISTS <SCHEMA>.<TABELA> (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),

  -- Ownership (multi-tenant)
  user_id     uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Campos de negócio — CUSTOMIZAR
  name        text        NOT NULL,
  description text,
  status      text        NOT NULL DEFAULT 'active'
                          CHECK (status IN ('active','archived','deleted')),
  metadata    jsonb       NOT NULL DEFAULT '{}'::jsonb,

  CONSTRAINT <TABELA>_name_not_empty CHECK (length(trim(name)) > 0)
);

COMMENT ON TABLE <SCHEMA>.<TABELA> IS '<1 linha — propósito da tabela>';

-- 2. Índices essenciais
CREATE INDEX IF NOT EXISTS idx_<TABELA>_user_id
  ON <SCHEMA>.<TABELA>(user_id);

CREATE INDEX IF NOT EXISTS idx_<TABELA>_status_created
  ON <SCHEMA>.<TABELA>(status, created_at DESC);

-- 3. Trigger updated_at
DROP TRIGGER IF EXISTS trg_<TABELA>_updated_at ON <SCHEMA>.<TABELA>;
CREATE TRIGGER trg_<TABELA>_updated_at
  BEFORE UPDATE ON <SCHEMA>.<TABELA>
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 4. RLS (OBRIGATÓRIO)
ALTER TABLE <SCHEMA>.<TABELA> ENABLE ROW LEVEL SECURITY;

-- 5. Policies (CRUD completo, ownership = user_id)
-- Usar (select auth.uid()) p/ evitar re-avaliação por linha (perf)
DROP POLICY IF EXISTS "<TABELA>_select_own" ON <SCHEMA>.<TABELA>;
CREATE POLICY "<TABELA>_select_own"
  ON <SCHEMA>.<TABELA> FOR SELECT
  TO authenticated
  USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "<TABELA>_insert_own" ON <SCHEMA>.<TABELA>;
CREATE POLICY "<TABELA>_insert_own"
  ON <SCHEMA>.<TABELA> FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "<TABELA>_update_own" ON <SCHEMA>.<TABELA>;
CREATE POLICY "<TABELA>_update_own"
  ON <SCHEMA>.<TABELA> FOR UPDATE
  TO authenticated
  USING (user_id = (select auth.uid()))
  WITH CHECK (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "<TABELA>_delete_own" ON <SCHEMA>.<TABELA>;
CREATE POLICY "<TABELA>_delete_own"
  ON <SCHEMA>.<TABELA> FOR DELETE
  TO authenticated
  USING (user_id = (select auth.uid()));

COMMIT;

-- =====================================================================
-- PÓS-MIGRATION:
-- 1. get_advisors(type=security)  → zero issues
-- 2. get_advisors(type=performance) → FKs indexadas
-- 3. Smoke test: INSERT c/ user A, SELECT c/ user B → 0 rows
-- 4. generate_typescript_types → atualizar types da app
-- =====================================================================
