# ⚠️ Gotchas — supabase-factory

Armadilhas conhecidas ao provisionar banco Supabase. Checar antes de executar.

---

## 1. `public` sobrecarregado é frankenstein

**Sintoma:** `febracis-dre.public` tem 50+ tabelas misturando DRE, GBrain, Agents, Events.

**Consequência:** nomes colidem (`events` é Método CIS ou evento de log?), RLS policies ficam ilegíveis, JOINs cruzam domínios sem semântica.

**Regra:** Novo módulo **NÃO** vai p/ `public`. Sempre criar schema dedicado (até mesmo se começar c/ 1 tabela). Baixo custo, alto payoff.

---

## 2. PostgREST não expõe schema automaticamente

**Sintoma:** `supabase.from('crm.leads')` retorna `relation does not exist` mesmo c/ tabela criada.

**Causa:** Supabase só expõe schemas listados em Project Settings → API → Exposed schemas.

**Fix:**
1. Dashboard → Settings → API → Exposed schemas → add `crm`
2. Ou em `supabase/config.toml`: `[api].schemas = ["public", "graphql_public", "crm"]`
3. Cliente JS: `createClient(url, key, { db: { schema: 'crm' } })` OU `supabase.schema('crm').from('leads')`

---

## 3. `search_path` default pega só `public`

**Sintoma:** funções/triggers que referenciam tabela sem qualificar schema dão erro.

**Fix:** SEMPRE qualificar schema em SQL: `crm.leads`, não `leads`. Ou configurar `ALTER ROLE authenticator SET search_path = 'public, crm';` (não recomendado — fica implícito).

---

## 4. RLS cross-schema exige GRANT explícito

**Sintoma:** Policy em `crm.deals` que faz `JOIN public.profiles` retorna vazio mesmo c/ dados.

**Causa:** `authenticated` pode ter acesso a `public` mas não a `crm`, ou vice-versa. GRANT USAGE no schema é OBRIGATÓRIO p/ cada role.

**Fix:** sempre incluir na migration do schema:
```sql
GRANT USAGE ON SCHEMA crm TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA crm GRANT ... ON TABLES TO authenticated;
```

---

## 5. `auth.uid()` em policy sem `(select ...)` = slow

**Sintoma:** Query lenta em tabela c/ RLS, especialmente em listagens.

**Causa:** `auth.uid()` é re-avaliado p/ cada linha (initplan issue flagged por advisor).

**Fix:** wrap c/ SELECT:
```sql
-- ❌ Slow
USING (user_id = auth.uid())

-- ✅ Fast (avalia 1x)
USING (user_id = (select auth.uid()))
```

---

## 6. `service_role` nunca no frontend

**Sintoma:** Variável `NEXT_PUBLIC_SUPABASE_SERVICE_ROLE_KEY` ou `VITE_SUPABASE_SERVICE_ROLE_KEY` presente.

**Consequência:** qualquer visitante do site BYPASSA TODO RLS → vazamento total de dados.

**Fix:** `service_role` só em:
- Edge Functions (secrets)
- Server-side de Next.js/Remix/etc.
- n8n credentials
- Migrations via CI

NUNCA em client JS. Ver `vibe-deploy-guard` VDG-01.

---

## 7. Branching não disponível no free tier

**Sintoma:** `create_branch` retorna erro "Project reference is missing when validating permissions" ou "not entitled".

**Causa:** Branching requer Pro tier ($25/mês).

**Fix atual de febracis-dre:** usar dev local (Supabase CLI + Docker) como substituto. Ver `references/branching-playbook.md`.

---

## 8. Migration aplicada direto em prod sem idempotência

**Sintoma:** Re-aplicar migration dá erro `relation already exists`.

**Fix:** sempre usar `IF NOT EXISTS` em DDL:
```sql
CREATE SCHEMA IF NOT EXISTS crm;
CREATE TABLE IF NOT EXISTS crm.leads (...);
CREATE INDEX IF NOT EXISTS idx_leads_email ON crm.leads(email);
```

Policies NÃO têm `IF NOT EXISTS` em versões antigas do Postgres — usar `DROP POLICY IF EXISTS ... ; CREATE POLICY ...`.

---

## 9. UUID gerado pelo client em vez do DB

**Sintoma:** App gera `uuid()` no frontend e envia ao DB.

**Causa:** perda de determinismo (dois clients podem gerar o mesmo UUID), logs não correlacionam.

**Fix:** PK sempre `DEFAULT gen_random_uuid()` no DB. Client NÃO envia `id` no INSERT.

---

## 10. Reserved schema names colidem silenciosamente

**Sintoma:** `CREATE SCHEMA auth` parece funcionar mas quebra Auth do Supabase.

**Fix:** SEMPRE validar c/ `scripts/validate-schema-name.sh` antes de criar. Lista reservada:
`public`, `auth`, `storage`, `realtime`, `graphql`, `graphql_public`, `extensions`, `vault`, `pgsodium`, `pgsodium_masks`, `supabase_migrations`, `net`, `pgbouncer`, `pg_catalog`, `information_schema`, `pg_temp_*`, `pg_toast*`.

---

## 11. Trigger `updated_at` replicado em cada schema

**Sintoma:** Função `set_updated_at()` duplicada em cada schema.

**Fix:** criar 1x em `public.set_updated_at()` (ou `_shared.set_updated_at()`) e reusar via `REFERENCES public.set_updated_at()`. Dar GRANT EXECUTE p/ roles.

---

## 12. Branch temporária esquecida = custo silencioso

**Sintoma:** Fatura Pro vai subindo sem explicação.

**Causa:** branch criada p/ PR, PR mergeu, branch NÃO foi deletada. Custo: ~$10/mês por branch viva 24/7.

**Fix:** Post-merge hook que chama `delete_branch`. Ou job cron que lista branches > 7 dias + notifica.

---

## 13. `apply_migration` pula `supabase_migrations.schema_migrations`

**Sintoma:** Migration aplicada via MCP `apply_migration`, mas `supabase migration list` local não mostra.

**Causa:** MCP aplica DDL direto no banco, o registry é atualizado mas CLI local não sabe.

**Fix:** rodar `supabase db pull` após MCP migrations p/ sincronizar state local, OU sempre migrar via CLI (não misturar).

---

## 14. PulsoFinance é projeto SEPARADO

**Sintoma:** User diz "criar tabela no Supabase" esperando que vá p/ PulsoFinance.

**Causa:** Pulso tem projeto próprio (`txbzynnszuvjnmhbnnzh`), factory foca `febracis-dre`.

**Fix:** Se contexto for Pulso Finance, handoff p/ skill `pulso-finance`. Factory NÃO opera lá.

---

## 15. Auto-detecção de schemas via MCP ignora `_temp_*`

**Sintoma:** Catálogo mostra schema `_temp_migration_20260419` que não deveria existir.

**Causa:** `list_tables` retorna tudo, incluindo temp schemas de migrations falhadas.

**Fix:** ao popular `schemas-catalog.md`, filtrar prefixos `_temp_`, `pg_`, `_lab_` (exceto se owner declarado).

---

## 16. Changelog da app não reflete schema novo

**Sintoma:** Pulso Finance tem feedback `changelog_update` — todo deploy atualiza Trilha de Novidades.

**Fix:** após provisionar schema p/ módulo novo da app, lembrar de atualizar o CHANGELOG da app consumidora (se aplicável).

---

## 17. Advisors rodam ASYNC — esperar antes de ler

**Sintoma:** `get_advisors` logo após `apply_migration` retorna advisors desatualizados.

**Fix:** aguardar ~10s antes de ler, ou verificar timestamp do último scan. Em caso de dúvida, re-rodar.
