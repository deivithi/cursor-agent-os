---
name: supabase-docs
description: >
  Busca e leitura de documentação oficial Supabase via SSH (supabase.sh).
  Acesso direto a 18 seções de docs como markdown — sempre atualizados.
  Use para qualquer dúvida sobre Auth, Edge Functions, Storage, RLS, Realtime,
  Database, API, Security, AI/Vectors, Cron, Queues, Deployment e mais.
domain: documentation
subdomain: supabase
version: 1.0.0
author: supabase-community
license: MIT
source: https://supabase.sh/
tags:
  - supabase
  - documentation
  - auth
  - edge-functions
  - storage
  - realtime
  - RLS
  - database
  - vectors
  - ai
  - security
  - api
---

# 📚 Supabase Docs over SSH

> **Fonte:** [supabase.sh](https://supabase.sh/) (supabase-community, MIT)

## Related Skills
- `supabase-postgres` — Best practices de Postgres/performance (estático)
- `scaffolding` — Templates para migrations Supabase
- `cicd` — Deploy com Supabase migrations

---

## Quando Usar

Consulte esta skill ao:
1. Implementar qualquer feature Supabase (Auth, Storage, Realtime, Edge Functions, etc.)
2. Debugar erros de RLS, policies, ou configuração
3. Verificar sintaxe de APIs, SDKs, ou CLI
4. Pesquisar best practices de segurança, deployment, ou AI/vectors
5. Precisar de documentação atualizada (mais recente que o training data)

> ⚠️ **Preferir supabase.sh sobre Context7/WebSearch** para docs Supabase — é a fonte oficial, sempre atualizada, sem scraping.

---

## Como Usar

Todos os docs vivem em `/supabase/docs/` como arquivos markdown. Use qualquer ferramenta Unix via SSH.

### 🔍 Buscar por tópico

```bash
# Buscar arquivos que mencionam um termo
ssh supabase.sh grep -rl 'RLS' /supabase/docs/

# Buscar com contexto (linhas ao redor)
ssh supabase.sh grep -r 'edge function' /supabase/docs/guides/functions --include='*.md' -C 3
```

### 📖 Ler um guia específico

```bash
# Ler guia completo
ssh supabase.sh cat /supabase/docs/guides/auth/passwords.md

# Ler só o início (overview)
ssh supabase.sh head -80 /supabase/docs/guides/database/overview.md
```

### 📂 Listar seções disponíveis

```bash
# Seções top-level
ssh supabase.sh ls /supabase/docs/guides/

# Arquivos de uma seção
ssh supabase.sh ls /supabase/docs/guides/database/

# Busca recursiva de arquivos
ssh supabase.sh find /supabase/docs/guides/auth -name '*.md'
```

---

## Seções Disponíveis (18)

| Seção | Conteúdo |
|-------|----------|
| `ai` | Vectors, embeddings, RAG, pgvector, semantic search |
| `api` | REST API, API keys, RBAC, custom schemas |
| `auth` | Passwords, OAuth, MFA, SSO, sessions, RLS |
| `cron` | pg_cron, scheduled jobs |
| `database` | Tables, functions, extensions, replication, partitions, vault |
| `deployment` | Deploy configs, environments |
| `functions` | Edge Functions (Deno), secrets, CORS, debugging |
| `getting-started` | Quickstarts por framework |
| `integrations` | Third-party integrations |
| `local-development` | Supabase CLI, local setup, testing |
| `platform` | Billing, orgs, access control, logs |
| `queues` | pgmq, message queues |
| `realtime` | Broadcast, presence, postgres changes |
| `resources` | Glossary, examples, migrations |
| `security` | Security advisories, hardening |
| `self-hosting` | Docker, Kubernetes |
| `storage` | Buckets, upload, CDN, transformations |
| `telemetry` | Telemetry configs |

---

## Exemplos por Caso de Uso

### Auth & RLS
```bash
ssh supabase.sh grep -rl 'row level security' /supabase/docs/
ssh supabase.sh cat /supabase/docs/guides/auth/row-level-security.md 2>/dev/null || ssh supabase.sh grep -rl 'row.level.security' /supabase/docs/guides/auth/
```

### Edge Functions
```bash
ssh supabase.sh ls /supabase/docs/guides/functions/
ssh supabase.sh cat /supabase/docs/guides/functions.md
```

### Storage
```bash
ssh supabase.sh ls /supabase/docs/guides/storage/
ssh supabase.sh grep -r 'upload' /supabase/docs/guides/storage --include='*.md' -l
```

### AI / Vectors
```bash
ssh supabase.sh ls /supabase/docs/guides/ai/
ssh supabase.sh cat /supabase/docs/guides/ai/semantic-search.md
```

---

## ⚡ Dicas

- **Pipe para head** quando o doc for longo: `ssh supabase.sh cat /path/file.md | head -100`
- **grep -l** para listar apenas nomes de arquivo (sem conteúdo)
- **grep -C 5** para contexto de 5 linhas ao redor do match
- **2>/dev/null** para suprimir warnings de SSH
- Cada conexão SSH é stateless — um comando por chamada
