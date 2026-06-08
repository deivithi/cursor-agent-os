---
name: vibe-deploy-guard
description: >
  Enforcement automático dos 18 erros de segurança mais comuns em código gerado por IA.
  3 blocos (segredos expostos, autorização inexistente, input inseguro), 3 níveis
  (quick/standard/deep). Ativa automaticamente em qualquer código que toque auth, API,
  database, env, upload ou deploy. Baseado no relatório GitGuardian 2026 (29M secrets
  vazados) e OWASP Top 10. "Vibe coding não é o problema. Vibe deploying é."
domain: security
subdomain: development-hygiene
version: 1.0.0
author: deivithi
license: Apache-2.0
tags:
  - vibe-coding
  - vibe-deploying
  - security-checklist
  - api-keys
  - supabase-rls
  - cors
  - sql-injection
  - rate-limiting
  - jwt
  - gitignore
  - env
  - mass-assignment
  - idor
  - webhook
  - upload
  - deploy
  - owasp
---

# vibe-deploy-guard — Seguranca Anti-Vibe-Deploying

> **"Vibe coding nao e o problema. O problema e vibe DEPLOYING."**
> — Breno Vieira, LionLab | Dados: GitGuardian 2026 (29M secrets vazados, IA = 2x mais vazamentos)

## File Structure
- `SKILL.md` — Voce esta aqui. Workflow + 18 checks.
- `references/checklist-completo.md` — Codigo ERRADO vs CORRETO para cada check.
- `references/fontes.md` — Fontes verificadas (GitGuardian, Veracode, Georgia Tech, OWASP).
- `gotchas.md` — Falsos positivos e edge cases.

## Related Skills
- `security-audit` — Auditoria profunda Trail of Bits. Handoff quando deep scan encontra Critical/High
- `guardrails` — Protecao runtime de agentes. Esta skill protege o CODIGO, nao o agente
- `code-review` — Review geral. vibe-deploy-guard roda ANTES como pre-requisito de seguranca
- `deploy-checklist` — Validacao pre-deploy. Esta skill adiciona o gate de seguranca
- `clean-code-rules` — Patterns de codigo limpo reduzem superficie de ataque

---

## Quando Usar

| Cenario | Nivel |
|---------|-------|
| Qualquer codigo que toque auth, API, DB, env, upload | Quick |
| Commit, PR, code-review | Standard |
| Pre-deploy, novo projeto, auditoria | Deep |
| PR review, CI/CD gate | Standard |
| Codigo gerado por IA (Cursor, Bolt, Lovable, Claude) | Quick (minimo) |

## Quando NAO Usar (Handoff)

- Auditoria profunda com Semgrep + variant analysis → `security-audit`
- Protecao de agente contra prompt injection → `guardrails`
- Pesquisa de vulnerabilidade especifica → `/cyber`

---

## Numeros que Justificam (2026)

| Dado | Fonte |
|------|-------|
| 29M secrets vazados no GitHub | GitGuardian 2026 |
| Commits com IA: 3.2% leak rate (vs 1.5% baseline) | GitGuardian 2026 |
| 45% do codigo IA introduz vulns OWASP Top 10 | Veracode |
| 83% dos Supabase expostos = RLS mal configurado | VibeAppScanner |
| 35 CVEs em 1 mes atribuidos a AI coding tools | Georgia Tech |
| 86% do codigo IA falha contra XSS | CSA Research |

---

## Progressive Disclosure

| Nivel | Trigger | Comportamento |
|-------|---------|---------------|
| **Quick** | Edit/write de codigo | Verificar checks relevantes ao codigo tocado. Flaggear inline |
| **Standard** | Commit, PR, code-review | Checklist completo 18 items. Reportar ✅/❌ por item |
| **Deep** | Pre-deploy, projeto novo, auditoria | Scan automatizado + relatorio + handoff se Critical/High |

---

## BLOCO 1 — Segredos Expostos

### [VDG-01] API Keys Expostas no Frontend

**Risco:** Qualquer usuario abre F12 → DevTools → copia suas chaves.
**2o maior vetor de vazamento** depois do GitHub (GitGuardian 2026).

**ERRADO — IA faz isso:**
```typescript
// .env (frontend)
NEXT_PUBLIC_OPENAI_KEY=sk-proj-abc123...
VITE_SUPABASE_SERVICE_ROLE=eyJhbGciOi...
NEXT_PUBLIC_STRIPE_SECRET=sk_live_...
```

**CORRETO:**
```typescript
// .env (backend APENAS)
OPENAI_API_KEY=sk-proj-abc123...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOi...
STRIPE_SECRET_KEY=sk_live_...

// Frontend so usa chaves PUBLICAS
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...  // anon key = OK, e publica por design
```

**Regra:** Chave privada NUNCA tem prefixo `NEXT_PUBLIC_` ou `VITE_`. Chamadas a APIs pagas SEMPRE via backend route.

---

### [VDG-02] .env Fora do .gitignore

**Risco:** `git add .` manda .env com todas as senhas pro GitHub. Bots encontram em minutos. Mesmo deletando depois, fica no historico de commits.

**ERRADO:**
```
# .gitignore inexistente ou sem .env
node_modules/
```

**CORRETO:**
```gitignore
# .gitignore — CRIAR ANTES DO PRIMEIRO COMMIT
.env
.env.local
.env.*.local
.env.production

# Manter .env.example com estrutura (sem valores reais)
!.env.example
```

**Regra:** `.gitignore` com `.env` ANTES do primeiro commit. Criar `.env.example` com placeholders. Se ja comitou: rotacionar TODAS as chaves + limpar historico com `git filter-branch` ou BFG.

---

### [VDG-03] Secrets em docker-compose.yml

**Risco:** IA gera docker-compose com senhas hardcoded em texto puro para "fazer funcionar".

**ERRADO:**
```yaml
services:
  db:
    environment:
      POSTGRES_PASSWORD: minha_senha_123
      REDIS_PASSWORD: redis_super_secret
```

**CORRETO:**
```yaml
services:
  db:
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      REDIS_PASSWORD: ${REDIS_PASSWORD}
    env_file:
      - .env
```

**Regra:** Zero strings de senha em docker-compose. Usar `${VAR}` + `env_file`. Docker secrets para producao.

---

### [VDG-04] Chamadas de AI Direto do Browser

**Risco:** Frontend chamando OpenAI/Anthropic expoe API key no Network tab. Atacante copia e usa sua cota.

**ERRADO:**
```typescript
// components/Chat.tsx — NUNCA
const response = await fetch('https://api.openai.com/v1/chat/completions', {
  headers: { 'Authorization': `Bearer ${process.env.NEXT_PUBLIC_OPENAI_KEY}` }
});
```

**CORRETO:**
```typescript
// app/api/chat/route.ts — Backend proxy
export async function POST(req: Request) {
  const { message } = await req.json();
  // Chave NUNCA sai do backend
  const response = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [{ role: 'user', content: message }],
  });
  return Response.json(response);
}

// Frontend chama SUA API, nao a da OpenAI
const res = await fetch('/api/chat', { method: 'POST', body: JSON.stringify({ message }) });
```

**Regra:** Frontend → sua API route → servico externo. Chave fica no backend.

---

## BLOCO 2 — Autorizacao Inexistente

### [VDG-05] Supabase sem RLS (ou com USING true)

**Risco:** Sem RLS, qualquer um com a anon key (publica) acessa TODOS os dados. 83% dos Supabase expostos em 2026. IA gera `USING (true)` para testes passarem.

**ERRADO:**
```sql
-- Tabela sem RLS (padrao ao criar)
CREATE TABLE profiles (id uuid, name text, email text);
-- Ou pior: RLS habilitado mas politica aberta
CREATE POLICY "allow_all" ON profiles FOR ALL USING (true);
```

**CORRETO:**
```sql
-- Habilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Politica: usuario so ve seus proprios dados
CREATE POLICY "users_own_data" ON profiles
  FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Tabela publica (ex: produtos) — USING (true) so para SELECT
CREATE POLICY "public_read" ON products
  FOR SELECT USING (true);
CREATE POLICY "admin_write" ON products
  FOR INSERT USING (auth.jwt() ->> 'role' = 'admin');
```

**Regra:** RLS habilitado em TODAS as tabelas. `USING (true)` so para SELECT em dados genuinamente publicos. Sempre usar `auth.uid()`, nunca confiar em ID vindo do client.

---

### [VDG-06] IDs Sequenciais e Previsiveis

**Risco:** Atacante incrementa `/api/users/1`, `/api/users/2`... e enumera todos os usuarios (IDOR).

**ERRADO:**
```sql
CREATE TABLE users (id SERIAL PRIMARY KEY, ...);
-- /api/users/1, /api/users/2, /api/users/3...
```

**CORRETO:**
```sql
CREATE TABLE users (id UUID DEFAULT gen_random_uuid() PRIMARY KEY, ...);
-- /api/users/a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

**Regra:** UUID para todos os IDs publicos. IDs sequenciais so para chaves internas nao expostas na API.

---

### [VDG-07] Logica de Autorizacao so no Frontend

**Risco:** Esconder botao no React NAO protege a rota. Atacante chama URL direto pelo terminal.

**ERRADO:**
```tsx
// Frontend "protege" escondendo o botao
{user.role === 'admin' && <button onClick={deleteUser}>Deletar</button>}
// Mas a API route /api/users/delete nao verifica role...
```

**CORRETO:**
```typescript
// API route SEMPRE verifica
export async function DELETE(req: Request) {
  const session = await getSession(req);
  if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 });

  const userRole = await getUserRole(session.user.id);
  if (userRole !== 'admin') return Response.json({ error: 'Sem permissao' }, { status: 403 });

  // So aqui executa a acao
  await deleteUser(params.id);
}
```

**Regra:** Frontend controla UX (o que mostrar). Backend controla ACESSO (quem pode). Ambos necessarios.

---

### [VDG-08] Roles de Admin Hardcoded no Codigo

**Risco:** Se repo publico, atacante sabe quem sao os admins e quem atacar.

**ERRADO:**
```typescript
const ADMINS = ['deivithi@empresa.com', 'joao@empresa.com'];
function isAdmin(email: string) { return ADMINS.includes(email); }
```

**CORRETO:**
```typescript
// Role no banco de dados, nunca no codigo
async function isAdmin(userId: string): Promise<boolean> {
  const { data } = await supabase
    .from('user_roles')
    .select('role')
    .eq('user_id', userId)
    .single();
  return data?.role === 'admin';
}
```

**Regra:** Roles no banco. Zero emails/IDs hardcoded no codigo.

---

### [VDG-09] API Routes sem Autenticacao

**Risco:** API exposta sem middleware. Qualquer um com a URL acessa seu backend.

**ERRADO:**
```typescript
// app/api/users/route.ts — sem verificacao nenhuma
export async function GET() {
  const users = await db.query('SELECT * FROM users');
  return Response.json(users);
}
```

**CORRETO:**
```typescript
// middleware.ts — protege TODAS as rotas /api/
import { NextResponse } from 'next/server';
import { getSession } from '@/lib/auth';

export async function middleware(req: Request) {
  const session = await getSession(req);
  if (!session) {
    return NextResponse.json({ error: 'Nao autenticado' }, { status: 401 });
  }
  return NextResponse.next();
}

export const config = { matcher: '/api/:path*' };
```

**Regra:** Middleware de autenticacao em TODAS as API routes. Whitelist explicita para rotas publicas.

---

### [VDG-10] Webhooks sem Verificacao de Assinatura

**Risco:** Qualquer um pode enviar POST falso para seu endpoint de webhook.

**ERRADO:**
```typescript
// Aceita qualquer POST sem verificar origem
export async function POST(req: Request) {
  const data = await req.json();
  await processPayment(data); // Confia cegamente
}
```

**CORRETO:**
```typescript
import crypto from 'crypto';

export async function POST(req: Request) {
  const body = await req.text();
  const signature = req.headers.get('stripe-signature');

  // Verificar assinatura do servico
  const expectedSig = crypto
    .createHmac('sha256', process.env.WEBHOOK_SECRET!)
    .update(body)
    .digest('hex');

  if (signature !== expectedSig) {
    return Response.json({ error: 'Assinatura invalida' }, { status: 401 });
  }

  const data = JSON.parse(body);
  await processPayment(data);
}
```

**Regra:** Todo webhook verifica assinatura HMAC do servico emissor. Nunca confiar no corpo sem verificar.

---

## BLOCO 3 — Input e Comunicacao Inseguros

### [VDG-11] Mass Assignment

**Risco:** Backend salva qualquer campo que o client enviar. Atacante adiciona `role: 'admin'`, `credits: 999999`.

**ERRADO:**
```typescript
// Salva TUDO que vem do request
const userData = await req.json();
await db.insert('users', userData); // Atacante envia { role: 'admin', credits: 999 }
```

**CORRETO:**
```typescript
import { z } from 'zod';

const CreateUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  // SEM role, SEM credits — campos controlados pelo sistema
});

const parsed = CreateUserSchema.safeParse(await req.json());
if (!parsed.success) return Response.json({ error: 'Dados invalidos' }, { status: 400 });

await db.insert('users', parsed.data); // So campos permitidos
```

**Regra:** Validar com Zod/Pydantic/Joi. Whitelist de campos explicita. Nunca `...req.body` direto no banco.

---

### [VDG-12] SQL Injection

**Risco:** Concatenacao de strings em queries. Atacante insere `' OR 1=1 --` e acessa tudo.

**ERRADO:**
```typescript
// NUNCA concatenar
const query = `SELECT * FROM users WHERE email = '${email}'`;
```

**CORRETO:**
```typescript
// Queries parametrizadas
const { data } = await supabase.from('users').select().eq('email', email);

// Ou com Prisma/Drizzle
const user = await prisma.user.findUnique({ where: { email } });

// Ou SQL parametrizado
const result = await db.query('SELECT * FROM users WHERE email = $1', [email]);
```

**Regra:** Zero concatenacao de strings em SQL. Usar ORM (Prisma, Drizzle) ou queries parametrizadas.

---

### [VDG-13] CORS Aberto

**Risco:** `origin: '*'` permite qualquer site chamar sua API. Site malicioso age em nome do usuario logado.

**ERRADO:**
```typescript
// Permite QUALQUER origem
app.use(cors({ origin: '*', credentials: true }));
```

**CORRETO:**
```typescript
const ALLOWED_ORIGINS = [
  'https://meuapp.com',
  'https://www.meuapp.com',
  process.env.NODE_ENV === 'development' ? 'http://localhost:3000' : '',
].filter(Boolean);

app.use(cors({
  origin: ALLOWED_ORIGINS,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
}));
```

**Regra:** CORS com lista explicita de origens permitidas. NUNCA `*` com `credentials: true`.

---

### [VDG-14] Sem Rate Limiting

**Risco:** Sem limite, atacante faz brute force no login, spam de emails, esgota creditos de IA, DDoS.

**ERRADO:**
```typescript
// Sem nenhum limite
export async function POST(req: Request) {
  const { email, password } = await req.json();
  return await login(email, password);
}
```

**CORRETO:**
```typescript
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '1 m'), // 10 tentativas por minuto
});

export async function POST(req: Request) {
  const ip = req.headers.get('x-forwarded-for') ?? '127.0.0.1';
  const { success } = await ratelimit.limit(ip);
  if (!success) return Response.json({ error: 'Muitas tentativas' }, { status: 429 });

  const { email, password } = await req.json();
  return await login(email, password);
}
```

**Regra:** Rate limit em login, signup, endpoints de IA, qualquer endpoint critico. Por IP minimo.

---

### [VDG-15] Upload de Arquivos sem Restricao

**Risco:** Atacante envia HTML com JS malicioso, PHP para execucao remota, ou 10GB de imagem para DDoS.

**ERRADO:**
```typescript
// Aceita QUALQUER arquivo sem verificar
const file = await req.formData();
await saveFile(file.get('upload'));
```

**CORRETO:**
```typescript
import { randomUUID } from 'crypto';
import path from 'path';

const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
const MAX_SIZE = 5 * 1024 * 1024; // 5MB

export async function POST(req: Request) {
  const formData = await req.formData();
  const file = formData.get('upload') as File;

  // Verificar tipo REAL (nao confiar na extensao)
  if (!ALLOWED_TYPES.includes(file.type)) {
    return Response.json({ error: 'Tipo nao permitido' }, { status: 400 });
  }

  // Verificar tamanho
  if (file.size > MAX_SIZE) {
    return Response.json({ error: 'Arquivo muito grande (max 5MB)' }, { status: 400 });
  }

  // Nome aleatorio (evita path traversal)
  const safeName = `${randomUUID()}${path.extname(file.name)}`;

  // Salvar em bucket separado do codigo
  await supabase.storage.from('uploads').upload(safeName, file);
}
```

**Regra:** Verificar tipo real + tamanho maximo + nome aleatorio. Salvar em bucket separado.

---

### [VDG-16] JWT Mal Implementado

**Risco:** JWT em localStorage e acessivel via XSS. Sem verificar assinatura, qualquer um forja tokens.

**ERRADO:**
```typescript
// Frontend — localStorage vulneravel a XSS
localStorage.setItem('token', jwt);

// Backend — nao verifica assinatura
const payload = JSON.parse(atob(token.split('.')[1])); // Decodifica sem verificar!
```

**CORRETO:**
```typescript
// Backend — gerar com assinatura e expiracao
import jwt from 'jsonwebtoken';

const token = jwt.sign(
  { userId: user.id, role: user.role },
  process.env.JWT_SECRET!,
  { expiresIn: '1h' }
);

// Enviar como httpOnly cookie (JS nao acessa)
res.setHeader('Set-Cookie', [
  `token=${token}; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=3600`
]);

// Backend — verificar com assinatura
const decoded = jwt.verify(token, process.env.JWT_SECRET!);
```

**Regra:** JWT com `jwt.verify()` (nao decode manual). Cookie `HttpOnly; Secure; SameSite=Strict`. Expiracao curta.

---

### [VDG-17] Erros Detalhados em Producao

**Risco:** Stack traces, logs de debug, console.log no browser = mapa completo para atacante.

**ERRADO:**
```typescript
// Producao expondo tudo
catch (error) {
  console.error(error); // Stack trace no console do browser
  return Response.json({
    error: error.message,
    stack: error.stack,
    query: sql, // Expoe a query!
  }, { status: 500 });
}
```

**CORRETO:**
```typescript
catch (error) {
  // Log interno (Sentry, Datadog, etc.)
  logger.error('Payment failed', { error, userId: session.user.id });

  // Resposta generica para o usuario
  return Response.json(
    { error: 'Erro interno. Tente novamente.' },
    { status: 500 }
  );
}
```

**Regra:** Erro generico para o usuario. Detalhes so em ferramentas de logging (Sentry, Datadog). Zero `console.log` com dados sensiveis em producao.

---

### [VDG-18] Git History nao Escaneado

**Risco:** Mesmo deletando secrets, ficam no historico de commits. Bots encontram em minutos.

**Verificacao:**
```bash
# Instalar gitleaks (pre-commit hook)
brew install gitleaks  # ou scoop install gitleaks (Windows)

# Scan do historico completo
gitleaks detect --source . --verbose

# Scan em CI/CD (a cada PR)
gitleaks detect --source . --log-opts="origin/main..HEAD"

# TruffleHog — verifica se credentials ainda estao ativas
trufflehog git file://. --only-verified
```

**Regra:** Gitleaks como pre-commit hook. TruffleHog no CI/CD. Scan do historico antes de tornar repo publico.

---

## Checklist Pre-Deploy (copiar e colar)

```
BLOCO 1 — Segredos Expostos
[ ] [VDG-01] Nenhuma chave privada tem prefixo NEXT_PUBLIC_ ou VITE_
[ ] [VDG-02] .env esta no .gitignore + existe .env.example
[ ] [VDG-03] docker-compose.yml sem senhas hardcoded
[ ] [VDG-04] Chamadas de AI passam por proxy no backend

BLOCO 2 — Autorizacao
[ ] [VDG-05] RLS habilitado em TODAS as tabelas do Supabase
[ ] [VDG-06] IDs publicos sao UUIDs, nao integers sequenciais
[ ] [VDG-07] Toda API route verifica autenticacao E autorizacao
[ ] [VDG-08] Roles de admin estao no banco, nao hardcoded
[ ] [VDG-09] Middleware de auth protege todas as rotas /api/
[ ] [VDG-10] Webhooks verificam assinatura do servico

BLOCO 3 — Input e Comunicacao
[ ] [VDG-11] Input validado com Zod/Pydantic (whitelist de campos)
[ ] [VDG-12] Zero concatenacao de strings em queries SQL
[ ] [VDG-13] CORS com origens especificas, nao *
[ ] [VDG-14] Endpoints criticos tem rate limiting
[ ] [VDG-15] Uploads verificam tipo, tamanho, nome aleatorio
[ ] [VDG-16] JWTs verificados no backend com assinatura + httpOnly cookie
[ ] [VDG-17] Erros em producao nao expoem detalhes internos
[ ] [VDG-18] Git history escaneado com trufflehog/gitleaks
```

---

## Handoff Points

| Quando | Repassar para | Condicao |
|--------|--------------|----------|
| Finding Critical/High no deep scan | `security-audit` | Auditoria profunda Trail of Bits necessaria |
| Review de codigo em andamento | `code-review` | vibe-deploy-guard e pre-requisito, depois review normal |
| Protecao runtime de agente | `guardrails` | Input/Output/Action guard para agentes IA |
| Pipeline CI/CD | `cicd` | Integrar como gate de seguranca no deploy |
| Projeto Supabase + Vercel | `pulso-finance` | Aplica automaticamente ao stack Pulso |
| Vulnerability research especifica | `/cyber` | Router de 572 skills de cybersecurity |
