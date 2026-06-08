-- =====================================================================
-- Migration: create_schema_<SCHEMA>
-- Schema:    <SCHEMA>
-- Autor:     Deivithi
-- Data:      YYYY-MM-DD
-- Propósito: Criar schema <SCHEMA> p/ domínio <DOMINIO>.
--
-- Rollback plan:
-- DROP SCHEMA <SCHEMA> CASCADE;   -- ⚠️ requer confirmação verbose
--
-- Dependências: nenhuma
--
-- Testes pós-deploy:
-- SELECT nspname FROM pg_namespace WHERE nspname = '<SCHEMA>';
-- SELECT has_schema_privilege('authenticated', '<SCHEMA>', 'USAGE');
-- =====================================================================

BEGIN;

-- 1. Schema
CREATE SCHEMA IF NOT EXISTS <SCHEMA>;

COMMENT ON SCHEMA <SCHEMA> IS
  'Domínio: <DOMINIO>. Owner: Deivithi. Criado: YYYY-MM-DD. '
  'Propósito: <1 linha>.';

-- 2. Grants p/ roles Supabase
GRANT USAGE ON SCHEMA <SCHEMA> TO anon, authenticated, service_role;

-- 3. Default privileges p/ objetos futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA <SCHEMA>
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated;

ALTER DEFAULT PRIVILEGES IN SCHEMA <SCHEMA>
  GRANT ALL ON TABLES TO service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA <SCHEMA>
  GRANT USAGE, SELECT ON SEQUENCES TO authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA <SCHEMA>
  GRANT EXECUTE ON FUNCTIONS TO anon, authenticated, service_role;

-- 4. Função de trigger compartilhada (se não existir em public)
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

COMMIT;

-- =====================================================================
-- PÓS-MIGRATION (manual, não rodar no SQL):
-- 1. Dashboard → Project Settings → API → Exposed schemas → add "<SCHEMA>"
-- 2. Atualizar supabase/config.toml: [api].schemas = [..., "<SCHEMA>"]
-- 3. Registrar em .claude/skills/supabase-factory/references/schemas-catalog.md
-- 4. Rodar get_advisors(type=security) e type=performance
-- =====================================================================
