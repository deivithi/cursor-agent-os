# ⚠️ Gotchas — OWASP Secure Coding Practices

---

## 1. Zod validation no frontend não substitui validação no backend

- **Sintoma:** Input malicioso passa direto para o banco — validação Zod existe no form React mas não no handler de API
- **Causa raiz:** Validação client-side (Zod no React) pode ser bypassada enviando request direto para a API. A API aceita qualquer payload
- **Solução:** DUPLICAR validação Zod no handler do backend. O schema deve ser compartilhado ou idêntico
- **Prevenção:** Padrão Aria: SEMPRE definir schema Zod no backend, importar no frontend. Nunca o contrário
- **Descoberto em:** 2026-03-18

---

## 2. console.log com dados sensíveis vai para Vercel Logs

- **Sintoma:** CPF, email ou token de acesso aparecem nos Vercel Runtime Logs
- **Causa raiz:** `console.log(req.body)` durante debug não foi removido. Vercel loga stdout/stderr
- **Solução:** Remover todos os `console.log` de dados sensíveis. Usar logger estruturado (Pino) com redação de campos
- **Prevenção:** Configurar Pino com `redact: ['*.cpf', '*.email', '*.token', '*.password']`
- **Descoberto em:** 2026-03-18

---

## 3. JWT secret compartilhado entre ambientes (dev/staging/prod)

- **Sintoma:** Token gerado em dev funciona em produção — ambiente comprometido pode escalar
- **Causa raiz:** Mesmo `JWT_SECRET` em todos os ambientes. Se dev é comprometido, attacker gera tokens válidos para prod
- **Solução:** Secret único por ambiente. `vercel env add JWT_SECRET production` com valor diferente de dev
- **Prevenção:** Auditar: `vercel env ls` — garantir que secrets são diferentes entre environments
- **Descoberto em:** 2026-03-18

---
