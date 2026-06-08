# 🌐 API Security Checklist

## Autenticação
- [ ] JWT com expiração curta (15min access token)
- [ ] Refresh token com rotação
- [ ] Secret diferente por ambiente
- [ ] MFA para endpoints admin

## Autorização
- [ ] RBAC ou ABAC implementado
- [ ] Supabase RLS para acesso a dados
- [ ] Endpoint-level authorization (não apenas autenticação)
- [ ] BOLA (Broken Object Level Authorization) testado

## Input Validation
- [ ] Zod/Joi em TODOS os endpoints
- [ ] Content-Type validation
- [ ] Request size limits
- [ ] File upload validation (tipo, tamanho, conteúdo)

## Rate Limiting
- [ ] Por API key/user (não por IP se atrás de proxy)
- [ ] Diferentes limites por endpoint (auth = mais restritivo)
- [ ] Headers de rate limit na response (X-RateLimit-*)
- [ ] 429 com Retry-After header

## CORS
- [ ] Origens explícitas (nunca *)
- [ ] Methods restritos (GET, POST, PUT, DELETE)
- [ ] Headers permitidos específicos
- [ ] Preflight cache (Access-Control-Max-Age)

## Headers de Segurança
- [ ] Strict-Transport-Security (HSTS)
- [ ] X-Content-Type-Options: nosniff
- [ ] X-Frame-Options: DENY
- [ ] Content-Security-Policy
- [ ] Referrer-Policy: strict-origin-when-cross-origin

## Logging & Monitoring
- [ ] Request/response logging (sem dados sensíveis)
- [ ] Rate limit violations logadas
- [ ] Auth failures logados
- [ ] Alertas para padrões anômalos
