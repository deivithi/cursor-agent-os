---
name: github-mentions
description: >
  Responde a menções @claude em PRs e Issues do GitHub. Executa comandos e posta
  resultado como comentário. Funciona via n8n polling (sem webhook necessário).
domain: integration
subdomain: github
version: 1.0.0
author: deivithi
tags: [github, mentions, automation, pr, issues]
---

# GitHub @claude Mentions

## Conceito

Quando alguém comenta `@claude <instrução>` em um PR ou Issue no GitHub, o sistema detecta, executa a instrução, e posta o resultado como comentário.

## Modos

### Polling (Recomendado)
n8n Schedule → `gh api` busca comentários recentes → filtra @claude → executa → responde.

### Webhook
GitHub webhook → n8n → executa → responde. Requer exposição de rede.

## Comandos Suportados

| Menção | Ação |
|--------|------|
| `@claude review` | Executa code review no PR |
| `@claude fix CI` | Analisa CI failure e sugere fix |
| `@claude explain` | Explica o que o PR faz |
| `@claude summarize` | Resumo do PR para revisores |
| `@claude <qualquer coisa>` | Executa como prompt livre |

## Workflow (Polling)

```bash
# Buscar comentários recentes com @claude
gh api repos/{owner}/{repo}/issues/comments \
  --jq '.[] | select(.body | contains("@claude")) | {id, body, issue_url}'

# Executar instrução
INSTRUCTION=$(echo "$BODY" | sed 's/@claude //')
RESULT=$(claude -p "$INSTRUCTION")

# Postar resposta
gh issue comment {number} --body "$RESULT"
```

## Integração
- Ativado automaticamente quando n8n polling workflow está ativo
- `/automations` pode registrar o polling como automação agendada
