---
name: strix
description: >
  Pentesting dinâmico com agentes IA autônomos (Strix). Escaneia codebases locais, URLs live
  e repos GitHub com validação real de exploits (zero falsos positivos). 3 modos: quick/standard/deep.
  CI/CD com --scope-mode auto para diffs de PR. Keywords: strix, pentest, pentesting, dynamic scan,
  exploit validation, penetration test, security scan live, varredura de segurança, scan de vulnerabilidades.
domain: security
subdomain: dynamic-pentesting
version: 1.0.0
allowed-tools: Bash, Read, Glob, Grep, Write, Agent
metadata:
  author: deivithi
  version: "1.0"
---

# Strix — Pentesting Dinâmico com Agentes IA

> **"vibe-deploy-guard diz que PODE ter SQLi. Strix PROVA que tem — com PoC."**

Agentes IA autônomos que agem como hackers reais. Rodam código dinamicamente, encontram vulnerabilidades e validam com proof-of-concept. Apache 2.0, 23K+ stars.

## File Structure

- `SKILL.md` — Você está aqui. Workflow completo.
- `gotchas.md` — Problemas conhecidos (Windows, venv, Docker).
- `references/target-registry.md` — Matriz de alvos do ecossistema.
- `references/scan-modes.md` — Comparação detalhada de modos.

## Related Skills

- `security-audit` — Metodologia Trail of Bits (3 fases). Strix alimenta Phase 2 com findings confirmados
- `vibe-deploy-guard` — 18 checks estáticos inline. Strix valida dinamicamente o que VDG flaggeia
- `mythos` — Hunting autônomo em código. Strix confirma exploitabilidade em alvos live
- `guardrails` — Proteção runtime. Findings do Strix alimentam regras de guardrails
- `cicd` — Strix integra como gate de segurança no pipeline CI/CD
- `error-alerting` — Padrão de alertas Telegram reutilizado pelo n8n Fleet Scanner

## Quando Usar

| Cenário | Nível |
|---------|-------|
| Scan rápido pré-commit de um arquivo/diretório | Quick |
| Scan de PR no CI/CD (só diff) | Quick + `--scope-mode auto` |
| Scan semanal de app deployado | Standard |
| Auditoria completa pré-release | Deep |
| Validar finding do vibe-deploy-guard ou mythos | Standard (alvo focado) |
| Scan de todos os alvos do ecossistema | Fleet (batch) |

## Quando NÃO Usar (Handoff)

- Análise estática de patterns no código → `vibe-deploy-guard`
- Auditoria profunda com metodologia formal → `security-audit`
- Hunting de zero-days em código → `mythos`
- Proteção runtime de agentes → `guardrails`
- Pesquisa de vulnerabilidade específica → `/cyber`
- Scan de banco de dados (RLS, policies) → VDG-05 + `security-audit`

---

## Setup

### Instalação (venv dedicado — sem Docker)

```bash
# Já instalado em ~/.strix-env/
# Wrapper: config/strix/strix-wrapper.sh
# Env vars: config/strix/.strix.env
```

### Comando Base

```bash
# Via wrapper (recomendado — carrega venv + env vars do .strix.env)
bash config/strix/strix-wrapper.sh -t <alvo> -m <modo> -n

# Via venv direto (OpenRouter free tier — custo $0)
source ~/.strix-env/Scripts/activate
export STRIX_LLM="deepseek/deepseek-r1:free"
export LLM_API_KEY="<openrouter-key>"
export LLM_API_BASE="https://openrouter.ai/api/v1"
strix -t <alvo> -m <modo> -n
```

### Modelos Gratuitos (OpenRouter Free Tier)

| Cenário | Modelo | Por que |
|---------|--------|---------|
| Default (melhor raciocínio) | `deepseek/deepseek-r1:free` | Chain-of-thought, análise profunda |
| Code-heavy (codebase) | `qwen/qwen3-coder-480b:free` | 262K contexto, especializado em código |
| Rápido (CI/CD) | `meta-llama/llama-3.3-70b-instruct:free` | Mais rápido para quick scans |

Config em `config/strix/.strix.env`. Rate limits: 20 req/min, ~200 req/dia.

### Flags Importantes

| Flag | Função |
|------|--------|
| `-t <alvo>` | Alvo: path local, URL, domínio, IP. Múltiplos `-t` permitidos |
| `-m quick\|standard\|deep` | Modo de scan (default: deep) |
| `-n` | Non-interactive (sem TUI, para CI/CD e automação) |
| `--instruction "..."` | Instruções custom (credenciais, foco, áreas) |
| `--instruction-file` | Instruções de um arquivo |
| `--config` | Config JSON custom |

---

## Progressive Disclosure

### L1: Quick Scan (`strix scan <alvo>`)

```bash
# Scan rápido — ~2min, ~$0.003 (Haiku)
bash config/strix/strix-wrapper.sh -t ./Aria/frontend -m quick -n
```

Superficial. Bom para: CI/CD, validação rápida, sites estáticos.

### L2: Standard Scan (`strix hunt <alvo>`)

```bash
# Scan padrão — ~10min, ~$0.013 (Haiku) ou ~$0.125 (Sonnet)
bash config/strix/strix-wrapper.sh -t https://aria-ai-phi.vercel.app -m standard -n
```

Cobertura OWASP completa. Bom para: scans semanais, apps com auth.

### L3: Deep Scan (`strix siege <alvo>`)

```bash
# Scan profundo — ~30min, ~$0.043 (Haiku) ou ~$0.425 (Sonnet)
bash config/strix/strix-wrapper.sh -t ./Aria -t https://aria-ai-phi.vercel.app -m deep -n
```

White-box + black-box combinados (multi-target). Bom para: pré-release, auditorias.

### L4: Fleet Scan (`strix fleet`)

Roda todos os alvos da matriz (`references/target-registry.md`) conforme cronograma:

```bash
# Grupo crítico (Aria)
bash config/strix/strix-wrapper.sh -t ./Aria -t https://aria-ai-phi.vercel.app -m deep -n

# Grupo standard (Pulso + n8n)
bash config/strix/strix-wrapper.sh -t https://pulsofinance.vercel.app -m standard -n
bash config/strix/strix-wrapper.sh -t http://localhost:5678 -m standard -n

# Grupo light (sites estáticos)
bash config/strix/strix-wrapper.sh -t https://ai-landing.netlify.app -m quick -n
```

Automatizado via n8n (workflow Strix Fleet Scanner).

---

## Instruções Focadas por Alvo

Para scans mais eficientes, usar `--instruction` com contexto do alvo:

```bash
# Aria — foco em auth, billing, PII
bash config/strix/strix-wrapper.sh -t https://aria-ai-phi.vercel.app -m standard -n \
  --instruction "App SaaS com Supabase auth, Stripe billing (BRL/PIX), AG-UI streaming via SSE. Focar em: auth bypass, IDOR em user data, Stripe webhook spoofing, SSE injection, RLS bypass via anon key."

# n8n — foco em webhooks
bash config/strix/strix-wrapper.sh -t http://localhost:5678 -m standard -n \
  --instruction "n8n automation server. Focar em: webhook endpoints sem autenticação, SSRF via HTTP Request nodes, credential leakage, admin panel access."

# Pulso Finance — foco em dados financeiros
bash config/strix/strix-wrapper.sh -t https://pulsofinance.vercel.app -m standard -n \
  --instruction "App financeiro pessoal com Supabase. Focar em: IDOR em transações financeiras, RLS bypass, auth token manipulation, XSS em campos monetários."
```

---

## Interpretando Resultados

| Exit Code | Significado | Ação |
|-----------|-------------|------|
| 0 | Nenhuma vulnerabilidade | Prosseguir com deploy |
| 2 | Vulnerabilidades encontradas | Revisar findings, corrigir antes de deploy |
| 1 | Erro no scan | Verificar logs, re-executar |

### Severidade (alinhada com security-audit e mythos)

| Strix Severity | CVSS | Ação |
|---------------|------|------|
| Critical | 9.0-10.0 | Bloquear deploy. Fix imediato |
| High | 7.0-8.9 | Bloquear PR merge. Fix antes de produção |
| Medium | 4.0-6.9 | Warning no PR. Fix no próximo sprint |
| Low | 0.1-3.9 | Informacional. Avaliar risco |

---

## CI/CD (GitHub Actions)

```yaml
strix-security:
  runs-on: ubuntu-latest
  needs: [build]
  steps:
    - uses: actions/checkout@v4
      with: { fetch-depth: 0 }
    - name: Install Strix
      run: pip install strix-agent
    - name: Run Strix
      env:
        STRIX_LLM: anthropic/claude-haiku-4-5-20251001
        LLM_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
      run: strix -n -t ./ --scan-mode quick
    - name: Upload report
      if: always()
      uses: actions/upload-artifact@v4
      with:
        name: strix-report
        path: strix_runs/
        retention-days: 30
```

---

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Finding precisa root cause no código | `mythos` | Strix confirma vuln, precisa localizar no source |
| Finding precisa classificação OWASP formal | `security-audit` | Mapear para relatório de auditoria |
| Finding precisa mitigação runtime imediata | `guardrails` | Deployer Input/Output guard |
| Finding precisa pesquisa especializada | `/cyber` | Vulnerability research domain-specific |
| Scan precisa rodar agendado | `automations` + n8n | Fleet scan no cron |
| VDG flaggeou pattern estático | Strix (este) | Validar se é exploitável de verdade |

---

## Gotchas

Consulte `gotchas.md` para lista completa. Principais:

1. **Venv obrigatório** — Strix tem conflito de litellm com instalação global. Sempre usar `~/.strix-env/`
2. **LLM_API_KEY necessária** — Sem key, scan falha silenciosamente
3. **localhost via Docker** — Se usar Docker no futuro, n8n é `host.docker.internal:5678`
4. **Windows paths** — Usar forward slashes ou Git Bash paths (`/c/Users/...`)

## Referências

- [GitHub — usestrix/strix](https://github.com/usestrix/strix) (Apache 2.0, 23K+ stars)
- [Documentação oficial](https://docs.strix.ai)
- [CLI Reference](https://docs.strix.ai/usage/cli)
- [Scan Modes](https://docs.strix.ai/usage/scan-modes)
