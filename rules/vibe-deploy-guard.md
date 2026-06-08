# vibe-deploy-guard — Enforcement Automatico de Seguranca

> Ativa skill `.claude/skills/vibe-deploy-guard/SKILL.md` automaticamente.

## Ativacao

Ao editar, criar ou revisar codigo que toque:
- **Auth/Sessions:** login, signup, JWT, tokens, sessions, middleware, getSession
- **API Routes:** route.ts, route.js, api/, endpoints, handlers
- **Database:** queries SQL, Supabase client, Prisma, Drizzle, migrations
- **Environment:** .env, docker-compose, secrets, API keys
- **Upload:** file upload, formData, storage, bucket
- **Deploy:** build, deploy, production, CI/CD
- **CORS:** cors, origin, Access-Control
- **Input:** req.body, req.json(), form data, user input

## Comportamento

1. **Ao escrever codigo:** Verificar mentalmente os 18 checks VDG-01 a VDG-18 no codigo tocado. Flaggear inline se encontrar violacao.

2. **Ao revisar/commitar:** Reportar checklist dos items relevantes com ✅/❌.

3. **Ao deployer:** Rodar checklist completo. Bloquear deploy se houver Critical.

## Checks Criticos (bloquear SEMPRE)

- VDG-01: Chave privada com prefixo NEXT_PUBLIC_ ou VITE_
- VDG-02: .env fora do .gitignore
- VDG-05: Tabela Supabase sem RLS
- VDG-12: Concatenacao de strings em SQL

## Consultar gotchas.md para falsos positivos conhecidos

Antes de flaggear: verificar se o caso nao e um edge case documentado (ex: NEXT_PUBLIC_SUPABASE_ANON_KEY e OK).
