---
name: cicd
description: >
  Workflow de CI/CD e deployment para projetos Vercel e Supabase. Inclui deploy
  automatizado, smoke test pós-deploy, rollback, monitoramento de PRs e cherry-pick
  para produção. Scripts para deploy seguro com verificação integrada.
domain: devops
subdomain: deployment
version: 1.0.0
author: deivithi
tags:
  - cicd
  - deploy
  - vercel
  - supabase
  - rollback
  - smoke-test
  - pr-management
  - cherry-pick
---

# 🚀 CI/CD & Deployment — Deploy Seguro e Automatizado

> **"babysit-pr monitora PR → retenta CI flaky → resolve conflitos → habilita auto-merge."** — Thariq, Anthropic

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Workflow abaixo.
- `scripts/deploy-vercel.sh` — Build + test + deploy Vercel com verificação.
- `scripts/deploy-supabase.sh` — Migrations + edge functions Supabase.
- `scripts/check-deploy-status.sh` — Verifica status do último deploy.
- `references/vercel-patterns.md` — Env vars, domains, rollback, preview deploys.
- `references/supabase-patterns.md` — Migrations, edge functions, branching.
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `product-verification` — Use para smoke test pós-deploy
- `runbook` — Use se o deploy falhar para investigar a causa
- `scaffolding` — Use para gerar config de deploy para novo projeto

---

## 1. Workflow de Deploy Seguro

```
PRE-FLIGHT → BUILD → TEST → DEPLOY → SMOKE TEST → VERIFY → REPORT
     ↓                                      ↓
  [Abort]                              [Rollback]
```

### 1.1 Pre-Flight Checks
Antes de qualquer deploy, verificar:
- [ ] Branch correta? (`main` para prod, `develop` para staging)
- [ ] Todos os testes passam localmente?
- [ ] Não há migrations pendentes não aplicadas?
- [ ] Env vars de produção estão configuradas?
- [ ] Último deploy está healthy?

### 1.2 Build
```bash
# Aria (Vercel)
cd Aria && npm run build 2>&1 | tail -20

# Verificar que build passou sem erros
echo $?  # Deve ser 0
```

### 1.3 Test
```bash
# TypeScript check
npx tsc --noEmit 2>&1

# Testes unitários
npx vitest run 2>&1 | tail -20
```

### 1.4 Deploy
```bash
# Vercel — Preview deploy (staging)
npx vercel 2>&1

# Vercel — Production deploy
npx vercel --prod --yes 2>&1

# Supabase — Aplicar migrations
supabase db push 2>&1

# Supabase — Deploy edge function
supabase functions deploy nome-funcao 2>&1
```

### 1.5 Smoke Test Pós-Deploy
```bash
# Verificar que o deploy está respondendo
curl -s -o /dev/null -w "%{http_code}" https://aria-ai-phi.vercel.app/api/health

# Usar product-verification skill para teste completo
# (referência cruzada com skill product-verification)
```

### 1.6 Rollback (se necessário)
```bash
# Vercel — Listar deploys recentes
npx vercel ls 2>&1 | head -10

# Vercel — Promover deploy anterior para produção
npx vercel promote <deployment-url> --yes 2>&1
```

---

## 2. Patterns por Plataforma

### 2.1 Vercel
Consultar `references/vercel-patterns.md` para:
- **Preview Deploys:** Cada PR gera preview automático
- **Env Vars:** Gerenciar via `vercel env` (dev/preview/production)
- **Domains:** Configurar domínios customizados
- **Rollback:** Promover deploy anterior como produção
- **Monorepo:** Configurar root directory e build command

### 2.2 Supabase
Consultar `references/supabase-patterns.md` para:
- **Migrations:** `supabase db push` vs `supabase migration up`
- **Edge Functions:** Deploy individual vs batch
- **Branching:** Preview branches para testar migrations
- **Secrets:** `supabase secrets set KEY=VALUE`
- **Database Reset:** Apenas em desenvolvimento!

---

## 3. Operações Avançadas

### 3.1 Babysit PR
Monitorar uma PR até merge:
1. Verificar status dos checks
2. Se CI falhou por flake → retrigger
3. Se há conflitos → resolver
4. Se tudo passou → habilitar auto-merge
5. Logar resultado

### 3.2 Cherry-Pick para Produção
Para hotfixes urgentes:
1. Criar worktree isolado
2. Cherry-pick o commit específico
3. Resolver conflitos se houver
4. Criar PR com template de hotfix
5. Deploy direto após aprovação

### 3.3 Deploy Gradual (Canary)
Para mudanças de alto risco:
1. Deploy para 10% do tráfego
2. Monitorar error rate por 15 min
3. Se error rate < baseline → expandir para 50%
4. Se error rate > baseline → rollback automático
5. Se 50% OK → expandir para 100%

---

## 4. ◆ Diamond Gates (Operações Irreversíveis)

As seguintes operações EXIGEM aprovação explícita do usuário:

| Operação | Gate | Motivo |
|----------|------|--------|
| Deploy para produção | ◆ DIAMOND | Irreversível para usuários finais |
| Aplicar migration em prod | ◆ DIAMOND | Alteração de schema é destrutiva |
| Rollback de produção | ◆ DIAMOND | Pode causar downtime |
| Delete de edge function | ◆ DIAMOND | Remove funcionalidade |
| Reset de database | ⛔ BLOQUEADO | Nunca em produção |

---

## 5. Boas Práticas

1. **Sempre smoke test pós-deploy** — Deploy sem verificação é incompleto
2. **Rollback > Debug em produção** — Se algo quebrou, rollback primeiro, investigue depois
3. **Preview deploys para tudo** — Nunca pular direto para produção
4. **Env vars nunca no código** — Usar `vercel env` ou `supabase secrets`
5. **Logs são efêmeros** — Capturar logs importantes antes que expirem (ver runbook gotcha #1)
