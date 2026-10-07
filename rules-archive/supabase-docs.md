---
globs:
  - "**/*.sql"
  - "**/supabase/**"
  - "**/migrations/**"
description: Supabase docs via SSH — ativa quando trabalha com SQL ou Supabase
---

# 📚 Supabase Docs via SSH

Documentação oficial Supabase disponível via `ssh supabase.sh <comando>`.
18 seções de docs como markdown, navegáveis com Unix tools (grep, find, cat, ls).

**Uso rápido:**
```bash
ssh supabase.sh grep -rl '<termo>' /supabase/docs/
ssh supabase.sh cat /supabase/docs/guides/<seção>/<arquivo>.md
```

Para consultas profundas, use a skill `supabase-docs`.
Para best practices de Postgres, use a skill `supabase-postgres`.
