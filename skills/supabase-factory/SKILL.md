---
name: supabase-factory
description: >
  Provisiona banco de dados Supabase p/ novas aplicações Febracis. Decide
  schema vs branch vs projeto novo, aplica padrão deivithi's Org/febracis-dre,
  gera migrations c/ RLS. Ativa c/: "criar banco", "novo banco supabase",
  "provisionar supabase", "onde subo essa tabela", "novo schema",
  "novo módulo supabase", "criar projeto supabase", "supabase branch",
  "ambiente dev supabase", "separar contextos supabase", "modularizar public",
  "onde criar tabela", "criar database", "nova aplicação banco".
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
metadata:
  author: deivithi
  version: "1.0.0"
  category: infrastructure
  tags: [supabase, postgres, provisioning, schemas, branching, febracis, multi-tenant, rls]
---

# 🏭 Supabase Factory — Provisioning Unificado Febracis

> **"Um projeto pago, schemas modulares, ambientes isolados. Zero frankenstein."**

Skill de roteamento que decide **onde** subir o banco de uma nova aplicação antes de executar. Aplica o padrão operacional da Febracis: **deivithi's Org** como org, **febracis-dre** como projeto único, schemas Postgres p/ modularização, Branching p/ ambientes.

## 📁 File Structure

- `SKILL.md` — Você está aqui. Hub de decisão + workflow.
- `references/org-project.md` — Fonte de verdade: IDs, hosts, region, env vars padrão
- `references/schemas-catalog.md` — Catálogo vivo de schemas (auto-detectado via MCP)
- `references/branching-playbook.md` — Fluxo dev local → branch temp → staging → prod
- `references/schema-creation-runbook.md` — CREATE SCHEMA passo a passo c/ RLS
- `references/decision-tree.md` — Árvore completa schema vs branch vs projeto
- `templates/new-schema.sql` — Template schema + grants + RLS defaults
- `templates/new-table-with-rls.sql` — Template tabela + RLS + policies
- `templates/migration-header.sql` — Cabeçalho padrão migrations
- `scripts/validate-schema-name.sh` — Valida nome de schema (reservados, convenção)
- `gotchas.md` — Armadilhas conhecidas (branching cost, search_path, RLS cross-schema)

## 🔗 Related Skills

- `supabase-docs` — Docs oficiais via SSH (handoff p/ dúvidas de sintaxe)
- `supabase-postgres` — Best practices RLS/índices (handoff pós-provisioning)
- `scaffolding` — Boilerplate de código app (handoff pós-schema)
- `vibe-deploy-guard` — 18 checks de segurança (bloquear deploy sem RLS)
- `pulso-finance` — Projeto externo (PulsoFinance, ref separado)
- `cicd` — Deploy c/ migrations via CI

---

## 🎯 Quando Ativar

Ativa **SEMPRE** que o contexto for **criar/provisionar/organizar banco Supabase**:

- "preciso criar banco p/ módulo X"
- "onde eu subo essa tabela nova?"
- "quero separar esse módulo do resto"
- "novo schema p/ vendas"
- "ambiente dev isolado"
- "criar projeto Supabase" (intercepta e sugere schema primeiro)
- "modularizar o public que tá virando frankenstein"

## 🚫 Quando NÃO Usar

- Escrever policy RLS específica → `supabase-postgres`
- Debug de Auth/Storage/Realtime → `supabase-docs`
- Gerar código da app (React hook, Edge Function) → `scaffolding`
- Deploy production → `deploy-checklist` + `vibe-deploy-guard`

---

## 🌲 Decision Tree (resumo)

```
Novo módulo precisa de banco?
│
├─ Domínio já existe em schema mapeado? (ver schemas-catalog.md)
│   └─ SIM → reusar schema existente
│
├─ Novo domínio de negócio dentro do Febracis?
│   └─ SIM → CREATE SCHEMA novo em febracis-dre
│            (ex: crm, vendas, educacao, ia, financeiro)
│
├─ Produto totalmente separado (billing próprio, compliance isolado,
│   time externo, escala prevista > 10GB/100M rows)?
│   └─ SIM → CRIAR PROJETO NOVO (requer confirmação verbose explícita
│            — custo $25/mês mínimo)
│
└─ Precisa testar mudança sem afetar prod?
    ├─ PR pequeno / 1-2 tabelas → dev local (supabase CLI)
    ├─ PR multi-tabela / migration complexa → branch temporária
    └─ Release candidate / QA integrado → merge p/ staging
```

> 📖 **Detalhes completos** → `references/decision-tree.md`

---

## ⚙️ Workflow

### Passo 1 — Identificar contexto

Perguntar (ou inferir do contexto):
- **Nome do módulo:** (ex: "crm", "vendas", "educacao-cis")
- **Domínio de negócio:** CRM, Financeiro, Educação, IA, DRE, Automação, Outro
- **Precisa ambiente isolado?** (dev local vs branch vs direto em staging)
- **Tabelas esperadas:** quantas, volume estimado, multi-tenant?

### Passo 2 — Consultar catálogo

```bash
# Ler catálogo atual
cat .claude/skills/supabase-factory/references/schemas-catalog.md
```

Se o domínio já tem schema → **reusar**. Se não → **criar schema novo**.

### Passo 3 — Aplicar decision tree

Seguir árvore em `references/decision-tree.md`. Em **99% dos casos** a resposta é **schema novo em febracis-dre**. Projeto novo = exceção rara.

### Passo 4 — Validar nome do schema

```bash
bash .claude/skills/supabase-factory/scripts/validate-schema-name.sh <nome>
```

Regras:
- `snake_case` (ex: `crm`, `financeiro`, `educacao_cis`)
- NÃO pode colidir c/ reservados: `public`, `auth`, `storage`, `realtime`, `graphql`, `extensions`, `vault`, `pgsodium`, `supabase_migrations`, `net`, `pgbouncer`
- NÃO pode colidir c/ schemas existentes (ver catálogo)

### Passo 5 — Executar provisioning

Usar MCP Supabase (ferramentas `mcp__claude_ai_Supabase__*`):

```
1. list_projects                   → confirmar febracis-dre ACTIVE
2. (se branch necessária)
   create_branch                    → branch "staging" ou "feature/X"
3. apply_migration                  → usar templates/new-schema.sql
4. apply_migration                  → usar templates/new-table-with-rls.sql
5. get_advisors(type=security)      → verificar RLS ok
6. get_advisors(type=performance)   → verificar índices
7. generate_typescript_types        → gerar types p/ app (se frontend)
```

### Passo 6 — Registrar no catálogo

Editar `references/schemas-catalog.md` adicionando entrada:

```markdown
### `nome_schema`
- **Owner:** [pessoa/time]
- **Propósito:** [descrição 1 linha]
- **Criado:** YYYY-MM-DD
- **Tabelas:** [lista inicial]
- **Multi-tenant:** sim/não
- **RLS:** habilitado
- **Aplicação consumidora:** [nome app/repo]
```

### Passo 7 — Env vars padrão

Retornar ao usuário as env vars p/ a aplicação:

```bash
SUPABASE_URL=https://vwxgrjjwbvdiaqxqbryk.supabase.co
SUPABASE_ANON_KEY=<anon_key>                      # público no frontend
SUPABASE_SERVICE_ROLE_KEY=<service_role>          # APENAS server-side
POSTGRES_URL=<pooled>                             # Supavisor 6543 transaction mode
POSTGRES_URL_NON_POOLING=<direct 5432>            # p/ migrations e LISTEN/NOTIFY

# Search path da app (importante!)
PGRST_DB_SCHEMAS=public,<novo_schema>             # expõe schema via PostgREST
```

> ⚠️ **`anon_key` e `service_role` obter via** MCP `get_publishable_keys` ou Dashboard. **Nunca** colar chaves neste SKILL.md.

### Passo 8 — Handoff

Após provisioning, sugerir próximas skills:

- `supabase-postgres` → otimizar índices, RLS avançado
- `scaffolding` → gerar client TS, hooks, route handlers
- `vibe-deploy-guard` → checklist segurança antes de deploy
- `cicd` → configurar migrations em CI

---

## 🛡️ Safety Gates (INVIOLÁVEIS)

| Gate | Regra | Motivo |
|------|-------|--------|
| 🚫 Destrutivo | NUNCA executar `DROP SCHEMA`, `DROP TABLE`, `TRUNCATE`, `DELETE s/ WHERE` sem confirmação verbose | `feedback_supabase_safety.md` — dados são sagrados |
| 🚫 Projeto novo | Exige confirmação EXPLÍCITA do usuário + justificativa escrita | Custo $25/mês mínimo, viola princípio de single-project |
| 🚫 Migration prod | NUNCA aplicar migration direto em prod — sempre via branch ou staging primeiro | Rollback caro em prod |
| ✅ RLS obrigatório | Toda tabela em schema novo ou `public` DEVE ter `ENABLE ROW LEVEL SECURITY` + policy | VDG-05 do `vibe-deploy-guard` |
| ✅ `auth.uid()` only | Policies usam `auth.uid()`, nunca headers JWT manuais | VDG + security-002 do `supabase-postgres` |
| ✅ UUID PK | Primary keys usam `uuid DEFAULT gen_random_uuid()` | schema-001 do `supabase-postgres` |
| ✅ Registro obrigatório | Após criar schema, DEVE atualizar `schemas-catalog.md` | Fonte de verdade não pode dessincronizar |
| ✅ Advisors check | Após migration, rodar `get_advisors(type=security)` + `type=performance` | Catch issues antes de virar incidente |

---

## 📊 Progressive Disclosure

| Complexidade | Comportamento |
|--------------|---------------|
| **Simples** (reusar schema existente, 1 tabela) | Aplicar template direto, validar RLS, registrar catálogo |
| **Médio** (novo schema, 3-5 tabelas relacionadas) | Decision tree completa, criar schema + tabelas + RLS + advisors |
| **Complexo** (novo produto, multi-schema, branching) | Pausar. Validar c/ usuário se é caso de projeto novo. Decompor em fases |

---

## 🔀 Handoff Points

| Situação | Skill destino | Condição |
|----------|---------------|----------|
| Dúvida sobre sintaxe Supabase | `supabase-docs` | Antes de escrever migration complexa |
| Policy RLS complexa | `supabase-postgres` | Multi-tenant, cross-schema, row-level ownership |
| Código da aplicação | `scaffolding` | Após schema pronto |
| Pre-deploy | `vibe-deploy-guard` | Sempre antes de push p/ main |
| Pulso Finance | `pulso-finance` | Projeto externo — factory NÃO provisiona lá |
| Criar skill nova | `skill-architect` | Meta-tarefa (não banco) |

---

## ⚠️ Gotchas

Consulte `gotchas.md` p/ lista completa. Principais:

1. **`public` sobrecarregado** → schemas novos viram mandatório, não opcional
2. **Branching custo** → requires Pro plan; free tier NÃO tem branches (apenas dev local)
3. **`search_path`** → PostgREST só expõe schemas listados em `db-schemas` config
4. **RLS cross-schema** → `auth.uid()` funciona em qualquer schema, mas JOIN entre schemas exige GRANT explícito
5. **Reserved schema names** → ver `scripts/validate-schema-name.sh`
6. **`service_role` no client** → VIOLA segurança. Nunca no frontend

---

## 📚 Referências

- Fonte de verdade do projeto: `references/org-project.md`
- Catálogo atual: `references/schemas-catalog.md`
- Supabase Branching: https://supabase.com/docs/guides/deployment/branching
- Postgres schemas: https://www.postgresql.org/docs/current/ddl-schemas.html
- RLS: `supabase-postgres` skill (security-001, security-002)

---

**Mantra:** *Um projeto. Schemas modulares. Ambientes isolados. Zero Frankenstein.*
