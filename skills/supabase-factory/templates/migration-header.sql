-- =====================================================================
-- Migration: <nome_descritivo>
-- Schema:    <schema_alvo>
-- Autor:     <deivithi>
-- Data:      YYYY-MM-DD
-- Propósito: <1 linha explicando o que essa migration faz>
--
-- Rollback plan:
-- <1-3 linhas descrevendo como reverter. Se DDL, geralmente:
--  - DROP TABLE <schema>.<tabela>;
--  - DROP SCHEMA <schema> CASCADE;  (se schema novo c/ só essa tabela)
--  - Restore do backup se data loss>
--
-- Dependências:
-- - <schema/tabela X deve existir antes>
-- - <extension Y>
--
-- Testes pós-deploy:
-- - SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE schemaname = '<schema>';
-- - SELECT ... FROM <schema>.<tabela> LIMIT 1;
-- - Conferir get_advisors(type=security) sem issues
-- =====================================================================

BEGIN;

-- ... DDL aqui ...

COMMIT;
