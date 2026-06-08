# 🏢 Organização e Projeto — Fonte de Verdade

> Dados detectados via MCP `list_projects` em 2026-04-19.
> Atualizar manualmente se houver mudança de region, upgrade de plano ou troca de projeto.

---

## Organização padrão

| Campo | Valor |
|-------|-------|
| **Nome** | deivithi's Org |
| **Organization ID / Slug** | `nayypuosrfhhrkorfszw` |
| **Billing** | Deivithi (pessoal) |

---

## Projeto principal: `febracis-dre`

| Campo | Valor |
|-------|-------|
| **Nome** | febracis-dre |
| **Project Ref / ID** | `vwxgrjjwbvdiaqxqbryk` |
| **Host do banco** | `db.vwxgrjjwbvdiaqxqbryk.supabase.co` |
| **URL API** | `https://vwxgrjjwbvdiaqxqbryk.supabase.co` |
| **Region** | `sa-east-1` (São Paulo) |
| **Postgres** | 17.6 (engine 17, release channel GA) |
| **Status** | ACTIVE_HEALTHY |
| **Criado em** | 2026-03-28 |
| **Branching habilitado** | ❌ Não (requer upgrade p/ Pro tier) |

### Connection strings

```bash
# Pooled (Supavisor transaction mode) — usar no app (Vercel/Edge Functions)
POSTGRES_URL="postgresql://postgres.vwxgrjjwbvdiaqxqbryk:<PASSWORD>@aws-0-sa-east-1.pooler.supabase.com:6543/postgres"

# Direct (porta 5432) — usar p/ migrations, LISTEN/NOTIFY, prepared statements
POSTGRES_URL_NON_POOLING="postgresql://postgres.vwxgrjjwbvdiaqxqbryk:<PASSWORD>@aws-0-sa-east-1.pooler.supabase.com:5432/postgres"
```

### Env vars padrão p/ apps consumidoras

```bash
# Frontend (safe to expose)
VITE_SUPABASE_URL=https://vwxgrjjwbvdiaqxqbryk.supabase.co
VITE_SUPABASE_ANON_KEY=<anon_key>                   # ver MCP get_publishable_keys

# Server-side APENAS (NUNCA NEXT_PUBLIC/VITE)
SUPABASE_URL=https://vwxgrjjwbvdiaqxqbryk.supabase.co
SUPABASE_SERVICE_ROLE_KEY=<service_role>            # bypass RLS — never frontend
POSTGRES_URL=<pooled>
POSTGRES_URL_NON_POOLING=<direct>

# PostgREST (expor schemas customizados via REST API)
# Configurar em Dashboard → Project Settings → API → Exposed schemas
# Default: public, graphql_public
# Adicionar: crm, financeiro, educacao, ia conforme criados
```

---

## Projeto externo (fora do escopo do factory)

| Nome | Ref | Papel |
|------|-----|-------|
| `PulsoFinance` | `txbzynnszuvjnmhbnnzh` | App pessoal Pulso Finance — projeto próprio (não usar via factory) |

---

## Como atualizar este arquivo

Executar via MCP:

```
mcp__claude_ai_Supabase__list_projects → obter refs, region, status
mcp__claude_ai_Supabase__get_project(project_id) → obter detalhes completos
mcp__claude_ai_Supabase__get_project_url(project_id) → URL REST
mcp__claude_ai_Supabase__get_publishable_keys(project_id) → chave anon pública
```

**NUNCA** colar `service_role` neste arquivo — é checkado no git.

---

## Sinais p/ criar projeto novo (exceção rara)

Considerar projeto separado SOMENTE se ≥2 dos critérios abaixo forem verdadeiros:

- [ ] Billing isolado obrigatório (cliente externo paga)
- [ ] Compliance isolado (LGPD scope diferente, dados sensíveis de terceiros)
- [ ] Volume > 10 GB ou > 100M rows projetado
- [ ] Time externo c/ acesso restrito (não mesma org deivithi)
- [ ] Produto vendido como SaaS independente (não ferramenta interna)

Se < 2 critérios → schema novo em `febracis-dre` é a resposta.
