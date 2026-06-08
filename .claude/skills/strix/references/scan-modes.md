# Strix — Comparação de Modos de Scan

## Modos

| Aspecto | Quick | Standard | Deep (default) |
|---------|-------|----------|----------------|
| **Duração** | ~2 min | ~10 min | ~30 min |
| **Profundidade** | Superficial | OWASP completo | Exaustivo |
| **Tokens (Haiku)** | ~5K (~$0.003) | ~25K (~$0.013) | ~80K (~$0.043) |
| **Tokens (Sonnet)** | ~5K (~$0.025) | ~25K (~$0.125) | ~80K (~$0.425) |
| **Quando usar** | CI/CD, sites estáticos | Scans semanais, apps com auth | Pré-release, auditorias |
| **Cobertura** | Patterns conhecidos | Todas as categorias OWASP | Multi-vetor, chain exploits |

## Recomendação por Alvo

| Alvo | Modo Recomendado | Modelo | Justificativa |
|------|-----------------|--------|---------------|
| PR diff (CI/CD) | quick | Haiku | Rápido, barato, só diff |
| Aria (semanal) | deep | Sonnet | App crítico com payments/PII |
| Pulso (semanal) | standard | Haiku | Auth + dados financeiros |
| n8n (semanal) | standard | Haiku | Webhooks expostos |
| Landing pages | quick | Haiku | Superfície mínima |
| Pré-release | deep | Sonnet | Validação completa |

## Custo Mensal Estimado

| Categoria | Frequência | Modelo | Custo |
|-----------|-----------|--------|-------|
| CI/CD (~20 PRs) | Por PR | Haiku | ~$0.12/mês |
| Aria deep | 4x/mês | Sonnet | ~$2.20/mês |
| Pulso + n8n | 4x/mês | Haiku | ~$0.10/mês |
| Sites estáticos | 1x/mês | Haiku | ~$0.01/mês |
| **TOTAL** | | | **~$2.43/mês** |

## Flags de Otimização

```bash
# CI/CD — mínimo custo, só diff
strix -t ./ -m quick -n --scope-mode auto

# Semanal — cobertura balanceada
strix -t <url> -m standard -n

# Auditoria — máxima profundidade, multi-target
strix -t ./code -t https://live-url -m deep -n
```
