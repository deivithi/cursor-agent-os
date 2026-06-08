---
name: trace-capability
description: >
  Análise contrastiva de trajetórias e identificação de gaps de capacidade para
  auto-aprimoramento de agentes. Compara traces de sucesso vs falha lado a lado
  para isolar deltas específicos, nomeia gaps usando taxonomia padronizada, e gera
  cenários de teste direcionados ou patches de skill/rule. Adaptação do paper TRACE
  (arXiv 2604.05336, Stanford) para Claude Code sem GPU. Use quando "trace analysis",
  "capability gap", "contrastive analysis", "por que essa skill falha", "comparar
  sucesso vs falha", "trace-capability", "TRACE method", "capability selection",
  "targeted improvement", "gap de capacidade", "análise contrastiva".
license: MIT (paper original) + Custom (adaptação)
metadata:
  author: Deivithi
  source: "arXiv 2604.05336 (ScalingIntelligence/TRACE, Stanford)"
  version: 1.0.0
  created: 2026-04-14
  tags:
    - self-improvement
    - contrastive-analysis
    - capability-gap
    - ouroboros
    - agent-evolution
    - trace-analysis
    - targeted-training
---

# TRACE Capability — Análise Contrastiva de Capacidades

## File Structure
- `SKILL.md` — Você está aqui. Comece pelo workflow de 3 stages abaixo
- `references/trace-paper-summary.md` — Metodologia do paper adaptada
- `references/capability-taxonomy.md` — 15 capacidades nomeadas (5 dimensões)
- `references/contrastive-protocol.md` — Protocolo detalhado de análise contrastiva
- `templates/` — Templates para gap report, test scenario e patch proposal
- `scripts/collect-traces.sh` — Coleta determinística de traces (bash, imutável)
- `gotchas.md` — Problemas conhecidos e armadilhas

## Related Skills
- `gepa-reflective` — Diagnóstico causal pós-falha (fast path, 1 trace). TRACE complementa com análise contrastiva (deep path, múltiplos traces)
- `ouroboros` — Motor de auto-aprimoramento onde TRACE integra no Step 2.1b
- `autonomous-agent-loop` — 10 padrões Karpathy que fundamentam o loop
- `evals` — Framework de avaliação que fornece os traces
- `skill-architect` — Padrão de qualidade para skills geradas/patcheadas

---

## Quando Usar

| Cenário | Ação |
|---|---|
| Ouroboros iteration 2+ com DISCARD/CRASH e 3+ PASS + 2+ FAIL traces | Stage 1 automático (paralelo ao GEPA) |
| Pós-sessão Ouroboros com items ainda falhando | Stage 2 (gerar testes para próxima sessão) |
| Skill com performance inconsistente (às vezes funciona, às vezes não) | Stage 1 manual: "analise os gaps de {skill}" |
| Quero entender por que meu agente falha em X | Stage 1 manual com traces disponíveis |

---

## Workflow — 3 Stages

### Phase 1 — Seleção Contrastiva de Capacidades

> **Input:** skill-name com traces suficientes | **Output:** Capability Gap Report

**Passo 1.** Coletar traces:
```bash
bash .claude/skills/trace-capability/scripts/collect-traces.sh {skill-name}
```
Se `sufficient_for_contrastive: false` → usar GEPA (fast path). PARAR aqui.

**Passo 2.** Ler traces PASS e FAIL completos do diretório retornado.

**Passo 3.** Alinhar pares: para cada FAIL, encontrar o PASS mais similar (mesmo tipo de input, mesmas tools disponíveis, mesmos checklist items alvo). Protocolo completo: `references/contrastive-protocol.md`

**Passo 4.** Extrair delta por par em 5 eixos:
- **Steps:** Que passos o PASS fez que o FAIL pulou?
- **Tools:** Que ferramentas o PASS usou diferente?
- **Information:** Que informação o PASS coletou a mais?
- **Decisions:** Em que ponto as trajetórias divergiram?
- **Quality:** Que aspecto do output diferiu?

**Passo 5.** Abstrair deltas em capacidades nomeadas usando `references/capability-taxonomy.md`. Mínimo 2 deltas para confirmar um gap.

**Passo 6.** Rankear por Impact Score: `frequência_nos_pares x delta_médio_score`

**Passo 7.** Gerar Capability Gap Report usando `templates/capability-gap-report.md`

### Phase 2 — Síntese de Cenários de Teste

> **Input:** Gap Report do Stage 1 | **Output:** Traces sintéticos + judge criteria

**Passo 1** — Para cada gap identificado, gerar 3 cenários de teste:
- 1 simples (happy path que exercita a capacidade)
- 1 padrão (caso real típico)
- 1 edge case (condição de contorno)

**Passo 2** — Formatar como JSON seguindo `templates/test-scenario.json`

**Passo 3** — Salvar traces em `ouroboros/evals/traces/{skill}/trace_synth_{gap}_{N}.json`

**Passo 4** — Gerar judge criteria: `ouroboros/evals/judges/{skill}/judge_{gap}.txt`
O judge deve avaliar especificamente se a capacidade é demonstrada, com critérios positivos e anti-critérios.

### Phase 3 — Patch de Skill/Rule

> **Input:** Gap Report | **Output:** Patch proposal com integração path

**Passo 1** — Classificar cada gap:

| Tipo | Sintoma | Ação |
|---|---|---|
| `knowledge` | SKILL.md não menciona a capacidade | Adicionar passo ou seção ao SKILL.md |
| `rule` | Agente sabe mas aplica inconsistentemente | Criar rule em `.claude/rules/` ou `learned-rules.md` |
| `tool` | Agente não usa a ferramenta certa | Adicionar guidance em gotchas.md |
| `structural` | Arquitetura da skill é inadequada | Flag para review humano. NUNCA auto-aplicar |

**Passo 2** — Gerar proposta usando `templates/patch-proposal.md`

**Passo 3** — Integrar conforme tipo:
- `knowledge`/`tool` → alimentar Ouroboros Step 2.2 como hipótese
- `rule` → append a `ouroboros/evolution/corrections.jsonl`
- `structural` → reportar ao humano e parar

---

## Integração com Ouroboros

### Step 2.1b Aprimorado

```
IF iteration > 1 AND (DISCARD or CRASH):

  [GEPA — fast path, SEMPRE roda]
  → Lê trace da falha → diagnóstico causal → classificação Type 1/2/3

  [TRACE — deep path, roda SE collect-traces retorna sufficient_for_contrastive: true]
  → Análise contrastiva PASS vs FAIL → gap report → patch proposal
  → Patch proposal alimenta Step 2.2 como hipótese informada
  → Se ambos rodaram: TRACE tem prioridade (mais evidência)
```

### Phase 3.5 — Síntese Pós-Sessão

```
IF checklist items ainda falham após max_iterations:
  → Stage 2 para cada item restante → traces sintéticos salvos
  → Próxima sessão Ouroboros começa com eval data mais rico
```

### Pipeline de Evolução

```
trace-capability → gap com evidência contrastiva
  → SE rule gap: append corrections.jsonl (via log-correction.sh)
  → SE 2x+ mesmo gap: promover a learned-rules.md
  → SE 10+ sessões: graduar a .claude/rules/
```

---

## Anti-Patterns

- **NUNCA** rodar Stage 1 com `sufficient_for_contrastive: false` — resultados não confiáveis sem pares suficientes
- **NUNCA** adicionar capacidade à taxonomia com base em uma única análise — mínimo 2 análises independentes
- **NUNCA** auto-aplicar patch `structural` — sempre requer review humano
- **NUNCA** tratar trace sintético (Stage 2) com mesmo peso de trace real — peso 0.3x
- **NUNCA** alinhar traces com tipos de input incompatíveis — melhor pular que forçar par
- **EVITE** rodar TRACE em skills com 0 traces — primeiro acumule dados via Ouroboros

---

## Checklist de Verificação

```
□ collect-traces.sh retornou sufficient_for_contrastive: true?
□ Pares alinhados por similaridade real (não forçados)?
□ Deltas extraídos nos 5 eixos (steps, tools, info, decisions, quality)?
□ Gaps com 2+ deltas de evidência (não single-occurrence)?
□ Impact Score calculado (frequência x delta)?
□ Taxonomia IDs referenciados corretamente (IG-01, PR-02, etc.)?
□ Patch type classificado (knowledge/rule/tool/structural)?
□ Traces sintéticos marcados com generated_by: trace-capability?
□ Patches structural flaggeados para review humano?
□ Gap report gerado com template padrão?
```

---

## Referências

- **TRACE Paper:** arXiv 2604.05336 — Capability-Targeted Agentic Training (Stanford, 2026)
- **GEPA:** `.claude/skills/gepa-reflective/` — Diagnóstico causal que TRACE complementa
- **Taxonomia:** `references/capability-taxonomy.md` — 15 capacidades, 5 dimensões
- **Protocolo:** `references/contrastive-protocol.md` — Procedimento detalhado de análise
