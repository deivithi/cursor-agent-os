# ⚠️ Gotchas — CI/CD & Deployment

> Problemas conhecidos ao fazer deploy e CI/CD. Consulte quando algo falhar.

---

## 1. vercel --prod deploya a branch atual, não necessariamente main

- **Sintoma:** Deploy de produção contém código de feature branch inacabada
- **Causa raiz:** `npx vercel --prod` deploya o diretório local atual, independente da branch git. Se você está na branch `feature/x`, ela vai para produção
- **Solução:** SEMPRE verificar a branch antes de deploy prod: `git branch --show-current` deve retornar `main`
- **Prevenção:** Script `deploy-vercel.sh` inclui check de branch como pre-flight obrigatório
- **Descoberto em:** 2026-03-18

---

## 2. Supabase migration aplicada em ordem errada causa erro de foreign key

- **Sintoma:** `supabase db push` falha com "relation does not exist" para uma tabela que deveria existir
- **Causa raiz:** Migrations são aplicadas em ordem alfabética/timestamp. Se a migration que cria a tabela referenciada tem timestamp posterior à que cria a foreign key, a ordem inverte
- **Solução:** Renomear o arquivo da migration para garantir ordem correta via timestamp
- **Prevenção:** Sempre gerar migrations com `supabase migration new` que gera timestamp automático. Nunca criar manualmente com timestamps inventados
- **Descoberto em:** 2026-03-18

---

## 3. Edge function deploy silenciosamente usa versão antiga se build falha

- **Sintoma:** Edge function deployada não reflete as últimas mudanças — comportamento antigo persiste
- **Causa raiz:** `supabase functions deploy` pode reportar sucesso mesmo quando o build da function falha. A versão anterior permanece ativa
- **Solução:** Após deploy, verificar com `supabase functions list` se o `updated_at` mudou. Testar a function com curl
- **Prevenção:** Sempre verificar output do deploy procurando por "error" ou "warning". Adicionar smoke test pós-deploy
- **Descoberto em:** 2026-03-18

---
