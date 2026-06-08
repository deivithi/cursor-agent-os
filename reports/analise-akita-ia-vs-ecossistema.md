# Análise — Boas Práticas de IA (Akita / Augusto Galego) × Nosso Ecossistema

> **Fonte:** vídeo _"Práticas do Akita com IA. Deu bom?"_ — Augusto Galego (01/06/2026, 21min).
> **Objetivo:** destilar a lógica do vídeo, comparar com o nosso funcionamento
> (`rules/` + `.claude/skills/` + `agents/` + `hooks/`) e mapear os gaps para sermos
> uma ferramenta de criação/operação profissional.
> **Data:** 2026-06-02. **Veredito:** ~80% já coberto; 4 gaps críticos + melhorias fechados nesta rodada.

---

## 1. A lógica do vídeo (13 ideias)

1. **Mito do one-shot prompt** — não perseguir o "prompt perfeito". One-shot só resolve tarefas triviais (~90%); para o resto é ilusão.
2. **Groomy** — em vez de adivinhar, _entrevistar_ o operador até entendimento mútuo. Conversar como com outra pessoa.
3. **Intenção > implementação** — modelos com thinking se importam com o "porquê". Descrever só a implementação leva a caminho errado; explicitar objetivo/impacto no usuário reduz desvio.
4. **Fluxo Task → conversa → PRD → código** — não jogar a task direto no agente. Conversar com a IA para gerar um PRD; quando o PRD está bom, aí sim implementar.
5. **PRs pequenos (~300, máx 500 linhas)** — épicos/milestones/stories quebrados em tasks pequenas com **boundaries claros** (input/output de API, quem faz migração de banco etc.). Sem clareza de fronteira → retrabalho.
6. **Tickets com intenção** — incluir _por que_ o ticket existe. Task pequena com pouco contexto é mal interpretada → mais trabalho de revisão.
7. **TDD ficou barato com IA** — criar ferramental de testes (script/handler para rodar) e referenciá-lo no `agents.md`/`CLAUDE.md`.
8. **agents.md / CLAUDE.md = pré-prompt** — incluído em todo prompt. Regras típicas: _pense antes de codar, declare presunções, pergunte em vez de adivinhar, simplicidade primeiro, mudanças cirúrgicas, goal-driven execution, testes que verificam intenção (não só comportamento)_. **Não fazer MD de 1000 linhas** — informação dilui no contexto e a IA ignora.
9. **APIs detalhadas / OpenAPI spec** — input/output bem descritos viram contexto excelente para a IA; gera menos divergência.
10. **MCPs úteis: GitHub + Task Manager** — aceleram (menos cliques). A maioria dos outros MCPs tem pouca utilidade.
11. **Code Rabbit loop** — review automático com idas e vindas (sugestões voltam ao agente sem input humano); revisão final humana.
12. **O que NÃO fazer:** deletar testes (nunca, sem aceite explícito); pular pre-commit/branch protection; rodar `--dangerously-skip-permissions` fora de sandbox/dev-container; **over-engineering / token-maxing** (mais tokens/código ≠ valor — gera código prolixo, vulnerabilidades, lentidão); MD gigante; **paralelismo excessivo** (a 4+ agentes o humano vira gargalo e só faz malabarismo).
13. **A realidade:** a IA faz a maior parte do **código**, não do **trabalho**. Criar tasks, revisar, montar setup, entender codebase/docs/cliente continuam tarefas humanas grandes — a IA _acelera_, não _facilita_.

---

## 2. Mapa comparativo (conceito → onde cobrimos → status)

| Conceito do vídeo                                        | Onde cobrimos                                                             | Status                                                |
| -------------------------------------------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------- |
| Anti one-shot / planejar antes                           | `spec-driven-core`, `spec-epic`, `workflow-patterns.md` §1                | ✅ Forte                                              |
| Groomy (entrevistar até entendimento)                    | `spec-epic` Discovery (elicitação ativa), `anti-sycophancy.md`            | ✅ Forte                                              |
| Intenção/objetivo ("porquê")                             | `spec-epic` ("captura o why"), `calibration.md`                           | ✅                                                    |
| PRD → tech plan → tickets                                | `spec-epic` (pipeline de 5 artefatos)                                     | ✅ Forte                                              |
| Mini-specs > monolitos / doc 1-2 págs                    | `spec-epic` ("Mini-specs > Monolitos")                                    | ✅                                                    |
| PRs pequenos ~300-500 linhas                             | `workflow-patterns.md` §8 (mediana ~120, p90 <500)                        | ✅                                                    |
| Pré-prompt / agents.md                                   | `rules/` modulares + hooks (sem CLAUDE.md monolítico)                     | ✅ (modular — supera o MD único)                      |
| Regras de conduta (simplicidade, cirúrgico, goal-driven) | `clean-code-rules`, `workflow-patterns`, `calibration`, `anti-sycophancy` | ✅ Forte                                              |
| APIs detalhadas / OpenAPI                                | `api-forge`, `api-to-mcp`                                                 | ✅                                                    |
| MCPs (GitHub + Task)                                     | `github-mentions`, Linear/Asana MCP (e muitos outros)                     | ✅                                                    |
| Code Rabbit loop                                         | `auto-pr-review` (n8n + `gh` + `data/severity-config.json`)               | ✅                                                    |
| Anti over-engineering / token-maxing                     | `clean-code-rules`, `workflow-patterns` §5, `token-efficiency.md`         | ✅ Forte                                              |
| Precisão > volume                                        | `calibration.md`, `anti-sycophancy.md`                                    | ✅                                                    |
| Não fazer MD gigante (diluição)                          | `token-efficiency` (context hygiene) + progressive disclosure das skills  | ✅ (conceito)                                         |
| **TDD barato + ferramental de testes**                   | `alpha-loop` (referenciava skill inexistente)                             | ✅ corrigido (skill `test-driven-development` criada) |
| **Nunca deletar testes sem aceite**                      | —                                                                         | ✅ criado (`rules/test-integrity.md` + guard)         |
| **Pre-commit + branch protection**                       | só "squash merge" em `workflow-patterns` §8                               | ✅ criado (`hooks/git-safety-guard.js` + template)    |
| **Estratégia de paralelismo**                            | `workflow-patterns` §2 dizia só "use com liberdade"                       | ✅ resolvido (reviewer-agent por etapa)               |
| **Boundaries I/O explícitas por ticket**                 | `spec-epic`/`spec-phases` (genérico)                                      | ✅ reforçado (template de ticket)                     |
| Sandbox p/ skip-permissions                              | `workflow-patterns` §7 (só menção a `/sandbox`)                           | ✅ formalizado (`rules/sandbox-dangerous.md`)         |

---

## 3. Gaps fechados nesta rodada

### Críticos

- **C1 — Integridade de testes:** `rules/test-integrity.md`. Proíbe deletar/`skip`/`xfail`/comentar/enfraquecer assert de teste sem aceite explícito. Reforçado por hook.
- **C2 — Skill `test-driven-development`:** criada em `skills/test-driven-development/`. Resolve link quebrado referenciado por `alpha-loop` e `golang-activate.md`. Cobre Red-Green-Refactor, testes de intenção e ferramental padronizado de rodar testes por stack.
- **C3 — Pre-commit + branch protection:** `hooks/git-safety-guard.js` (preToolUse: confirma commit/push em `main`, bloqueia force-push em main, confirma remoção de arquivos de teste) + template git pre-commit por projeto em `hooks/templates/`.
- **C4 — Reviewer-agent por etapa:** `workflow-patterns.md` §2/§4 reescritas. Cada etapa de implementação passa por agente revisor independente/adversarial (motor: `code-review` + `spec-verify` + `data/severity-config.json`), **sem humano no loop de rotina**. Salvaguarda: `human-architectural-gate.md` retém o humano em cripto/LGPD/sanitização BD/destrutivo.

### Melhorias

- **M1 — Boundaries I/O por ticket:** template de ticket exige input/output/contrato/erros/quem-faz-migração/tamanho-alvo (~300-500 linhas); OpenAPI via `api-forge` para APIs.
- **M2 — Sandbox:** `rules/sandbox-dangerous.md` — `--dangerously-skip-permissions` só em dev container isolado. Cross-link Blast Radius Limiter (`HARNESS.md`).
- **M3 — Modelo operacional:** princípio "IA coda → agente revisa → humano arquiteta" em `workflow-patterns.md`.

---

## 4. Onde já superamos o vídeo

- **Pré-prompt modular** — em vez de um `agents.md` único (que o próprio vídeo alerta virar 1000 linhas diluídas), usamos `rules/` modulares + progressive disclosure por skill: cada regra carrega só quando o contexto casa.
- **Calibração + anti-sycophancy** — o vídeo fala de intenção; nós adicionamos rótulo de confiança (`calibration.md`) e challenge ativo de instruções subótimas.
- **Human Architectural Gate** — bloqueio formal para cripto/LGPD/sanitização BD, além do que o vídeo discute.
- **Adaptive-depth + zoom-out** — detecção de estagnação de loop e drift de escopo (o vídeo só menciona "não iterar à toa").

---

## 5. O que o vídeo lembra e devemos manter vivo

- A IA acelera, **não substitui** o trabalho de pensar/arquitetar/revisar. Mesmo com reviewer-agent, o humano decide arquitetura e gates irreversíveis.
- **Precisão > volume**: doc de 1-2 páginas vence um de 6-7. Token-maxing é antipadrão.
- **Fronteiras claras** por ticket continuam sendo o maior previsor de assertividade.
