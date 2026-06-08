# Equivalente ao Traycer Agile Workflow (comandos)

Referência: [Workflows — Traycer Agile Workflow](https://docs.traycer.ai/tasks/workflows).

Use esta sequência quando o modo escolhido for **Epic** (produto/feature grande, vários artefactos). Cada bloco = uma “volta” de conversa focada; adapte ao que o utilizador já trouxe.

## 1. `trigger_workflow` (alinhamento)

- Discutir pedido e metas.
- Perguntas de clarificação; sem assumir requisitos silenciosos.
- Saída: intenção partilhada; decidir se segue para `epic-brief` ou salta para `core-flows` se o problema já estiver fechado.

## 2. `epic-brief` (Epic Brief / PRD curto)

- Quem é afetado, dor atual, resultado desejado a nível produto.
- Epic Brief **conciso** (guia Traycer: ~50 linhas ou menos).
- Sem detalhe de UI ou desenho técnico profundo neste passo.
- Next típico: `core-flows`.

## 3. `core-flows` (fluxos e UX)

- Jornadas de utilizador, hierarquia de informação, passos.
- Aceita esboços ASCII ou referência a wireframes.
- Next típico: `tech-plan` (ou `ticket-breakdown` se tech já for óbvia).

## 4. `tech-plan` (plano técnico)

- Arquitectura, ficheiros/componentes a mexer, decisões e racional.
- Alinhar a padrões existentes no repositório.
- Next típico: `ticket-breakdown`.

## 5. `ticket-breakdown` (tickets)

- Tickets **independentes** com critérios de aceitação.
- Ligação explícita a specs relevantes.
- Priorização e ordem sugerida.
- Next: implementação via **Phases** (várias entregas) ou **Plan** (uma frente) + **Verify** após código.

---

**Filosofia (doc Traycer):** colaboração primeiro; perguntas como investimento; artefactos legíveis por humanos.
