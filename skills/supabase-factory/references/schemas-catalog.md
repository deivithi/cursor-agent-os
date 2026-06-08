# 📋 Schemas Catalog — febracis-dre

> Auto-detectado via MCP `list_tables` em 2026-04-19.
> Atualizar a cada novo schema criado via `supabase-factory`.

---

## Como ler este catálogo

- **Schema:** nome do schema Postgres
- **Owner:** pessoa/time responsável (preencher quando conhecido)
- **Propósito:** domínio de negócio que o schema representa
- **Tabelas principais:** núcleo do schema (lista não exaustiva)
- **Multi-tenant:** se tem `franchise_id`/`tenant_id`/`user_id` na maioria das tabelas
- **RLS:** status de Row Level Security
- **App consumidora:** repositório/aplicação que lê/escreve no schema
- **Convenção de nomes:** padrão adotado (snake_case_singular, etc.)

---

## Schemas de aplicação (livres p/ uso)

### `public` ⚠️ SOBRECARREGADO

**Status atual: misturando 4 domínios distintos. Candidato a refactor progressivo p/ schemas dedicados.**

- **Owner:** Deivithi
- **Propósito:** [MIXED] — originalmente tudo, hoje mistura DRE + GBrain + Agents + Events
- **Multi-tenant:** parcial (algumas tabelas c/ `franchise_id`, outras c/ `user_id`)
- **RLS:** habilitado na maioria (algumas tabelas c/ RLS disabled — revisar: `pages`, `access_tokens`, `mcp_request_log`, `links`, `files`, `tags`, `raw_data`, `config`, `page_versions`, `timeline_entries`, `ingest_log`, `content_chunks`)
- **App consumidora:** portal febracis-dre + gbrain + agents

#### Sub-domínios identificados em `public` (candidatos a extração)

| Sub-domínio | Tabelas | Extração sugerida |
|-------------|---------|-------------------|
| **DRE (portal financeiro)** | `franchises`, `regionals`, `events`, `event_types`, `reporting_periods`, `period_franchise_status`, `dre_sections`, `dre_lines`, `dre_line_groups`, `dre_line_group_items`, `submissions`, `submission_*` (8 tabelas), `calculation_rules`, `calculation_rule_versions`, `calculation_rule_dependencies`, `validation_rules` | → schema `dre` |
| **GBrain (knowledge base)** | `pages`, `page_versions`, `content_chunks`, `files`, `links`, `tags`, `raw_data`, `ingest_log`, `timeline_entries` | → schema `gbrain` |
| **Agents (MCP/IA)** | `agent_sessions`, `agent_messages`, `mcp_request_log`, `access_tokens` | → schema `agents` |
| **Auth/RBAC compartilhado** | `profiles`, `roles`, `user_roles`, `user_scopes`, `audit_log`, `config` | permanece em `public` (cross-cutting) |

### `febracis_automation` ✅ EXEMPLO DE MODULARIZAÇÃO

- **Owner:** Deivithi
- **Propósito:** Registry e estado de workflows de automação (n8n, etc.)
- **Tabelas:** `workflow_registry`
- **Multi-tenant:** não (registry global)
- **RLS:** ❌ desabilitado (revisar — se expuser via PostgREST, habilitar)
- **App consumidora:** n8n + dashboards internos
- **Criado:** 2026 (primeiro schema customizado de febracis-dre)

---

## Schemas reservados (NÃO USAR como destino)

| Schema | Reservado por | Nunca criar tabelas aqui |
|--------|---------------|-------------------------|
| `auth` | Supabase Auth | users, sessions, identities, MFA, SSO, OAuth |
| `storage` | Supabase Storage | buckets, objects, s3 multipart |
| `realtime` | Supabase Realtime | subscription, messages |
| `vault` | Supabase Vault | secrets encriptados |
| `supabase_migrations` | Supabase CLI | schema_migrations |
| `graphql`, `graphql_public` | pg_graphql extension | — |
| `extensions` | Postgres extensions | — |
| `pgsodium`, `pgsodium_masks` | Encryption | — |
| `net` | pg_net extension | — |
| `pgbouncer` | Pooler | — |

---

## Candidatos de schemas futuros (roadmap de modularização)

| Schema | Trigger p/ criação | Justificativa |
|--------|-------------------|---------------|
| `dre` | Quando houver refactor do portal | Isolar domínio financeiro (34 tabelas em `public`) |
| `gbrain` | Na próxima feature do GBrain | Knowledge base tem modelo mental próprio |
| `agents` | Quando agent_sessions crescer > 10k rows | Separar logs de agentes IA do resto |
| `crm` | Novo módulo de relacionamento c/ franqueados/leads | Sugerido pelo usuário como contexto |
| `financeiro` | Módulo financeiro (diferente de DRE — contas a pagar/receber) | Sugerido pelo usuário |
| `educacao` | Módulo Método CIS (eventos, trilhas, certificações) | Sugerido pelo usuário |
| `ia` | Features IA novas (embeddings, feedback loops, evals) | Sugerido pelo usuário |

---

## Como adicionar nova entrada

Após criar schema via `supabase-factory`, adicionar abaixo (antes de "Schemas reservados"):

```markdown
### `<nome_schema>`
- **Owner:** <pessoa>
- **Propósito:** <1 linha>
- **Tabelas principais:** <lista>
- **Multi-tenant:** sim/não (coluna `<tenant_col>`)
- **RLS:** habilitado
- **App consumidora:** <repo/app>
- **Convenção de nomes:** snake_case_plural (ex: `leads`, `contacts`)
- **Criado:** YYYY-MM-DD
```

---

## Última atualização

**2026-04-19** — seed inicial via MCP `list_tables`. 77 tabelas detectadas em 6 schemas (public, auth, storage, realtime, vault, supabase_migrations, febracis_automation).
