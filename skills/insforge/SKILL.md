---
name: insforge
description: >
  InsForge — BaaS agentic-first, alternativa self-host ao Supabase com MCP nativo.
  Auth, Database (Postgres+PostgREST), Storage S3, AI Gateway, Edge Functions (Deno),
  Realtime, Schedules, Email, Deployments. SDK: @insforge/sdk. Docker Compose.
  Use para backend operado por agentes, self-hosting, prototipagem agentic-first.
domain: backend
subdomain: baas
version: 1.0.0
author: InsForge Team
license: Apache-2.0
source: https://github.com/InsForge/InsForge
tags:
  - insforge
  - baas
  - self-host
  - backend-agentic
  - alternativa-supabase
  - mcp
  - postgres
  - postgrest
  - deno
  - edge-functions
  - auth
  - storage
  - realtime
  - ai-gateway
---

# 🔨 InsForge — Backend Agentic-First

> **Fonte:** [InsForge/InsForge](https://github.com/InsForge/InsForge) (Apache 2.0)

## Related Skills

- `supabase-docs` — Documentação oficial Supabase (comparação direta)
- `supabase-postgres` — Best practices Postgres (aplicável ao InsForge também)
- `mcp-builder` — Criar MCP servers custom
- `scaffolding` — Templates para projetos com backend

---

## Quando Usar

1. Precisa de backend **operado por agentes** via MCP (criar tabelas, deploy functions, gerenciar auth — tudo via tool calls)
2. Requisito de **self-hosting completo** (Docker Compose, sem dependência de cloud)
3. **Prototipagem agentic-first** — agente cria o backend inteiro sem dashboard manual
4. Reduzir **vendor lock-in** do Supabase em projetos não-críticos
5. Código menciona `@insforge/sdk`, `createClient` InsForge, ou MCP tools InsForge

> ⚠️ **Para produção atual (Pulso Finance, Febracis):** manter Supabase. InsForge é para novos experimentos e self-host.

---

## Decision Tree: InsForge vs Supabase

```
Precisa de managed hosting confiável? → Supabase
Precisa de self-host completo?        → InsForge ✅
Agente deve criar backend sozinho?    → InsForge ✅ (MCP nativo)
Projeto em produção existente?        → Supabase (não migrar)
Prototipagem rápida com agentes?      → InsForge ✅
Ecossistema maduro + community?       → Supabase
```

---

## Setup Rápido (Docker Compose)

### Pré-requisitos

- Docker + Docker Compose
- Node.js (para SDK)

### 1. Subir Instância

```bash
git clone https://github.com/InsForge/InsForge.git
cd InsForge
cp .env.example .env
# Editar .env com secrets (JWT_SECRET, API_KEY, etc.)
docker compose up -d
```

**Serviços:**
| Porta | Serviço |
|-------|---------|
| 3000 | Backend API |
| 5430 | PostgREST |
| 7130 | Dashboard (+ MCP connect) |
| 7133 | Deno runtime |

### 2. Conectar MCP Server

Abrir `localhost:7130` → botão "Connect MCP" → copiar configuração para Claude Code `settings.json`.

### 3. Verificar

```
Prompt: "call InsForge MCP's fetch-docs tool"
```

---

## SDK — Patterns Essenciais

### Instalar

```bash
npm install @insforge/sdk@latest
```

### Inicializar

```typescript
import { createClient } from '@insforge/sdk';

const insforge = createClient(
  process.env.INSFORGE_URL!,    // ex: http://localhost:3000
  process.env.INSFORGE_ANON_KEY! // da .env
);
```

### Database (CRUD)

```typescript
// Listar
const { data } = await insforge.database.from('posts').select('*');

// Inserir
await insforge.database.from('posts').insert({ title: 'Hello', body: '...' });

// Filtrar
const { data } = await insforge.database
  .from('posts')
  .select('*')
  .eq('author_id', userId);
```

### Auth

```typescript
// Sign up
await insforge.auth.signUp({ email, password });

// Sign in
const { session } = await insforge.auth.signIn({ email, password });

// OAuth (Google, GitHub)
await insforge.auth.signInWithOAuth({ provider: 'google' });
```

### Storage

```typescript
// Upload
await insforge.storage.from('avatars').upload('user.png', file);

// Download URL
const url = insforge.storage.from('avatars').getPublicUrl('user.png');
```

### AI Gateway

```typescript
// OpenAI-compatible — multi-model via OpenRouter
const response = await insforge.ai.chat({
  model: 'anthropic/claude-sonnet-4-20250514',
  messages: [{ role: 'user', content: 'Hello' }]
});
```

### Edge Functions

```typescript
// Invocar
const result = await insforge.functions.invoke('my-function', {
  body: { key: 'value' }
});
```

### Realtime

```typescript
// Escutar canal
insforge.realtime.channel('chat').on('message', (msg) => {
  console.log(msg);
}).subscribe();
```

---

## Schema Patterns (do Plugin Oficial)

### Social Graph (follows, likes)

```sql
CREATE TABLE follows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_following ON follows(following_id);
```

### Multi-Tenant (org-scoped com RLS)

```sql
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE org_members (
  org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member',
  PRIMARY KEY (org_id, user_id)
);

-- RLS policy
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "org_members_only" ON projects
  USING (org_id IN (
    SELECT org_id FROM org_members WHERE user_id = auth.uid()
  ));
```

### Junction Table (many-to-many)

```sql
CREATE TABLE post_tags (
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, tag_id)
);

CREATE INDEX idx_post_tags_tag ON post_tags(tag_id);
```

---

## MCP Tools Disponíveis

Após conectar o MCP server:

| Tool | Descrição |
|------|-----------|
| `fetch-docs` | Buscar documentação SDK atualizada |
| `download-template` | Scaffold projeto com URL+key pré-configurados |
| Schema management | Criar/alterar tabelas, RLS policies |
| Bucket creation | Gerenciar storage buckets |
| Function deployment | Deploy edge functions Deno |
| Secret management | Gerenciar secrets criptografados |

---

## Gotchas

1. **Tailwind CSS:** InsForge usa v3.4 — não fazer upgrade para v4
2. **Backend imports:** ESM-style com extensão `.js` (ex: `import { x } from './y.js'`)
3. **Respostas da API:** Backend retorna JSON raw, **não** `{ data }` wrapper
4. **MCP requer Docker:** O MCP server só funciona com instância InsForge rodando
5. **Shared schemas:** Mudanças de contrato → editar `@insforge/shared-schemas` primeiro, depois consumidores
6. **PostgREST:** Porta 5430, não confundir com a API principal (3000)

---

## Referências

- 📦 Repositório: https://github.com/InsForge/InsForge
- 🌐 Cloud: https://insforge.dev
- 💬 Discord: https://discord.com/invite/MPxwj5xVvW
- 📄 Licença: Apache 2.0
- 🧠 Memória: `reference_insforge.md`
