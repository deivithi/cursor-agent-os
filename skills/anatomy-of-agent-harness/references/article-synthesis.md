# Síntese: The Anatomy of an Agent Harness

**Referência original (artigo no X):** https://x.com/akshay_pachaar/status/2041146899319971922  

**Nota legal e de método:** este ficheiro é uma **síntese** para operação neste monorepo — não reproduz o artigo na íntegra. Para citação exata ou nuances do autor, usar o link acima.

---

## 1. Definição e metáfora

- **LLM sozinho** comporta-se como processador sem sistema operativo completo: precisa de **RAM/disco/redes** no mundo do software — isto é o **harness**.
- **Scaffolding:** o harness é a estrutura que segura o modelo enquanto o produto e o contexto mudam; retirar o harness deixa a demo frágil.

**Takeaway para o repo:** investir em harness (regras, skills, verify, contexto) é investir em **produto**, não em “extras”.

---

## 2. Três níveis de engenharia (recapitulação)

1. **Prompt engineering** — o que se escreve como instrução ao modelo.  
2. **Context engineering** — curadoria do que o modelo **vê** (incluindo o que se omiti, resume ou carrega sob demanda).  
3. **Harness engineering** — orquestração, estado, ferramentas, erros, segurança, verificação, **lifecycle**.

Falhas em produção costumam ser **harness e contexto**, não “só escolher outro modelo”.

---

## 3. Context management — padrões citados no debate

| Padrão | Ideia | Alinhamento neste workspace |
|--------|--------|----------------------------|
| **Compaction** | Resumir histórico ao aproximar limites; preservar decisões e bugs abertos; descartar outputs redundantes de tools | `.claude/docs/compact-protocol.md` |
| **Observation masking** | Esconder outputs antigos de tools mantendo visível a estrutura das chamadas | Parcialmente: subagentes isolam ruído; Cursor/Claude compactam — documentar intenção ao desenhar fluxos |
| **Just-in-time retrieval** | Identificadores leves + carga dinâmica (grep, glob, head, tail vs. ficheiros inteiros) | Prática recomendada em exploração de código; skills `iterative-retrieval` |
| **Sub-agent delegation** | Exploração ampla no subagente; **retorno condensado** (ordem de ~1k–2k tokens de resumo) | Task tool + `spec-phases`; não repatriar dumps enormes |

---

## 4. Os 12 componentes (expandido)

1. **Orchestration loop** — ciclo pensar–agir–observar ou equivalente por fases; coração do agente.  
2. **Tools** — contratos estáveis, timeouts, erros surface-ados.  
3. **Memory** — facto estável vs. volátil; onde vive a verdade (ficheiros, DB, MCP).  
4. **Context management** — compaction, masking, JIT, orçamento de tokens entre passos.  
5. **Prompt construction** — montagem dinâmica (system + rules + RAG + estado).  
6. **Output parsing** — JSON, tool calls, validação; falha explícita quando o parse falha.  
7. **State management** — o que sobrevive entre turns e entre sessões.  
8. **Error handling** — retries com teto, circuit breaker em integrações, mensagens acionáveis.  
9. **Guardrails and safety** — entrada, saída, ações destrutivas; política de permissões.  
10. **Verification loops** — testes/linters (verdade determinística) + juiz LLM quando necessário (latência/custo).  
11. **Subagent orchestration** — divisão de trabalho, handoff, **resumo** obrigatório no retorno.  
12. **Lifecycle management** — versões de tools, deploy, feature flags, deprecação, continuidade entre janelas de contexto (ex. padrões tipo “Ralph loop” em tarefas longas).

**Artefactos citados no ecossistema** (nomes que o artigo/fio ligam a boas práticas): `CLAUDE.md`, `AGENTS.md`, `MEMORY.md` — neste repo os papéis análogos estão em `CLAUDE.md`, `AGENTS.md` e skills de memória/knowledge graph.

---

## 5. O loop em movimento (walkthrough genérico)

1. Utilizador objetivo → harness prepara contexto mínimo necessário.  
2. Modelo propõe ação (tool / código / pergunta).  
3. Harness executa com permissões e limites; captura **observação**.  
4. Harness decide: continuar, verificar, compactar, delegar ou pedir esclarecimento.  
5. Antes de declarar “pronto”, **verificação** (testes, smoke, checklist) quando aplicável.

---

## 6. Sete decisões que definem cada harness

| Decisão | Eixo | Implicação operacional |
|---------|------|-------------------------|
| 1 | **Single-agent vs multi-agent** | Maximizar um agente forte primeiro; multi-agente só quando o isolamento de contexto ou especialização compensa overhead (routing, perda em handoffs). |
| 2 | **ReAct vs plan-and-execute** | ReAct flexível por passo; plan-and-execute pode reduzir custo quando o plano é estável (trade-off citado no debate: velocidade vs flexibilidade). |
| 3 | **Estratégia de janela de contexto** | Limpeza temporal, sumarização, masking, notas estruturadas, delegação — combinar em função do produto. |
| 4 | **Design do loop de verificação** | Preferir verificação computacional quando existir ground truth; LLM-as-judge para lacunas semânticas, ciente de latência. |
| 5 | **Arquitetura de permissões** | Permissivo (veloz, arriscado) vs restritivo (lento, seguro) conforme superfície de ataque e ambiente. |
| 6 | **Tool scoping** | Menos tools bem escolhidas costuma bater mais tools genéricas; lazy loading / namespaces; evitar sprawl. |
| 7 | **Espessura do harness** | Quanta lógica fica no código do harness vs no modelo — tendência a harness mais fino quando o modelo melhora, mas **gestão de contexto e ferramentas** permanecem. |

---

## 7. “The harness is the product”

- Diferenciação sustentável está em **confiabilidade, auditabilidade, custo e segurança** — domínio do harness.  
- Para este workspace: **spec-verify**, **guardrails**, **compact-protocol**, **agent-harness** e o mapa em `.cursor/README.md` são a materialização dessa ideia.

---

## Ligações internas (índice)

- Skill resumo: `../SKILL.md`  
- Mapa Cursor: `.cursor/README.md`  
- Sessão longa / checkpoints: `.claude/skills/agent-harness/SKILL.md`  
- Guardrails: `.claude/skills/guardrails/SKILL.md`  
- Compactação: `.claude/docs/compact-protocol.md`  
- Automações / observações: `.cursor/skills/stack-automacoes/SKILL.md`
