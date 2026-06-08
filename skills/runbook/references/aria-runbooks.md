# 🤖 Runbooks — Aria (SaaS)

> Runbooks para problemas comuns no Aria, deployado em Vercel + Supabase.

---

## RB-ARIA-001: Deploy Vercel Falhou

**Sintoma:** Deploy status "Error" no dashboard Vercel ou CLI
**Triage:** P1 se afeta produção, P2 se apenas preview

**Investigação:**
1. `cd Aria && npx vercel ls 2>&1 | head -10` → status do último deploy
2. Build logs: `npx vercel inspect <deployment-url> 2>&1`
3. Se build falhou: `npx tsc --noEmit 2>&1` localmente

**Causas comuns:**
- TypeScript error não detectado localmente (versão diferente de types)
- Env var ausente em produção (`vercel env ls`)
- Dependência não instalada (`package-lock.json` desatualizado)
- Timeout de build (projetos grandes > 45s no Hobby)

**Ação:**
- TypeScript: corrigir erro e re-deploy
- Env var: `vercel env add NOME production`
- Dependência: `npm ci && vercel --prod`
- Timeout: otimizar build ou upgrade de plano

---

## RB-ARIA-002: API Retornando 500

**Sintoma:** Frontend mostra erro ou loading infinito. API retorna status 500
**Triage:** P0 se todas as rotas, P1 se rota específica

**Investigação:**
1. `curl -s https://aria-ai-phi.vercel.app/api/health` → health check
2. Vercel Runtime Logs: `npx vercel logs <url> 2>&1 | head -30`
3. Supabase logs: Dashboard → Logs → API
4. Testar rota localmente: `npm run dev` → reproduzir

**Causas comuns:**
- Supabase connection string expirada ou incorreta
- Rate limit de API externa (OpenAI, Anthropic)
- Erro não tratado em handler (throw sem catch)
- Edge function cold start timeout

**Ação:**
- Connection: verificar `SUPABASE_URL` e `SUPABASE_ANON_KEY`
- Rate limit: implementar retry com backoff
- Error handling: adicionar try/catch no handler
- Cold start: otimizar imports, reduzir bundle size

---

## RB-ARIA-003: Supabase Connection Issues

**Sintoma:** Erro "connection refused" ou "too many connections"
**Triage:** P1

**Investigação:**
1. Supabase Dashboard → Database → Active Connections
2. Verificar se Connection Pooler está configurado (Supavisor)
3. Checar se a região do Supabase match a região do Vercel

**Causas comuns:**
- Excedeu limite de conexões do plano Free (max 60 direct)
- Não usando connection pooler (Supavisor/PgBouncer)
- Client criando nova conexão a cada request (não reutilizando)

**Ação:**
- Usar connection pooler: trocar porta 5432 → 6543
- Implementar singleton de client Supabase
- Reduzir idle timeout

---

## RB-ARIA-004: Auth/JWT Problems

**Sintoma:** Usuário logado mas recebe 401, ou sessão expira inesperadamente
**Triage:** P1

**Investigação:**
1. Verificar JWT_SECRET em env vars do Vercel
2. Checar se token está sendo enviado no header Authorization
3. Verificar expiração do token (decode JWT em jwt.io)
4. Supabase Auth → Users → verificar status do usuário

**Causas comuns:**
- JWT_SECRET diferente entre ambientes
- Token expirado e refresh não implementado
- CORS bloqueando header Authorization
- Usuário desativado no Supabase Auth

**Ação:**
- Sincronizar JWT_SECRET: `vercel env add JWT_SECRET production`
- Implementar refresh token flow
- Configurar CORS: permitir header Authorization
