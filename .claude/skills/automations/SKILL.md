---
name: automations
description: >
  Sistema de tarefas agendadas com review queue. Define automações que rodam em schedule
  via n8n, coletam resultados e apresentam para revisão humana. Equivalente ao Codex Automations.
domain: automation
subdomain: scheduling
version: 1.0.0
author: deivithi
tags:
  - scheduling
  - cron
  - automation
  - review-queue
  - n8n
---

# Automations — Tarefas Agendadas com Review Queue

## 📁 File Structure
- `SKILL.md` — Você está aqui
- `gotchas.md` — Problemas conhecidos

## 🔗 Related Skills
- `autonomous-agent-loop` — Para loops de otimização contínua (Ouroboros)
- `cicd` — Para automações de deploy
- `lead-audit` — Candidata a automação agendada
- `product-verification` — Candidata a automação agendada

## Conceito

Automações são tarefas que rodam **sem intervenção humana** em schedule definido. Quando produzem resultado que precisa de decisão, o resultado vai para uma **review queue** onde o usuário aprova ou rejeita.

## Arquitetura

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│  registry.json  │────▶│  n8n Dispatcher   │────▶│  claude -p  │
│  (definições)   │     │  (Schedule 5min)  │     │  (execução) │
└─────────────────┘     └──────────────────┘     └──────┬──────┘
                                                        │
                              ┌─────────────────────────┤
                              ▼                         ▼
                   ┌──────────────────┐     ┌──────────────────┐
                   │  review-queue.md │     │   notify.sh      │
                   │  (se required)   │     │  (telegram/etc)  │
                   └──────────────────┘     └──────────────────┘
```

## Workflow

1. Usuário define automação via `/automations add`
2. n8n Dispatcher checa a cada 5 minutos quais estão no horário
3. Executa o comando definido
4. Se `review_required`: resultado vai para review-queue.md
5. Notifica via canal configurado
6. Usuário revisa via `/automations review`
