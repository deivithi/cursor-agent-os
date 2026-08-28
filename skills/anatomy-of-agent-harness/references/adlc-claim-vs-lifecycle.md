# ADLC — claim Limestone vs lifecycle institucional

Nota curta (sem skill nova). Contexto: tweet/material sobre “ADLC” / agentic delivery.

**Fonte primaria deste refinemento:** [mardehaym @ LimestoneHQ](https://x.com/mardehaym/status/2086769996496077036) (2026-08-10) — fetch via agent-reach / OpenCLI twitter. Imagem no post ilustra “8 steps / humans everywhere” vs “2 human gates”.

## Homônimo critico (nao misturar)

| Uso | Significado | Exemplos |
|-----|-------------|----------|
| **ADLC institucional** | Ciclo de vida para **construir e operar o agente** (probabilistico): plan, build, eval, deploy, operate, monitor | [IBM ADLC](https://www.ibm.com/think/topics/agent-development-lifecycle-adlc), [Glean ADLC](https://docs.glean.com/agents/agent-development-lifecycle/adlc), Atlan (contexto + governanca) |
| **“ADLC” de vendedor (Limestone)** | **SDLC agentizado** — agentes escrevem o software de produto; humanos so em poucos gates | Tweet Limestone: goal humano → PRD/arch/code/test/deploy/monitor por agentes |

Mesma sigla, objetos diferentes. Em decisao local: se o assunto e *como fabricamos software com agentes*, e harness + spec gates. Se o assunto e *como gerimos o proprio agente em producao*, e ADLC institucional (eval-first, drift, catalogo).

## Claim de vendedor (rotular)

Limestone (e similares) costumam vender:

- **2 gates humanos** + **6 passos agent-driven** (mesmo “8 steps”, menos supervisao humana)
- Ciclo **horas/dias** vs semanas/meses
- **~98% do codigo** nos pods nao e handwritten
- Agentes “nao so skimam PR — pegam mais edge cases”

Tratar como **claim de marketing / experiencia de firma**, nao como padrao medido nem como politica local. Sem fonte auditavel no material → `[Claim]` / `[Nao verificado]`. CTA de discovery call / newsletter no fio = lead gen.

## O que o mundo confirma (conceito)

**ADLC** institucional (IBM / Glean / Atlan e correlatos) aponta para:

- ciclo de vida agentic com **gates** humanos em pontos de risco  
- **eval** / verificacao continua, nao so “gerar e mergear”  
- governanca de harness (contexto, tools, verify) — nao vibe coding  
- diferenca estrutural SDLC vs ADLC: deterministico vs probabilistico; code-first vs **outcome/eval-first** (IBM)

O *conceito* (lifecycle + gates + eval + observabilidade) e solido; o *numero* 98% / “so 2 gates” / “horas a dias” nao.

## Sinais uteis do fio (nao viram padrao sozinhos)

Respostas no thread reforcam restrições que o claim omite:

- **Memoria institucional** — sem durable memory, o agente rediscobre as mesmas decisoes a cada ciclo  
- **Rollback barato** — reduzir gates humanos so funciona se desfazer for barato  
- **Especificacao como gargalo** — quando execucao colapsa, o recurso escasso e clareza de spec, nao velocidade de codigo  

Alinha com o mapa local (spec gates + harness verify + memoria/checkpoints).

## Mapa local (ja existe — nao criar skill concorrente)

| Necessidade | Onde vive aqui |
|-------------|----------------|
| Gates / spec antes de codar | `spec-driven-core`, `contrato-tarefa-agente` |
| Harness / verify / anatomy | `anatomy-of-agent-harness` |
| Persistencia / checkpoints | `agent-harness` |
| Fetch de material solto | `material-solto` Passo 0 + `agent-reach` |

Factory floor = spec gates + harness verify (+ memoria institucional). Expandir esses artefatos; **nao** abrir skill `adlc-*` paralela.
