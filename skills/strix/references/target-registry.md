# Strix — Registro de Alvos do Ecossistema

## Grupos de Scan

### Grupo Crítico (Semanal — segunda 03h BRT)

| Alvo | Target | Modo | Instrução |
|------|--------|------|-----------|
| Aria URL | `https://aria-ai-phi.vercel.app` | deep | Auth bypass, IDOR, Stripe webhook, SSE injection, RLS bypass |
| Aria codebase | `./Aria` | standard | Secrets, SQL injection, mass assignment, CORS, JWT |
| Aria agent | `./Aria/agent` | standard | FastAPI injection, dependency confusion, SSRF |

### Grupo Standard (Semanal — quarta 03h BRT)

| Alvo | Target | Modo | Instrução |
|------|--------|------|-----------|
| Pulso Finance URL | `https://pulsofinance.vercel.app` | standard | IDOR transações, RLS bypass, auth manipulation, XSS monetário |
| n8n local | `http://localhost:5678` | standard | Webhook auth bypass, SSRF, credential leakage, admin access |

### Grupo Light (Mensal — 1º do mês 03h BRT)

| Alvo | Target | Modo | Instrução |
|------|--------|------|-----------|
| AI Landing | `https://ai-landing.netlify.app` | quick | XSS em formulário, CORS |
| SureThing | URL Netlify | quick | XSS, localStorage exposure |
| FIO-IA | `./automacoes/fio-ia` | quick | Credential exposure, injection no prompt |

### On-Deploy

| Alvo | Target | Modo | Instrução |
|------|--------|------|-----------|
| Cloudflare Worker | URL do worker | quick | Auth bypass, SSRF, header injection |

## Alvos Excluídos (cobertura por outras camadas)

| Alvo | Razão | Cobertura alternativa |
|------|-------|----------------------|
| Supabase DBs (3x) | Strix não escaneia DBs diretamente | VDG-05 + security-audit |
| MCP servers (20+) | Serviços terceiros, não nossa superfície | guardrails (Action Auth) |
| Cloudflare Mesh | Network-level | `/cyber` network skills |
| browser-use daemon | Processo local não exposto | Hardening de OS |

## Comandos Rápidos

```bash
STRIX="bash config/strix/strix-wrapper.sh"

# Scan rápido do Aria
$STRIX -t ./Aria -m quick -n

# Scan completo do Aria (white + black box)
$STRIX -t ./Aria -t https://aria-ai-phi.vercel.app -m deep -n

# Scan do Pulso
$STRIX -t https://pulsofinance.vercel.app -m standard -n

# Scan do n8n
$STRIX -t http://localhost:5678 -m standard -n
```
