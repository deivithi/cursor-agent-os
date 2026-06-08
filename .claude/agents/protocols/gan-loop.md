# GAN Loop Orchestrator

> Fonte: [Anthropic Engineering — Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) (2026-03-24)
> Arquitetura inspirada em GANs: Generator produz, Evaluator critica, loop itera até convergência.

## Arquitetura

```
                    ┌─────────────┐
                    │   Planner   │
                    │ (1x, início)│
                    └──────┬──────┘
                           │ spec
                           ▼
Sprint Contract ◄── Generator ──► Evaluator
    (negociação)     │    ▲         │
                     │    │         │
                     │    └─────────┘
                     │   feedback loop
                     │   (5-15 rounds)
                     ▼
                  Entrega Final
```

## 3-Agent Architecture

| Agent | Papel | Ferramentas | Quando Roda |
|-------|-------|-------------|-------------|
| **Planner** | Expande prompt de 1-4 frases em spec completo | Read-only, exploração | 1x no início |
| **Generator** | Implementa features, uma por vez | Edit, Write, Bash, Git | Cada sprint |
| **Evaluator** | QA live, scoring, bugs | Playwright MCP, Read-only | Após cada sprint |

## Fluxo Completo

### Fase 1: Planning (1 round)
```
Input: prompt do usuário (1-4 frases)
    ↓
Planner expande em:
  - Product spec com features
  - Design de alto nível (não granular — evita cascading errors)
  - Stack recomendada
  - Oportunidades de IA no produto
    ↓
Output: spec aprovado
```

### Fase 2: Sprint Execution (N rounds)
```
Para cada sprint:
  1. Generator propõe Sprint Contract
  2. Evaluator revisa contrato
  3. Generator implementa (1 feature por vez)
  4. Generator faz self-eval rápido antes de entregar
  5. Evaluator faz QA formal (Playwright + code review)
  6. Resultado:
     ├── 🟢 PASS → próximo sprint
     ├── 🟡 CONDITIONAL → Generator corrige → re-eval
     └── 🔴 FAIL → Generator pivota abordagem
```

### Fase 3: Convergence
```
Loop termina quando:
  - Todas as features do spec estão PASS
  - Score weighted ≥ 7.0/10
  - Zero bugs CRITICAL/HIGH abertos

OU quando:
  - 15 rounds atingidos → entrega best-effort + relatório
  - 5 rounds sem progresso no mesmo issue → flag para humano
```

## Pivot Protocol

> No artigo, o modelo scrapped uma abordagem inteira na iteração 10 e reimaginou o site como experiência 3D.

Quando pivotar:
- **3 rounds** sem melhoria no mesmo critério → considerar pivot
- **Score caindo** entre rounds → abordagem atual não converge
- **Evaluator sugere direção diferente** → Generator DEVE considerar

Como pivotar:
1. Git commit do estado atual (preservar trabalho)
2. Evaluator documenta POR QUE a abordagem não converge
3. Generator propõe abordagem alternativa (pode ser radicalmente diferente)
4. Novo Sprint Contract para a nova abordagem

## Integração com Skills Existentes

| Skill Existente | Como o GAN Loop Usa |
|----------------|---------------------|
| `alpha-loop` | Generator usa internamente para iteração dentro do sprint |
| `code-review` | Evaluator incorpora as regras de review |
| `product-verification` | Evaluator usa browser-use para QA live |
| `frontend-design` | Generator segue para UI work |
| `agent-harness` | Session tracking e checkpoints entre sprints |
| `gepa-reflective` | Evaluator analisa WHY algo falhou, não só O QUÊ |

## Custos de Referência (Anthropic Labs)

| Configuração | Tempo | Custo | Qualidade |
|-------------|-------|-------|-----------|
| Solo (sem harness) | 20 min | $9 | Quebrado, layout ruim |
| Full GAN harness | 6 hrs | $200 | Funcional, polido |
| Opus 4.6 (sem sprints) | 3h50 | $125 | Funcional, boa qualidade |

> **Insight:** Com Opus 4.6, sprints per-feature podem ser removidos. Evaluator faz single-pass no final. O modelo sustenta tarefas mais longas sozinho.

## Modo Simplificado (Opus 4.6+)

Para o modelo atual, a versão lean:
```
Planner (1x) → Generator (implementa tudo) → Evaluator (1x no final)
                     ↓                              ↓
              self-eval durante build         se FAIL → fix → re-eval
                                              máx 3 rounds
```

Usar full GAN loop (com sprints) apenas para:
- Projetos com 5+ features distintas
- Builds que ultrapassam 1 hora
- Quando qualidade é mais importante que velocidade
