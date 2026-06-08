# Checklist Completo — vibe-deploy-guard

> Referencia expandida com evidencias e metricas para cada check.
> Para codigo ERRADO vs CORRETO detalhado, ver `SKILL.md`.

## Metricas de Contexto (2026)

| Metrica | Valor | Fonte |
|---------|-------|-------|
| Secrets vazados no GitHub (2025) | 28.65 milhoes | GitGuardian 2026 |
| Aumento YoY | +34% | GitGuardian 2026 |
| Leak rate em commits com IA | 3.2% | GitGuardian 2026 |
| Leak rate baseline (sem IA) | 1.5% | GitGuardian 2026 |
| Aumento leaks de AI-service keys | +81% YoY | GitGuardian 2026 |
| Codigo IA com vulns OWASP | 45% | Veracode |
| Taxa de falha contra XSS | 86% | CSA Research |
| Taxa de falha contra log injection | 88% | CSA Research |
| Supabase expostos por RLS | 83% | VibeAppScanner |
| CVEs de AI tools (marco 2026) | 35 em 1 mes | Georgia Tech |
| Codigo IA referenciando pacotes inexistentes | 20% | Slopsquatting research |

---

## Priorizacao por Impacto

### Criticos (resolver IMEDIATO — data breach direto)
1. **VDG-01** API keys no frontend — acesso direto a servicos pagos
2. **VDG-02** .env no git — todas as senhas expostas para sempre
3. **VDG-05** Sem RLS — qualquer um acessa todos os dados
4. **VDG-12** SQL Injection — acesso total ao banco

### Altos (resolver antes de producao)
5. **VDG-04** AI direto do browser — cota estourada + key exposta
6. **VDG-07** Auth so no frontend — qualquer um acessa API
7. **VDG-09** Routes sem auth — API completamente aberta
8. **VDG-11** Mass assignment — escalacao de privilegios
9. **VDG-16** JWT inseguro — sessoes forjadas

### Medios (resolver no proximo sprint)
10. **VDG-03** Secrets em docker-compose — risco se repo publico
11. **VDG-06** IDs sequenciais — IDOR com impacto variavel
12. **VDG-08** Admin hardcoded — info leak se repo publico
13. **VDG-10** Webhook sem assinatura — acoes falsas
14. **VDG-13** CORS aberto — CSRF em nome do usuario
15. **VDG-14** Sem rate limit — brute force, DDoS, custo
16. **VDG-15** Upload sem restricao — malware, DDoS

### Baixos (backlog — boas praticas)
17. **VDG-17** Erros detalhados — info leak para atacante
18. **VDG-18** Git history — historico nao escaneado

---

## Comandos de Verificacao Rapida

```bash
# VDG-01: Buscar keys privadas com prefixo publico
grep -rn "NEXT_PUBLIC_.*SECRET\|NEXT_PUBLIC_.*PRIVATE\|NEXT_PUBLIC_.*sk-\|VITE_.*SECRET\|VITE_.*sk-" .

# VDG-02: Verificar .gitignore
grep -q ".env" .gitignore && echo "OK" || echo "FALHA: .env nao esta no .gitignore"

# VDG-03: Buscar senhas hardcoded em docker-compose
grep -n "PASSWORD.*=.*['\"]" docker-compose*.yml 2>/dev/null

# VDG-04: Buscar chamadas diretas a APIs de AI no frontend
grep -rn "api.openai.com\|api.anthropic.com\|api.together.xyz" src/ components/ app/ pages/ 2>/dev/null

# VDG-05: Verificar RLS no Supabase (via SQL)
# SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND NOT rowsecurity;

# VDG-06: Buscar SERIAL/INTEGER como primary key
grep -rn "SERIAL PRIMARY KEY\|INTEGER PRIMARY KEY\|INT PRIMARY KEY" migrations/ supabase/ 2>/dev/null

# VDG-08: Buscar emails/roles hardcoded
grep -rn "ADMINS\s*=\|isAdmin.*@\|role.*=.*['\"]admin['\"]" src/ app/ 2>/dev/null

# VDG-12: Buscar concatenacao SQL
grep -rn "SELECT.*\${.*}\|INSERT.*\${.*}\|UPDATE.*\${.*}\|DELETE.*\${.*}" src/ app/ 2>/dev/null

# VDG-13: Buscar CORS aberto
grep -rn "origin.*['\"]\\*['\"]\|Access-Control-Allow-Origin.*\\*" src/ app/ 2>/dev/null

# VDG-17: Buscar console.log em producao
grep -rn "console\.\(log\|error\|warn\|debug\)" src/ app/ --include="*.ts" --include="*.tsx" 2>/dev/null

# VDG-18: Scan com gitleaks
gitleaks detect --source . --verbose 2>/dev/null || echo "gitleaks nao instalado"
```

---

## Stack-Specific Notes

### Supabase + Next.js + Vercel (nosso stack principal)
- `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_ANON_KEY` sao seguros no frontend (by design)
- `SUPABASE_SERVICE_ROLE_KEY` NUNCA no frontend — so em API routes ou Edge Functions
- RLS e a primeira linha de defesa — tudo mais e complementar
- Edge Functions: deploy com `--no-verify-jwt` (caso contrario 100% POST = 401)
- Vercel auto-seta variaveis de ambiente — verificar que nao expoe em build logs

### n8n (nosso runtime de automacao)
- Credenciais armazenadas criptografadas no banco do n8n
- Webhooks n8n devem usar Header Auth ou HMAC verification
- Code nodes rodam em sandbox V8 — nao tem acesso a filesystem
- Nunca logar dados sensiveis em Code nodes (aparecem nos execution logs)
