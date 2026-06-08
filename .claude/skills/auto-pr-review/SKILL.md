---
name: auto-pr-review
description: >
  Review automático de PRs via n8n webhook ou polling. Aplica code-review skill com
  Severity Scoring e posta resultado como comentário no PR via gh CLI.
domain: quality-assurance
subdomain: code-review
version: 1.0.0
author: deivithi
tags: [code-review, pr, github, automation, severity-scoring]
---

# Auto PR Review — Review Automático de Pull Requests

## 📁 File Structure
- `SKILL.md` — Você está aqui
- `references/review-prompt.md` — Template de prompt para review

## 🔗 Related Skills
- `code-review` — Base de conhecimento para reviews
- `automations` — Pode ser registrada como automação agendada
- `agent-skill-patterns` — Usa Reviewer + Severity Scoring patterns

## Conceito

Toda PR recebe review automático sem intervenção humana. O review é postado como comentário no PR via `gh pr review`.

## Modos de Operação

### 1. Webhook (Tempo Real)
n8n recebe webhook do GitHub quando PR é aberta/atualizada → executa review → posta comentário.
Requer: n8n webhook exposto (ngrok ou similar).

### 2. Polling (Sem Exposição)
n8n Schedule node roda a cada 5 minutos → `gh pr list --json` → identifica PRs sem review → executa review.
Não requer: exposição de rede. Funciona 100% local.

## Workflow (Polling Mode — Recomendado)

1. `gh pr list --state open --json number,title,headRefName,updatedAt`
2. Para cada PR sem review recente:
   - `gh pr diff {number}` → captura diff
   - Aplica severity-config.json threshold
   - Executa review com prompt template
   - `gh pr review {number} --comment --body "{review}"`
3. Notifica via notify.sh

## Severity Integration

Lê `.claude/data/severity-config.json` e só reporta findings acima do threshold configurado para `auto-pr-review` (default: MEDIUM).
