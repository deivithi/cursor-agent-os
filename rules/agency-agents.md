# 🏢 Agency Agents — 208 Agentes Especializados

> Auto-detecção por tema. Catálogo: `.claude/agents/agency/INDEX.md`

## Quando considerar

Ao receber pedido que envolva qualquer área abaixo, consultar o agent relevante em `.claude/agents/agency/`:

| Keywords do pedido | Divisão | Caminho |
|---|---|---|
| vendas, pipeline, discovery, outbound, proposta, deal, SPIN, MEDDPICC | **sales/** | 8 agents |
| marketing, conteúdo, SEO, social media, growth, tiktok, instagram, linkedin, podcast | **marketing/** | 30 agents |
| mídia paga, PPC, ads, programática, tracking, search query | **paid-media/** | 7 agents |
| produto, sprint, feedback, nudge, trend, priorização | **product/** | 5 agents |
| design, UI, UX, brand, visual, acessibilidade visual | **design/** | 8 agents |
| engenharia, backend, frontend, devops, mobile, security, SRE, code review | **engineering/** | 29 agents |
| finanças, FP&A, tax, investimento, contabilidade, bookkeeper | **finance/** | 5 agents |
| projeto, PM, jira, experiment, studio, shepherd | **project-management/** | 6 agents |
| teste, QA, performance, API test, accessibility, evidence | **testing/** | 8 agents |
| suporte, analytics, compliance, legal, infraestrutura | **support/** | 6 agents |
| academia, história, psicologia, antropologia, narratologia | **academic/** | 5 agents |
| game dev, unity, unreal, godot, roblox, blender | **game-development/** | 20 agents |
| XR, visionOS, spatial, metal, realidade aumentada | **spatial-computing/** | 6 agents |
| Salesforce architect, workflow, orchestrator, RH, healthcare, legal | **specialized/** | 41 agents |
| orquestração multi-agente, NEXUS, playbook, runbook, pipeline de agents | **strategy/** | 16 agents |

## Como usar

1. Ler o agent `.md` relevante da divisão
2. Ativar a persona/workflow descrita no agent
3. Combinar com skills internas quando houver sobreposição (ex: paid-media + claude-ads)

## Prioridade

Skills internas (`.claude/skills/`) têm prioridade sobre agency agents quando ambos cobrem o mesmo tema. Agency agents servem como **complemento, segunda opinião ou abordagem alternativa**.
