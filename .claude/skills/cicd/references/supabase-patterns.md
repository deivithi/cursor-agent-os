# 🗄️ Supabase Patterns

> Referência rápida para operações comuns no Supabase.

## Migrations

```bash
# Criar nova migration
supabase migration new descricao_curta

# Listar migrations
supabase migration list

# Aplicar migrations pendentes
supabase db push

# Reset completo (⚠️ APENAS dev!)
supabase db reset
```

## Edge Functions

```bash
# Criar nova function
supabase functions new nome-funcao

# Deploy
supabase functions deploy nome-funcao

# Deploy todas
supabase functions deploy

# Listar
supabase functions list

# Testar localmente
supabase functions serve nome-funcao
```

## Secrets

```bash
# Listar
supabase secrets list

# Adicionar
supabase secrets set CHAVE=valor

# Remover
supabase secrets unset CHAVE
```

## Branching (Preview)

```bash
# Criar branch de preview
supabase branches create feature-x

# Listar branches
supabase branches list

# Deletar branch
supabase branches delete feature-x
```

## Database

```bash
# Conectar via psql
supabase db connect

# Executar SQL
supabase db execute "SELECT COUNT(*) FROM leads;"

# Dump schema
supabase db dump --schema public
```

## Gotchas Supabase

1. **RLS habilitado por default** — tabela sem policy = sem acesso (ou acesso total se RLS desativado)
2. **Migrations são ordenadas por timestamp** — cuidado com ordem de foreign keys
3. **Connection limit**: 60 diretas (Free), usar Supavisor para pooling (porta 6543)
4. **Edge functions deploy silencioso** — pode reportar sucesso com build falho
5. **`db reset` é DESTRUTIVO** — nunca em produção
6. **`db push`** aplica migrations irreversivelmente — testar em branch antes
