---
name: spec-driven-core
description: >
  Núcleo spec-driven (Traycer+): roteamento automático entre Epic, Phases, Plan, Review,
  Verify e YOLO sem o utilizador invocar slash commands. Use quando houver novo produto,
  épico, várias entregas, PRD/tickets/fases, refactor grande, migração, "planeja antes de
  codar", verificação contra plano, ou automação Plan→Code→Verify. Carregar skills spec-*
  sob demanda (progressive disclosure). Palavras-chave: spec-driven, Traycer, epic, fases,
  PRD, tech plan, tickets, verificar implementação, YOLO, milestones, handoff.
domain: spec-driven-development
subdomain: orchestration
version: 1.0.0
author: deivithi
tags:
  - spec-driven
  - traycer
  - orchestration
  - routing
  - verification
  - epic
  - phases
---

# Spec-Driven Core — Traycer+ (orquestração)

> **Papel:** definir **qual modo** usar, **que contexto** recolher, **como verificar** e **onde delegar**. O protocolo detalhado vive nas skills `spec-*`; esta skill evita enciclopédia duplicada.

## Referências locais (progressive disclosure)

| Ficheiro | Quando abrir |
|----------|----------------|
| [references/traycer-official-map.md](references/traycer-official-map.md) | Dúvida sobre o que o Traycer documenta oficialmente |
| [references/traycer-agile-workflow.md](references/traycer-agile-workflow.md) | Epic com workflow tipo Traycer Agile |
| [references/smart-yolo-parameters.md](references/smart-yolo-parameters.md) | Automação end-to-end / ajuste de parâmetros YOLO |
| [references/mini-spec-ticket-skeletons.md](references/mini-spec-ticket-skeletons.md) | Templates rápidos de artefactos |
| [gotchas.md](gotchas.md) | Armadilhas comuns |

---

## 1. Gatilhos de ativação (automático)

Ativar este protocolo **sem esperar** `/spec` ou nome de skill quando o pedido incluir **qualquer** combinação relevante:

- Novo produto, greenfield, “do zero”, roadmap, **épico**, várias **milestones** ou entregas sequenciais.
- Pedido explícito de **PRD**, **tech plan**, **tickets**, **fases**, **spec**, **planejar antes de implementar**.
- Refactor ou migração **grande** (múltiplos módulos, risco de regressão).
- **Verificar** implementação contra plano, spec, ou “está de acordo com o que combinámos”.
- **Automação total**: “corre tudo”, YOLO, loop plan→code→verify até acabar.
- **Review** profundo de qualidade (segurança, performance, clareza) **sem** necessidade de plano prévio.

**Não forçar** este fluxo em: typo único, alteração de uma linha, pergunta factual curta, ou tarefa já com plano fechado na mensagem imediata.

**Regra de ouro:** *rotear primeiro* (escolher modo + recolher contexto mínimo), *depois executar* (ler só a skill `spec-*` necessária).

---

## 2. Tabela de roteamento

| Modo | Escolher quando | Ler em seguida (skill) |
|------|------------------|-------------------------|
| **Epic** | Várias specs/tickets, produto/feature grande, alinhamento tipo PRD→tech→tickets | `.claude/skills/spec-epic/SKILL.md` |
| **Evaluate** | Spec gerada e prestes a ir para execução — **gate obrigatório** | `.claude/skills/spec-evaluate/SKILL.md` |
| **Enrich** | Spec aprovada (>= 80) precisa de edge cases, contradições, gaps | `.claude/skills/spec-enrich/SKILL.md` |
| **Phases** | Objetivo complexo com **validação entre entregas**, milestones claros | `.claude/skills/spec-phases/SKILL.md` |
| **Plan** | Uma frente de trabalho, “single PR”, mudança direccionada | `.claude/skills/spec-planner/SKILL.md` |
| **Verify** | Já existe plano/spec; falta validar código **contra** o plano | `.claude/skills/spec-verify/SKILL.md` |
| **Review** | Auditoria de qualidade **sem** plano formal (bugs, perf, sec, clareza) | `.claude/skills/spec-review/SKILL.md` |
| **YOLO** | Utilizador quer **orquestração contínua** plan→implement→verify→fix | `.claude/skills/spec-yolo/SKILL.md` |

**Composição típica (Pipeline Harness Engineering)**

```
Intent → Epic → Evaluate (gate ≥80) → Enrich → Phases (+Contracts) → Plan → Execute → Verify (+Sensors+Scoring) → Next
```

- Epic → **Evaluate** (gate ≥ 80) → **Enrich** (contradições + gaps) → Phases ou Plan → Verify após código.
- Phases → cada fase: **Sprint Validation** (3.5) → **Sprint Contract** (4.5) → Plan → implementação → Verify (**sensores + scoring**) → próxima fase.
- YOLO → automatiza o ciclo; continua a respeitar tectos de loops em `spec-yolo`.

> **Feed-forward** (instruções antes): specs, plans, contracts, boundaries.
> **Feedback** (sensores depois): lint, test, typecheck, build, scoring, evaluation report.
> Ambos são necessários. Spec-driven é metade; Harness Engineering é o todo.

---

## 3. Contexto opcional (paridade Traycer)

Antes de planear, oferecer ou pedir explicitamente (quando aplicável):

- **Ficheiros** (código, config, docs, testes).
- **Pastas** (feature, componente, pacote).
- **Imagens** (mockup, screenshot de erro).
- **Git**: diff não commitado; diff vs `main`; vs branch; vs commit específico.

Integração com o repo: respeitar [`AGENTS.md`](../../../AGENTS.md) na raiz do workspace e, se existir, convenções do projeto.

---

## 4. Taxonomias

### 4.1 Verification (implementação vs **plano**)

Alinhado à doc Traycer [Verification](https://docs.traycer.ai/tasks/verification):

| Nível | Significado |
|-------|-------------|
| **Critical** | Bloqueia requisito ou funcionalidade core |
| **Major** | Impacto forte em comportamento ou UX; pode haver workaround |
| **Minor** | Polimento; não bloqueia |
| **Outdated** | Comentário obsoleto após mudanças |

**Re-verify:** foco em issues já levantados (ciclo rápido).  
**Fresh verification:** reavaliação completa do diff/estado atual contra o plano (mais lenta, maior cobertura).

### 4.2 Review (qualidade geral)

Alinhado a [Review Mode](https://docs.traycer.ai/tasks/review):

| Categoria | Âmbito |
|-----------|--------|
| **Bug** | Lógica, correção funcional |
| **Performance** | Latência, recursos, escalabilidade |
| **Security** | Riscos, dados, auth |
| **Clarity** | Legibilidade, manutenção, estilo |

---

## 5. Ledger de execuções (auditoria local)

Usar quando houver handoffs longos ou **YOLO** / várias fases. Compatível com checkpoints de `agent-harness` para sessões extensas.

Colar e atualizar em `tasks/todo.md`, comentário de PR, ou ficheiro dedicado (ex.: `memory/spec-ledger.md`) — o importante é **existir trilho**.

```markdown
## Execution — [id ou data]

| Campo | Valor |
|-------|--------|
| mode | epic \| phases \| plan \| yolo |
| plan_ref | link ou título do plano/spec |
| scope | ficheiros/pastas principais |
| verify_pass | sim / não |
| verify_mode | re-verify \| fresh |
| loops | N (correções) |
| notes | decisões que não estão no git |
```

---

## 6. Pipeline Greenfield — Produto Novo do Zero

> **Inspirado no LionLab (Breno Vieira):** 12 fases, 5 estágios, 5 validadores com contexto limpo.
> **Princípio central:** "O contexto vai enchendo, o cara vai pulando coisas. Você tem sempre que colocar um validador com contexto limpo do lado."

### Ativação automática

Ativar este pipeline quando o pedido incluir: **"produto novo"**, **"do zero"**, **"greenfield"**, **"MVP"**, **"criar um app/sistema/plataforma"**, **"construir [produto]"**.

### 12 Fases / 5 Estágios

```
ESTÁGIO 1 — DISCOVERY
 1. Discovery Estruturado     → spec-epic Cmd 1 (5 blocos: Visão/Features/Monetização/Técnico/Contexto)

ESTÁGIO 2 — PRD
 2. PRD Generator              → spec-epic Cmd 2-3 (user stories + requisitos + core flows)
 3. PRD Validator               → spec-evaluate (gate >= 80) [VALIDADOR]
 4. PRD Completo                → spec-epic Cmd 4 (Tech Decisions) + Cmd 4.5 (consolida PRD)

ESTÁGIO 3 — SPEC
 5. Spec Generation             → spec-planner (spec técnica unificada a partir do PRD)
 6. Spec Enricher               → spec-enrich (contradições + gaps + edge cases) [VALIDADOR]

ESTÁGIO 4 — SPRINTS
 7. Sprint Planner              → spec-phases Step 3 (decomposição em sprints)
 8. Sprint Validator             → spec-phases Step 3.5 via spec-evaluate tipo Sprint [VALIDADOR]

ESTÁGIO 5 — DESENVOLVIMENTO
 9. Coder                       → spec-yolo Step 2 (sprint por sprint, contexto isolado)
10. Evaluator                   → spec-verify (loop com coder, max 3 rounds) [VALIDADOR]
11. [Repetir 9-10 por sprint]
12. Acceptance Review            → spec-review (revisão macro final pós-sprints) [VALIDADOR]
```

**5 Validadores com contexto limpo:** fases 3, 6, 8, 10, 12.

### Métricas por Fase (template para Ledger)

Adicionar ao ledger (seção 5) quando executar pipeline greenfield:

```markdown
## Métricas — Pipeline Greenfield [Produto]

| # | Fase | Skill | Tempo | Rounds | Status |
|---|------|-------|-------|--------|--------|
| 1 | Discovery | spec-epic | — | 1 | — |
| 2 | PRD Gen | spec-epic | — | 1 | — |
| 3 | PRD Validate | spec-evaluate | — | — | — |
| 4 | PRD Completo | spec-epic | — | 1 | — |
| 5 | Spec Gen | spec-planner | — | 1 | — |
| 6 | Spec Enrich | spec-enrich | — | — | — |
| 7 | Sprint Plan | spec-phases | — | 1 | — |
| 8 | Sprint Validate | spec-evaluate | — | — | — |
| 9-11 | Dev Sprints | spec-yolo | — | — | — |
| 12 | Acceptance | spec-review | — | 1 | — |

## Resumo
- Fases concluídas: [N]/12
- Validadores acionados: [N]/5
- Rounds de correção: [N]
- Gate bypasses: [N] (registrar motivo abaixo)

## Bypass Audit Trail
| Data | Fase | Gate | Motivo |
|------|------|------|--------|
```

---

## 7. Progressive disclosure — ordem de leitura (renumerado de 6)

1. **Confirmar modo** com a secção 2 (ou perguntar numa frase se estiver no limiar).
2. **Abrir só uma** skill `spec-*` alvo e seguir o seu SKILL.md até ao fim desse passo.
3. Para Epic estruturado, seguir [references/traycer-agile-workflow.md](references/traycer-agile-workflow.md) enquanto guia de conversa.
4. Para parâmetros de automação, [references/smart-yolo-parameters.md](references/smart-yolo-parameters.md) + `spec-yolo`.
5. Em dúvida sobre o produto Traycer, [references/traycer-official-map.md](references/traycer-official-map.md).

**Não** carregar todas as skills `spec-*` na mesma mensagem salvo se o utilizador pedir visão completa.

---

## 7. Integração com outras skills

- **`agent-harness`**: sessões longas, ficheiro de progresso, checkpoints após milestones.
- **`alpha-loop`**: iteração fina dentro de uma fase difícil (opcional).
- **`mermaid-diagrams`**: diagramas nos planos quando `spec-planner` ou `spec-epic` o exigirem.

---

## 8. Checklist rápido antes de declarar “pronto”

- O modo (Epic / Phases / Plan / Review / Verify / YOLO) foi **explícito** para ti e coerente com o pedido?
- Contexto opcional (secção 3) foi considerado ou recusado conscientemente?
- Após código: correu **Verify** quando havia plano, ou **Review** quando era pedido qualidade geral?
- Ledger atualizado se a sessão foi multi-handoff?

---

## 9. Comandos slash (opcional)

O utilizador pode usar `/spec` em [`.claude/commands/spec.md`](../../commands/spec.md), que roteia para as mesmas skills. O comportamento **automático** desta skill **não depende** de slash.
