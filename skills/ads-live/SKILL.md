---
name: ads-live
description: "Cross-platform live ads dashboard via MCP. Pulls real-time data from Google Ads and Meta Ads APIs automatically, then runs audit analysis using existing ads skills. Use when user says: como estao minhas campanhas, ads dashboard, live ads, performance ao vivo, relatorio de ads, metricas de campanha, ROAS hoje, quanto gastei em ads."
user-invokable: true
argument-hint: "dashboard | google | meta | compare | audit"
---

# Ads Live — Cross-Platform Dashboard via MCP

Puxa dados ao vivo de Google Ads e Meta Ads via MCP servers locais,
analisa com as 18 skills de audit existentes, e entrega relatorio unificado.

## Pre-requisitos

Ambos os MCP servers devem estar configurados em `.mcp.json`:
- **google-ads**: `google-ads` MCP server (Google Ads API via OAuth2)
- **meta-ads**: `meta-ads` MCP server (Meta Marketing API via access token)

Se um MCP nao estiver disponivel, reportar qual esta faltando e continuar
com a plataforma disponivel. Nunca falhar silenciosamente.

## Comandos

| Comando | Acao |
|---------|------|
| `/ads-live` ou `/ads-live dashboard` | Dashboard unificado Google + Meta |
| `/ads-live google` | Apenas dados ao vivo do Google Ads |
| `/ads-live meta` | Apenas dados ao vivo do Meta Ads |
| `/ads-live compare` | Comparativo cross-platform (ROAS, CPA, spend) |
| `/ads-live audit` | Puxa dados ao vivo e roda audit completo |

## Workflow

### 1. Detectar MCP Servers Disponiveis

Verificar quais MCP tools estao acessiveis:
- Google Ads: tentar listar campanhas via `mcp__google-ads__*` tools
- Meta Ads: tentar listar contas via `mcp__meta-ads__list_ad_accounts`

Se nenhum estiver configurado:
```
Os MCP servers de ads nao estao configurados ainda.
Siga o guia em .claude/docs/ads-mcp-setup-guide.md para ativar.
```

### 2. Coletar Dados (paralelo quando possivel)

**Google Ads (se disponivel):**
- Listar campanhas ativas
- Metricas dos ultimos 30 dias: spend, clicks, impressions, conversions, ROAS, CPA
- Search Terms Report (top 50 por spend)
- Keywords com Quality Score < 6
- Campanhas limitadas por orcamento

**Meta Ads (se disponivel):**
- Listar contas de anuncio
- Campanhas ativas com insights (30 dias)
- Ad sets em Learning Limited
- Criativos com CTR em queda (fatigue detection)
- Breakdown por placement (Feed vs Stories vs Reels)

### 3. Formatar Dashboard

```
==================================================
   ADS LIVE DASHBOARD — {data atual BRT}
==================================================

GOOGLE ADS
  Campanhas ativas: X
  Spend (30d):      R$ X.XXX,XX
  Conversoes:       XXX
  ROAS:             X.Xx
  CPA medio:        R$ XX,XX
  Quality Score:    X.X avg

META ADS
  Campanhas ativas: X
  Spend (30d):      R$ X.XXX,XX
  Conversoes:       XXX
  ROAS:             X.Xx
  CPA medio:        R$ XX,XX
  Learning Limited: X ad sets

CROSS-PLATFORM
  Total Spend:      R$ X.XXX,XX
  Total Conversoes: XXX
  Blended ROAS:     X.Xx
  Blended CPA:      R$ XX,XX

ALERTAS
  [!] Google: X campanhas limitadas por orcamento
  [!] Meta: X criativos com fadiga detectada
  [!] Google: X keywords com QS < 5
==================================================
```

### 4. Audit Automatico (quando `/ads-live audit`)

Apos coletar dados ao vivo:
1. Formatar dados no formato esperado pelas skills de audit
2. Invocar skill `ads-google` com dados do Google Ads MCP
3. Invocar skill `ads-meta` com dados do Meta Ads MCP
4. Consolidar scores em Ads Health Score unificado
5. Gerar relatorio com Quick Wins priorizados

## Integracao com Skills Existentes

Esta skill e um **router de dados ao vivo**. Ela NAO substitui as skills
de audit — ela **alimenta** as skills existentes com dados reais em vez de
exports manuais.

| Skill | Fonte sem MCP | Fonte com MCP (esta skill) |
|-------|--------------|---------------------------|
| ads-google | Export CSV colado | Google Ads API ao vivo |
| ads-meta | Screenshot Ads Manager | Meta Marketing API ao vivo |
| ads-audit | Dados manuais | Ambas APIs ao vivo |
| ads-budget | Metricas informadas | Spend real + breakdown |

## Gotchas

- **Rate limits:** Google Ads API tem quota diaria. Nao fazer polling excessivo.
- **Meta token expira:** Long-lived token dura 60 dias. Se der 401, renovar token.
- **Moeda:** Verificar moeda da conta (BRL, USD) e converter se necessario.
- **Timezone:** Google Ads usa timezone da conta. Meta usa timezone do ad account. Normalizar para BRT.
- **Dados parciais:** Conversoes podem ter lag de 1-3 dias. Alertar o usuario.
