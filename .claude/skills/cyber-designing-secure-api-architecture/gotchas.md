# ⚠️ Gotchas — Secure API Architecture

---

## 1. CORS com wildcard (*) em API que usa cookies/auth headers

- **Sintoma:** Browser bloqueia request com erro "CORS policy: credential not supported with wildcard origin"
- **Causa raiz:** `Access-Control-Allow-Origin: *` é incompatível com `credentials: include`. Browser rejeita
- **Solução:** Especificar origens permitidas explicitamente: `Access-Control-Allow-Origin: https://aria-ai-phi.vercel.app`
- **Prevenção:** NUNCA usar `*` em APIs que requerem autenticação. Usar whitelist
- **Descoberto em:** 2026-03-18

---

## 2. Rate limiting por IP não funciona atrás de CDN/proxy

- **Sintoma:** Rate limit não é efetivo — requests passam mesmo após exceder limite
- **Causa raiz:** Todas as requests chegam do mesmo IP (CDN/Vercel proxy). Rate limit conta como 1 client
- **Solução:** Rate limit por header `X-Forwarded-For` ou `CF-Connecting-IP` (Cloudflare). Ou por API key/user ID
- **Prevenção:** Testar rate limiting com requests reais de IPs diferentes, não apenas local
- **Descoberto em:** 2026-03-18

---

## 3. API key exposta no frontend JavaScript

- **Sintoma:** API key do serviço externo (OpenAI, Stripe) visível no código fonte do browser
- **Causa raiz:** `NEXT_PUBLIC_*` ou env var sem prefixo correto expõe a variável no bundle client-side
- **Solução:** Mover chamada para API route server-side. API key fica apenas no backend
- **Prevenção:** NUNCA prefixar secrets com `NEXT_PUBLIC_` ou `VITE_`. Auditar: `grep -r "NEXT_PUBLIC_" .env*`
- **Descoberto em:** 2026-03-18

---
