---
name: supabase-postgres-best-practices
description: >
  Postgres performance optimization e best practices do Supabase. 8 categorias
  priorizadas por impacto (query performance, connection management, security/RLS,
  schema design, concurrency, data access patterns, monitoring, advanced features).
  Source: supabase/agent-skills (MIT).
domain: database
subdomain: postgres
version: 1.1.0
author: supabase
license: MIT
source: https://github.com/supabase/agent-skills/tree/main/skills/supabase-postgres-best-practices
tags:
  - supabase
  - postgres
  - database
  - performance
  - RLS
  - optimization
  - indexing
---

# 🐘 Supabase Postgres Best Practices

> **Fonte:** [supabase/agent-skills](https://github.com/supabase/agent-skills) (MIT) v1.1.0

## Related Skills
- `supabase-docs` — Docs oficiais Supabase via SSH (18 seções, sempre atualizados)
- `scaffolding` — Templates para migrations Supabase
- `code-review` — Review de queries SQL (complementar)
- `cicd` — Deploy com Supabase migrations

---

## Quando Aplicar

Consulte estas regras ao:
1. Escrever queries SQL para Supabase
2. Implementar índices
3. Investigar problemas de performance
4. Configurar connection pooling
5. Otimizar features do Postgres
6. Trabalhar com Row-Level Security (RLS)

---

## Categorias por Prioridade

| Prioridade | Categoria | Prefixo | Impacto |
|------------|-----------|---------|---------|
| 🔴 CRITICAL | Query Performance | `query-` | Maior impacto em latência e throughput |
| 🔴 CRITICAL | Connection Management | `conn-` | Estabilidade e escalabilidade |
| 🟠 HIGH | Security & RLS | `security-` | Proteção de dados e compliance |
| 🟠 HIGH | Schema Design | `schema-` | Fundação para performance futura |
| 🟡 MEDIUM | Concurrency & Locking | `lock-` | Evitar deadlocks e contenção |
| 🟡 MEDIUM | Data Access Patterns | `access-` | Otimizar reads/writes comuns |
| 🔵 LOW | Monitoring & Diagnostics | `monitor-` | Visibilidade e troubleshooting |
| 🔵 LOW | Advanced Features | `advanced-` | Otimizações incrementais |

---

## Regras Essenciais (Top 10)

### 🔴 query-001: ALWAYS use EXPLAIN ANALYZE
```sql
-- ❌ Errado: query sem análise
SELECT * FROM leads WHERE email LIKE '%@gmail.com';

-- ✅ Correto: analisar antes de deploy
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM leads WHERE email LIKE '%@gmail.com';
-- Verificar: Seq Scan = problema em tabelas grandes
```

### 🔴 query-002: Index columns used in WHERE/JOIN/ORDER BY
```sql
-- ❌ Errado: filtro sem índice
SELECT * FROM leads WHERE status = 'qualified' AND created_at > now() - interval '7 days';

-- ✅ Correto: índice composto
CREATE INDEX idx_leads_status_created ON leads(status, created_at DESC);
```

### 🔴 query-003: Avoid SELECT *
```sql
-- ❌ Errado
SELECT * FROM contacts;

-- ✅ Correto: apenas colunas necessárias
SELECT id, name, email, phone FROM contacts;
```

### 🔴 conn-001: Use connection pooling (Supavisor)
```
-- Supabase usa Supavisor por padrão na porta 6543
-- Transaction mode: melhor para serverless (Vercel, Edge Functions)
-- Session mode: necessário para prepared statements e LISTEN/NOTIFY
```

### 🟠 security-001: Always enable RLS on public tables
```sql
-- ❌ Errado: tabela sem RLS
CREATE TABLE documents (id uuid, content text, user_id uuid);

-- ✅ Correto: RLS habilitado com policy
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own documents"
ON documents FOR SELECT
USING (auth.uid() = user_id);
```

### 🟠 security-002: Use auth.uid() not request headers
```sql
-- ❌ Errado: header manipulável
USING (user_id = current_setting('request.jwt.claims')::json->>'sub');

-- ✅ Correto: função built-in segura
USING (user_id = auth.uid());
```

### 🟠 schema-001: Use UUIDs for primary keys
```sql
-- ✅ Supabase padrão
CREATE TABLE leads (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  -- ...
);
```

### 🟡 lock-001: Keep transactions short
```sql
-- ❌ Errado: transação longa com lock
BEGIN;
  SELECT * FROM leads FOR UPDATE;  -- lock em todas as rows
  -- processamento demorado...
COMMIT;

-- ✅ Correto: lock apenas no necessário
BEGIN;
  UPDATE leads SET status = 'processed'
  WHERE id = $1 AND status = 'pending';  -- lock mínimo
COMMIT;
```

### 🟡 access-001: Use pagination (not OFFSET for large datasets)
```sql
-- ❌ Errado: OFFSET lento em datasets grandes
SELECT * FROM leads ORDER BY created_at OFFSET 10000 LIMIT 20;

-- ✅ Correto: cursor-based pagination
SELECT * FROM leads
WHERE created_at < $last_seen_created_at
ORDER BY created_at DESC
LIMIT 20;
```

### 🔵 monitor-001: Check slow queries
```sql
-- Ver queries lentas no Supabase Dashboard > Reports
-- Ou via pg_stat_statements:
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;
```

---

## Referências
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Performance](https://supabase.com/docs/guides/platform/performance)
- [Supabase RLS](https://supabase.com/docs/guides/auth/row-level-security)
