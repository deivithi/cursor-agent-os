# 🌿 Branching Playbook — febracis-dre

> **Estratégia:** Híbrido. `staging` persistente (quando Pro tier ativo) + temporárias por PR crítico + `dev` local via Supabase CLI.

---

## Status atual

⚠️ **Branching Supabase NÃO está habilitado em `febracis-dre`** (2026-04-19).
Requer upgrade p/ **Pro tier** ($25/mês). Enquanto não habilitado:

- **Dev local** via `supabase CLI` + Docker (recomendado p/ 90% dos casos)
- **Staging "virtual"** via schema dedicado `staging_<modulo>` (isolamento lógico temporário)
- **Prod** é o único ambiente cloud disponível

---

## Fluxo ideal (quando branching estiver ativo)

```
┌──────────┐   develop   ┌─────────────┐    QA    ┌─────────┐   cut    ┌──────┐
│ dev local│────────────▶│ branch temp │─────────▶│ staging │─────────▶│ prod │
│ (CLI)    │  supabase   │ feature/X   │  merge   │persistent│  merge   │      │
└──────────┘   db push   └─────────────┘          └─────────┘          └──────┘
     ▲                          │                      │
     │    rollback fácil        │  auto-delete         │  rebase diário
     └──────────────────────────┘  no merge PR         │  p/ pegar hotfixes prod
                                                       │
```

---

## Dev local (sempre disponível)

Requer `supabase CLI` instalado:

```bash
# Instalar (Windows via scoop ou release .exe)
scoop install supabase

# Iniciar stack local
supabase init               # 1x por projeto
supabase start              # sobe Docker c/ Postgres + Studio + Auth + Storage

# Status e URLs locais
supabase status
# Studio: http://localhost:54323
# API:    http://localhost:54321
# DB:     postgresql://postgres:postgres@localhost:54322/postgres

# Criar migration
supabase migration new criar_schema_crm

# Editar o arquivo gerado em supabase/migrations/*.sql

# Aplicar localmente
supabase db reset           # rebuild db local c/ todas as migrations

# Quando pronto, push p/ projeto remoto (prod)
supabase link --project-ref vwxgrjjwbvdiaqxqbryk
supabase db push            # aplica migrations pendentes em prod
```

### Quando usar dev local

- Mudanças pequenas (1-2 tabelas)
- Experimentação rápida
- Treinar policies RLS antes de prod
- Debug c/ volume real de dados (seed custom)

### Limites dev local

- Dados não sincronizam c/ prod (snapshot desatualizado)
- Extensions podem divergir (verificar via `list_extensions`)
- Edge Functions rodam em Docker local (OK mas não 100% igual prod)

---

## Branches temporárias (Pro tier)

```bash
# Criar via Supabase CLI (depois que Pro tier estiver ativo)
supabase branches create feature/crm-leads --project-ref vwxgrjjwbvdiaqxqbryk

# Ou via MCP:
# mcp__claude_ai_Supabase__create_branch(
#   project_id="vwxgrjjwbvdiaqxqbryk",
#   name="feature/crm-leads",
#   confirm_cost_id=<token>
# )

# Listar branches
supabase branches list

# Usar a branch — cada branch tem HOST e KEYS próprios
# (retornados na criação — salvar em .env local)

# Merge p/ main (prod)
supabase branches merge feature/crm-leads

# Deletar após merge
supabase branches delete feature/crm-leads
```

### Convenções de nomes de branch

| Prefixo | Uso | Persistência |
|---------|-----|--------------|
| `feature/<nome>` | Feature branch por PR | Temporária (delete no merge) |
| `hotfix/<nome>` | Correção urgente | Temporária |
| `staging` | Pré-prod persistente | Persistente (nunca deletar) |
| `qa/<sprint>` | Sprint QA | Temporária (delete no fim do sprint) |
| `_lab_/<experimento>` | POC/descartável | Temporária (TTL 30 dias) |

---

## Rebase vs reset de branches

- **`rebase_branch`** — sincroniza branch c/ mudanças da main. Use quando main recebeu hotfix e sua branch está atrasada.
- **`reset_branch`** — destrói mudanças da branch e volta ao estado da main. ⚠️ destrutivo.

```
# Via MCP:
# mcp__claude_ai_Supabase__rebase_branch(branch_id)   — preserva trabalho
# mcp__claude_ai_Supabase__reset_branch(branch_id)    — DESTRUTIVO (confirmação verbose!)
```

---

## Custo estimado

| Item | Custo |
|------|-------|
| Pro tier (base) | $25/mês |
| Branch persistente (`staging`) | incluído no Pro |
| Branch temporária | $0.01344/hora (~$10/mês se 24/7 — deletar após merge!) |
| Compute adicional em branch | variável |

> Deletar branches temporárias **SEMPRE** após merge. Branches esquecidas acumulam custo silenciosamente.

---

## Fallback enquanto Pro não está ativo

### Opção A — Schema dedicado como "staging virtual"

```sql
-- Staging lógico dentro do mesmo banco prod (não recomendado p/ dados sensíveis)
CREATE SCHEMA IF NOT EXISTS staging_crm;

-- Copiar estrutura do schema prod
-- ... DDL manual ou pg_dump --schema-only ...

-- Quando validado, DROP staging e apply migration em prod
DROP SCHEMA staging_crm CASCADE;  -- ⚠️ confirmação verbose
```

❌ **Desvantagens:** sem isolamento de compute, sem isolamento de auth, arriscado.

### Opção B — Dev local + deploy direto (recomendado)

1. Validar tudo em dev local
2. `supabase db push` em horário de baixo tráfego
3. Monitor logs + advisors imediatamente após deploy
4. Ter script de rollback pronto (migration reversa)

---

## Checklist pre-merge (p/ prod)

- [ ] Migration rodou sem erro em dev local
- [ ] `supabase db diff` mostra apenas mudanças esperadas
- [ ] RLS habilitado em todas as tabelas novas
- [ ] Policies testadas c/ `auth.uid()` de usuários diferentes
- [ ] `get_advisors(type=security)` → zero issues críticos
- [ ] `get_advisors(type=performance)` → índices em colunas de JOIN/WHERE
- [ ] Rollback plan escrito (migration reversa ou script)
- [ ] Backup recente do banco (Supabase faz diário, verificar)
- [ ] Notificar time (se time > 1 pessoa)
