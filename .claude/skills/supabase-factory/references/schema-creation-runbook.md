# 🛠️ Schema Creation Runbook

> Passo a passo p/ criar um novo schema em `febracis-dre` corretamente.

---

## Pré-requisitos

- [ ] Nome do schema validado (ver `scripts/validate-schema-name.sh`)
- [ ] Owner definido
- [ ] Propósito escrito em 1 linha
- [ ] Decision tree seguida (ver `decision-tree.md`)
- [ ] Sem colisão c/ `schemas-catalog.md`

---

## Passo 1 — Gerar migration file

Usar template `templates/new-schema.sql` como base.

```bash
# Via Supabase CLI (local)
supabase migration new create_schema_<nome>

# O arquivo é gerado em supabase/migrations/<timestamp>_create_schema_<nome>.sql
```

---

## Passo 2 — Popular a migration

Estrutura mínima:

```sql
-- [migration-header.sql]

BEGIN;

-- 1. Criar schema
CREATE SCHEMA IF NOT EXISTS <nome>;

-- 2. Comentário (documentação inline)
COMMENT ON SCHEMA <nome> IS 'Propósito: <1 linha>. Owner: <pessoa>. Criado: YYYY-MM-DD.';

-- 3. Grants padrão Supabase
GRANT USAGE ON SCHEMA <nome> TO anon, authenticated, service_role;

-- 4. Default privileges p/ objetos futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA <nome>
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA <nome>
  GRANT USAGE, SELECT ON SEQUENCES TO authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA <nome>
  GRANT EXECUTE ON FUNCTIONS TO anon, authenticated, service_role;

-- 5. (Opcional) Extensões específicas do schema
-- CREATE EXTENSION IF NOT EXISTS <ext> SCHEMA <nome>;

COMMIT;
```

---

## Passo 3 — Expor schema via PostgREST

Supabase só expõe schemas listados em `db-schemas`. Configurar:

**Via Dashboard:**
- Project Settings → API → Exposed schemas
- Adicionar `<nome>` à lista
- Save

**Via supabase CLI config (`supabase/config.toml`):**
```toml
[api]
schemas = ["public", "graphql_public", "<nome>"]
```

**Via MCP (não disponível diretamente):** usar Dashboard ou CLI.

⚠️ **Sem expor:** tabelas do schema ficam invisíveis ao client JS (`supabase.from(...)`). Acesso só via SQL direto.

---

## Passo 4 — Criar primeiras tabelas

Usar template `templates/new-table-with-rls.sql`. Exemplo:

```sql
BEGIN;

CREATE TABLE <schema>.leads (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),

  -- Multi-tenant (obrigatório se tabela tem dados por usuário/franquia)
  user_id     uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Campos de negócio
  name        text        NOT NULL,
  email       text        NOT NULL,
  phone       text,
  status      text        NOT NULL DEFAULT 'new' CHECK (status IN ('new','qualified','lost','won')),

  CONSTRAINT uq_<schema>_leads_email UNIQUE (email)
);

-- Índices p/ queries comuns
CREATE INDEX idx_<schema>_leads_user_id ON <schema>.leads(user_id);
CREATE INDEX idx_<schema>_leads_status_created ON <schema>.leads(status, created_at DESC);

-- Trigger updated_at (se função existir em public — senão criar uma vez)
CREATE TRIGGER trg_<schema>_leads_updated_at
  BEFORE UPDATE ON <schema>.leads
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- RLS obrigatório
ALTER TABLE <schema>.leads ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "leads_select_own"
  ON <schema>.leads FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "leads_insert_own"
  ON <schema>.leads FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "leads_update_own"
  ON <schema>.leads FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "leads_delete_own"
  ON <schema>.leads FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

COMMIT;
```

---

## Passo 5 — Aplicar migration

### Dev local

```bash
supabase db reset                       # rebuild local c/ migration
# OU
supabase migration up                   # aplica apenas a nova
```

### Prod (via MCP)

```
mcp__claude_ai_Supabase__apply_migration(
  project_id="vwxgrjjwbvdiaqxqbryk",
  name="create_schema_<nome>",
  query="<SQL da migration>"
)
```

### Prod (via CLI)

```bash
supabase link --project-ref vwxgrjjwbvdiaqxqbryk
supabase db push
```

---

## Passo 6 — Rodar advisors

```
mcp__claude_ai_Supabase__get_advisors(
  project_id="vwxgrjjwbvdiaqxqbryk",
  type="security"
)

mcp__claude_ai_Supabase__get_advisors(
  project_id="vwxgrjjwbvdiaqxqbryk",
  type="performance"
)
```

**Zero issues críticos obrigatório** antes de considerar schema pronto.

Issues comuns:
- `auth_rls_initplan` — policy c/ `auth.uid()` sem `(select ...)` wrapper (performance)
- `policy_exists_rls_disabled` — tabela c/ policy mas RLS disabled
- `rls_disabled_in_public` — tabela public sem RLS
- `no_primary_key` — tabela sem PK
- `unindexed_foreign_keys` — FK sem índice

---

## Passo 7 — Gerar types TypeScript (se frontend)

```
mcp__claude_ai_Supabase__generate_typescript_types(
  project_id="vwxgrjjwbvdiaqxqbryk"
)
```

Salvar em `src/types/supabase.ts` ou equivalente no repo da app.

---

## Passo 8 — Registrar no catálogo

Editar `references/schemas-catalog.md`:

```markdown
### `<nome>`
- **Owner:** Deivithi
- **Propósito:** <1 linha>
- **Tabelas principais:** leads, contacts, deals (inicial)
- **Multi-tenant:** sim (coluna `user_id`)
- **RLS:** habilitado
- **App consumidora:** <repo/app>
- **Convenção de nomes:** snake_case_plural
- **Criado:** YYYY-MM-DD
```

---

## Passo 9 — Atualizar env da app consumidora

Se a app precisa acessar o schema via cliente JS:

```typescript
// Supabase client c/ schema customizado
const supabase = createClient(url, anonKey, {
  db: { schema: '<nome>' }
});

// Ou por query:
const { data } = await supabase.schema('<nome>').from('leads').select();
```

---

## Passo 10 — Smoke test

```sql
-- Inserir registro via app (user logado)
-- Verificar que aparece apenas p/ o user dono
-- Verificar que outro user NÃO vê

-- SQL direto de validação:
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = '<nome>';
-- rowsecurity deve ser TRUE em todas

SELECT tablename, policyname, cmd, qual
FROM pg_policies
WHERE schemaname = '<nome>';
-- Deve listar as 4 policies (SELECT/INSERT/UPDATE/DELETE) por tabela
```

---

## Rollback (se der errado)

```sql
-- Só se NADA em produção usa ainda:
BEGIN;
  DROP SCHEMA <nome> CASCADE;   -- ⚠️ VERBOSE CONFIRMATION REQUIRED
COMMIT;
```

**NUNCA** rodar `DROP SCHEMA CASCADE` em schema c/ dados sem confirmação explícita + backup + aprovação.
