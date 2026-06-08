# Mapa da documentação oficial Traycer (referência)

Fonte canónica do produto: [https://docs.traycer.ai/](https://docs.traycer.ai/) — índice para LLMs: [https://docs.traycer.ai/llms.txt](https://docs.traycer.ai/llms.txt). Landing: [https://traycer.ai/](https://traycer.ai/).

Este ficheiro resume **conceitos e fluxos** alinhados à doc pública; não substitui a leitura das páginas para detalhes que mudem ao longo do tempo.

## Visão geral

- **Spec-driven development**: intenção → artefactos partilháveis (PRD, tech spec, wireframes) → handoff para agentes de código → verificação contra o plano.
- **Problema que o Epic Mode declara resolver**: deriva (“drift”) porque contexto crítico vive em chats dispersos; o sistema tenta capturar o “porquê”, restrições e regras implícitas.

## Epic Mode

- **URL**: [Epic Mode](https://docs.traycer.ai/tasks/epic)
- **Artefactos**:
  - **Specs (mini-specs)**: PRD, Tech Doc, Design Spec, API Spec — documentos focados, evolutivos, em vez de um monolito.
  - **Tickets**: trabalho acionável com critérios de aceitação, estado (Todo → In Progress → Done), atribuição e handoff a agentes.
- **Contexto**: specs e tickets do epic entram no contexto do LLM nas conversas sobre esse epic.
- **Fluxo resumido**: escolher workflow → requisitos → seguir comandos do workflow (elicitação) → handoff para implementação com verificação integrada nos modos de implementação.
- **Execuções (Executions)**: registo de handoffs — planos gerados, comentários de verificação, commit, estado — trilho de auditoria no epic.
- **Smart YOLO**: orquestrador que corre o epic com mínima intervenção; ajuste dinâmico de estratégia em runtime (ver [YOLO Mode](https://docs.traycer.ai/tasks/yolo-mode)).

## Workflows

- **URL**: [Workflows](https://docs.traycer.ai/tasks/workflows)
- Workflow = coleção de **ficheiros de comando** + **entrypoint**; cada comando tem descrição, **argument hints**, **next steps** (multi-path), e pode usar **modos de agente** (Planner vs Reviewer).
- Argumentos referenciados nas instruções como `$1`, `$2`, …
- **Traycer Agile Workflow** (default): `trigger_workflow` → `epic-brief` → `core-flows` → `tech-plan` → `ticket-breakdown` → implementação (Phases / Plan / agente).

## Plan Mode

- **URL**: [Plan Mode](https://docs.traycer.ai/tasks/plan)
- Objetivo: tarefa “single-PR”, guia passo a passo direto.
- Passos: query + contexto opcional → plano file-level com referências a símbolos → executar no agente → verificação → concluir.

## Phases Mode

- **URL**: [Phases Mode](https://docs.traycer.ai/tasks/phases)
- Objetivo: projetos complexos em fases com **validação entre passos**.
- Passos: query + contexto → clarificação (se necessário) → geração de fases → plano por fase → handoff → **verificação** → próxima fase com contexto preservado.
- Contexto opcional alinhado ao Plan: ficheiros, pastas, imagens, diffs git (uncommitted, main, branch, commit).

## Verification

- **URL**: [Verification](https://docs.traycer.ai/tasks/verification)
- Compara implementação ao **plano original**; comentários categorizados: **Critical**, **Major**, **Minor**, **Outdated**.
- Modos: **Re-verify** (focado em issues anteriores) vs **Fresh Verification** (re-análise completa).

## Review Mode

- **URL**: [Review Mode](https://docs.traycer.ai/tasks/review)
- Review exploratório (“agentic”) com categorias: **Bug**, **Performance**, **Security**, **Clarity** (ortogonal à verificação contra plano).

## YOLO Mode

- **URL**: [YOLO Mode](https://docs.traycer.ai/tasks/yolo-mode)
- Automação de planeamento, código e verificação com menos handoffs manuais; **Smart YOLO** no Epic ajusta configuração por tarefa (ex.: skip plan, níveis de verificação, timeouts, auto-commit — conforme documentação atual).

## Integrações (paridade conceitual)

- [Agents](https://docs.traycer.ai/integrations/agents.md) — handoff para agentes de código.
- [Custom CLI Agents](https://docs.traycer.ai/integrations/custom-cli-agents.md)
- [MCP](https://docs.traycer.ai/integrations/mcp.md)
- [Templates](https://docs.traycer.ai/integrations/templates.md) (Handlebars para prompts de plano)
- [AGENTS.md no repositório](https://docs.traycer.ai/tasks/agents-md.md) — contexto de projeto para execução
- [Ticket Assist](https://docs.traycer.ai/integrations/ticket-assist.md) — planos a partir de issues GitHub

## Tasks overview

- [Tasks index / overview](https://docs.traycer.ai/tasks/index.md)

## Mapeamento para este workspace (skills locais)

| Conceito Traycer | Skill local |
|------------------|-------------|
| Epic + mini-specs + tickets | `spec-epic` |
| Phases + gate | `spec-phases` |
| Plan file-level | `spec-planner` |
| Verification vs plano | `spec-verify` |
| Review categorizado | `spec-review` |
| YOLO / loop auto | `spec-yolo` |
| Orquestração + roteamento | **`spec-driven-core`** (esta skill) |
