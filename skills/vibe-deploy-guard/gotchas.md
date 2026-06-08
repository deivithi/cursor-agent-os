# Gotchas — vibe-deploy-guard

## 1. Falsos Positivos em VDG-01 (API Keys no Frontend)

**Problema:** `NEXT_PUBLIC_SUPABASE_ANON_KEY` e `NEXT_PUBLIC_SUPABASE_URL` sao PROJETADOS para serem publicos. Flaggear como erro confunde.

**Solucao:** Diferenciar chaves publicas por design vs chaves privadas:
- OK no frontend: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
- NUNCA no frontend: qualquer coisa com `SECRET`, `PRIVATE`, `SERVICE_ROLE`, `sk-`, `sk_live_`

---

## 2. RLS USING (true) Intencional (VDG-05)

**Problema:** Tabelas genuinamente publicas (ex: `products`, `categories`, `blog_posts`) DEVEM ter `USING (true)` para SELECT.

**Solucao:** `USING (true)` e aceitavel APENAS para:
- Politicas de SELECT em dados publicos
- NUNCA para INSERT, UPDATE, DELETE
- Documentar explicitamente por que a tabela e publica

---

## 3. console.log vs Logger (VDG-17)

**Problema:** Nem todo `console.log` e um problema. Em desenvolvimento local e util. O problema e em producao.

**Solucao:** Verificar se existe conditional logging:
- OK: `if (process.env.NODE_ENV === 'development') console.log(...)`
- OK: Logger configurado (Winston, Pino) com levels
- PROBLEMA: `console.log` solto sem condicao em codigo de producao

---

## 4. Rate Limiting em Desenvolvimento (VDG-14)

**Problema:** Rate limiting bloqueia o proprio desenvolvedor durante testes locais.

**Solucao:** Desabilitar rate limit em `NODE_ENV === 'development'` ou usar limites muito altos (1000/min) em dev. Nunca deployer sem rate limit em producao.

---

## 5. CORS * em APIs Publicas (VDG-13)

**Problema:** APIs genuinamente publicas (ex: API de dados abertos, CDN) podem precisar de `origin: '*'`.

**Solucao:** `origin: '*'` e aceitavel APENAS se:
- A API nao usa cookies/sessions
- `credentials: false` (NUNCA `true` com `*`)
- Os dados sao genuinamente publicos
- Nao existe acao de escrita (GET-only)

---

## 6. IDs Sequenciais em Tabelas Internas (VDG-06)

**Problema:** IDs sequenciais sao mais eficientes para JOINs e indexacao. Proibir totalmente impacta performance.

**Solucao:** UUID para IDs EXPOSTOS na API/URL. SERIAL para chaves internas nunca expostas ao cliente (ex: tabelas de auditoria, logs).

---

## 7. JWT em Supabase (VDG-16)

**Problema:** Supabase ja gerencia JWT internamente. `supabase.auth.getSession()` retorna tokens gerenciados pelo SDK.

**Solucao:** Se usando Supabase Auth, o SDK ja faz a gestao correta de tokens. VDG-16 aplica quando:
- Voce implementa JWT customizado (fora do Supabase Auth)
- Armazena tokens manualmente em localStorage
- Cria sistema de auth do zero

---

## 8. Gitleaks em Repos com Historico Longo (VDG-18)

**Problema:** Scan completo de repos com 10k+ commits pode demorar minutos.

**Solucao:**
- Scan completo: rodar 1x na configuracao inicial
- CI/CD: scan incremental apenas nos commits da PR (`--log-opts="origin/main..HEAD"`)
- Pre-commit: scan apenas do staged content (instantaneo)

---

## 9. Webhook Signatures Variam por Servico (VDG-10)

**Problema:** Cada servico (Stripe, GitHub, Clerk, Twilio) tem seu proprio metodo de assinatura.

**Solucao:** Usar a lib oficial do servico para verificacao:
- Stripe: `stripe.webhooks.constructEvent(body, sig, secret)`
- GitHub: `crypto.timingSafeEqual(computedSig, headerSig)`
- Clerk: `svix.verify(body, headers)`
- Nao implementar verificacao manual — usar SDK do servico

---

## 10. Edge Functions Supabase e JWT (Relacionado VDG-09/16)

**Problema:** Edge Functions do Supabase rejeitam 100% dos POSTs sem `--no-verify-jwt` no deploy.

**Solucao:** Deploy SEMPRE com `supabase functions deploy <nome> --no-verify-jwt`. Implementar verificacao manual de auth dentro da function se necessario. Este e um gotcha conhecido do nosso ecossistema (ver memory: feedback_supabase_edge_deploy).
