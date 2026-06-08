# 🔐 OWASP Quick Reference — Stack Aria/Febracis

## Top 5 Relevantes para Node.js/TypeScript + Supabase

### 1. Injection (A03:2021)
- **Risco:** SQL injection via inputs não sanitizados
- **Mitigação Supabase:** Usar `.from('table').select()` (parameterized). NUNCA construir SQL com template literals
- **Mitigação Node:** Zod para validação de input. Nunca interpolar user input em queries

### 2. Broken Authentication (A07:2021)
- **Risco:** Sessões fracas, JWT mal implementado
- **Mitigação:** Supabase Auth com RLS. JWT com expiração curta (15min access + refresh token)
- **Check:** `JWT_SECRET` diferente por ambiente. MFA habilitado

### 3. Sensitive Data Exposure (A02:2021)
- **Risco:** Dados pessoais (LGPD) expostos em logs, responses, erros
- **Mitigação:** Pino com `redact`. Nunca retornar stack traces em prod. HTTPS only

### 4. Security Misconfiguration (A05:2021)
- **Risco:** Defaults inseguros, CORS permissivo, headers faltando
- **Mitigação:** Helmet.js para headers. CORS restritivo (apenas domínios do Aria). Rate limiting
- **Check:** `X-Content-Type-Options: nosniff`, `Strict-Transport-Security`, `X-Frame-Options`

### 5. SSRF (A10:2021)
- **Risco:** Edge functions que fazem fetch de URLs fornecidas pelo usuário
- **Mitigação:** Whitelist de domínios permitidos. Validar URL antes de fetch. Bloquear IPs internos
