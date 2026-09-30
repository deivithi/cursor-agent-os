---
name: anatomy-of-agent-harness
description: >
  Anatomia de um agent harness de produção: 12 componentes, 7 decisões de desenho,
  três níveis (prompt / contexto / harness). Síntese alinhada ao artigo "The Anatomy of
  an Agent Harness" + mapa para skills e docs deste repo. Use quando desenhar agentes, rever arquitetura, debugar falhas de contexto,
  tool sprawl, alinhar equipa ao mesmo vocabulário, ou quando o humano ainda é
  quem dispara o próximo passo (gargalo, autonomia, walk-away, Hermes, agenda, handoff).
  Também quando o agente de trabalho de conhecimento falha em tool-call: o default
  é escrever um programa que executa a tarefa, não alongar a cadeia de ferramentas.
domain: infrastructure
subdomain: agent-architecture
version: 1.0.0
author: deivithi
tags:
  - agent-harness
  - production-agents
  - context-engineering
  - orchestration
  - verification
  - tool-scoping
---

# Anatomia do agent harness (produção)

## Fonte e âmbito

- **Inspiração / referência externa:** [The Anatomy of an Agent Harness — @akshay_pachaar (X)](https://x.com/akshay_pachaar/status/2041146899319971922)
- **Este repositório:** texto em `references/article-synthesis.md` é **síntese operacional** para o workspace (não cópia literal do artigo).

## O que é o harness

O **modelo** é só uma peça: o **harness** é a infraestrutura à volta — loop de orquestração, ferramentas, memória, gestão de contexto, estado, erros, guardrails, verificação e ciclo de vida. Em produção, **o harness é grande parte do produto** (não um anexo descartável).

Distinção útil: o **agente** é o comportamento emergente; o **harness** é a maquinaria que o torna estável e auditável.

**Trabalho de conhecimento (default):** se a tarefa não é código e a cadeia de tool-calls patina, o próximo desenho é um programa que executa a tarefa, com o harness a correr e a verificar. O produto é esse programa mais o ciclo de verificação, não mais uma tool. Quem ganha no mercado não se decide nesta skill — lente `mostrar-o-beneficio`. Fonte do mecanismo: https://x.com/DavidGeorge83/status/2104576086101426620 (opinião de investidor, 28/09/2026).

## Auditoria de gargalo (default)

Norte: Andrej Karpathy, No Priors, 20/03/2026 (~16:33). Fonte: [episódio](https://www.youtube.com/watch?v=kwSVtQ7dziU). Frase: tirar-se do gargalo — não estar lá para o prompt seguinte; objetivo, métrica, fronteira; mais agentes a correr mais tempo sem envolvimento.

Aplicação (não é citação): checklist do [HermesWatcher, 24/09/2026](https://x.com/HermesWatcher/status/2103031686418006166).

Ao desenhar ou rever um agente, fechar estes cinco antes de pedir o humano de volta:

1. Objetivo e métrica de sucesso
2. Ferramentas, skills, memória, ficheiros e contexto do projeto
3. Fronteira (o que pode sozinho vs o que exige o humano)
4. Arranque sem o humano (agenda, evento, tarefa recorrente ou handoff)
5. O que o humano ainda faz e o agente já poderia fazer

O humano volta só se a métrica ou a fronteira não existirem, ou se a ação for irreversível (publicar, enviar, apagar, deploy de produção). Contar agentes não é o critério. Detalhe de execução no turno: regra `plan-and-execute` (secção Gargalo humano).

## Três níveis de engenharia

| Nível | O quê |
|-------|--------|
| **Prompt engineering** | Instruções e formato que o modelo recebe. |
| **Context engineering** | O que entra na janela, quando, e em que forma (compactação, máscaras, JIT). |
| **Harness engineering** | Tudo acima **mais** orquestração, persistência, recuperação de erros, verificação, segurança e gestão de ciclo de vida. |

## Os 12 componentes — mapa rápido para este repo

| # | Componente | Onde vive no workspace |
|---|------------|-------------------------|
| 1 | **Orchestration loop** (pensar–agir–observar / fases) | `spec-driven-core`, `spec-phases`, `spec-yolo`; Agent/Composer no Cursor |
| 2 | **Tools** (MCP, CLI, APIs) | `mcp.json`, tools nativas; skills `n8n-mcp-tools-expert`, `mcp-builder` |
| 3 | **Memory** (facts, preferências, RAG) | `AGENTS.md`, `CLAUDE.md`; skills `knowledge-graph`, Memory MCP se ativo |
| 4 | **Context management** | `@.claude/docs/compact-protocol.md`; `stack-automacoes` (higiene de observações) |
| 5 | **Prompt construction** | Rules `.cursor/rules/*.mdc`, skills, system prompts implícitos |
| 6 | **Output parsing** | Schemas/JSON em integrações; validação em guardrails e testes |
| 7 | **State management** | Kanvas; git; skill `agent-harness` (progress + checkpoints) |
| 8 | **Error handling** | Erros explícitos (regra stack-automacoes); não silenciar MCP/HTTP |
| 9 | **Guardrails and safety** | skill `guardrails`; política de remoção em `agent-auto-aprovado` |
| 10 | **Verification loops** | `spec-verify`, `product-verification`, lint/testes no `CLAUDE.md`; latência de produto = skill `perf-hill-climb` (jornada gesto→render + ratchet), não só navigation timing |
| 11 | **Subagent orchestration** | Task tool; `delegate-task`, `spec-phases`; resumos condensados ao repatriar |
| 12 | **Lifecycle management** | `deploy-checklist`, `cicd`; handoff entre sessões via `agent-harness` |

**Detalhe expandido** (7 decisões, walkthrough, metáforas, artefactos tipo CLAUDE/AGENTS, Ralph Loop): ler `@.claude/skills/anatomy-of-agent-harness/references/article-synthesis.md`.

## Skills relacionadas

- `agent-harness` — durabilidade de sessão (checkpoints); **não** substitui esta anatomia.
- `guardrails`, `autonomous-agent-loop`, `gepa-reflective`
- Mapa Cursor: `@.cursor/README.md` (secção *Agent harness — mapa no repositório*)

## 📁 File Structure

- `SKILL.md` — este ficheiro (roteamento + tabela dos 12).
- `references/article-synthesis.md` — síntese longa e decisões de desenho.
