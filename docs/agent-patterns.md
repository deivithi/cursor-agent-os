# 🤖 Agent Design Patterns (3 skills complementares)

---

## 🔄 Autonomous Agent Loop (1 skill — Karpathy Pattern)

**Repositório:** `.claude/skills/autonomous-agent-loop/` (extraído de: karpathy/autoresearch)
**Ativação:** Automática quando o contexto envolver design de agentes autônomos

### ⚡ Ativação Automática

Quando o usuário mencionar **agente autônomo, loop de experimentação, otimização autônoma, keep/discard, métrica única, time-boxed, blast radius, experiment loop, A/B testing autônomo, scoring autônomo**, o assistente **DEVE automaticamente**:

1. Ler `.claude/skills/autonomous-agent-loop/SKILL.md`
2. Aplicar os 10 padrões fundamentais ao contexto do usuário
3. Consultar `references/examples.md` para exemplos concretos

### 🏗️ 10 Padrões Fundamentais

| # | Padrão | Essência |
|---|--------|----------|
| 1 | 🔁 Forever Loop | Agente roda indefinidamente, nunca para para perguntar |
| 2 | 📏 Single Metric | Uma métrica única, imutável, computável automaticamente |
| 3 | 🔒 The Firewall | Separação rígida: imutável (avaliação) vs modificável (execução) |
| 4 | ⏱️ Fixed Budget | Todo experimento tem tempo fixo, resultados comparáveis |
| 5 | 📋 The Ledger | Log estruturado append-only (TSV) de todos os experimentos |
| 6 | 🎯 Keep/Discard/Crash | Decisão binária automática baseada na métrica |
| 7 | 💎 Simplicity Wins | Complexidade é custo — simplicidade é critério de keep |
| 8 | 💥 Blast Radius | Agente modifica APENAS escopo definido (1 arquivo/componente) |
| 9 | 📄 Program.md | Instruções estruturadas e completas para o agente |
| 10 | 🌿 Git as Lab | Cada experimento é um commit, histórico git = histórico de pesquisa |

---

## 🏗️ Agent Skill Patterns (1 skill — Google ADK Patterns + 3 Melhorias)

**Repositório:** `.claude/skills/agent-skill-patterns/` (extraído de: Google Cloud Tech / ADK)
**Ativação:** Automática quando o contexto envolver design de skills ou workflows de agentes

### ⚡ Ativação Automática

Quando o usuário mencionar **criar skill, design de agente, workflow de aprovação, pipeline de validação, reviewer, auditoria com scoring, gates de aprovação, Diamond Gate, severity scoring, gating instructions, padrão ADK**, o assistente **DEVE automaticamente**:

1. Ler `.claude/skills/agent-skill-patterns/SKILL.md`
2. Aplicar o padrão adequado ao contexto
3. Consultar `references/severity-matrix.md` para scoring de findings

### 📐 5 Padrões + 3 Melhorias

| # | Padrão | Essência | 🆕 Melhoria |
|---|--------|----------|-------------|
| 1 | 🔧 Tool Wrapper | Empacota conhecimento de ferramenta para carga dinâmica | — |
| 2 | 📝 Generator | Gera outputs padronizados via templates | — |
| 3 | 🔍 Reviewer | Avalia contra critérios predefinidos | 🆕 **Severity Scoring** (CRITICAL→INFO, thresholds) |
| 4 | 🔄 Inversion | Entrevista estruturada ANTES de executar | 🆕 **Gating Instructions** ("NÃO prossiga até...") |
| 5 | ⛓️ Pipeline | Workflow sequencial com checkpoints | 🆕 **Diamond Gates** (aprovação humana obrigatória) |

### 🔗 Integração com Comandos

| Comando | Padrão Integrado |
|---------|-----------------|
| `/make-plan` | **Inversion** com Gating Instructions na Fase 0 |
| `/do` | **Pipeline** com Diamond Gates para fluxos críticos |
| `/simplify` | **Reviewer** com Severity Scoring |

---

## 🤖 Agent Builder (1 skill — AgentScope Framework)

**Repositório:** `.claude/skills/agent-builder/` (fonte: AgentScope / Alibaba)
**Framework:** AgentScope v1.0.17+ (Apache 2.0, 18.4K ⭐, Python 3.10+)
**Ativação:** Automática quando o contexto envolver implementação/construção de agentes IA

### ⚡ Ativação Automática

Quando o usuário mencionar **criar agente, construir agente, agente IA, AgentScope, ReAct agent, multi-agent, agent builder, implementar agente, agent framework, orquestração de agentes, A2A, agent-to-agent**, o assistente **DEVE automaticamente**:

1. Ler `.claude/skills/agent-builder/SKILL.md`
2. Seguir o workflow de construção (Propósito → Componentes → Implementar → Testar → Deploy)
3. Consultar `references/` para detalhes técnicos (architecture, recipes, model-formatter-matrix)

### 🔺 Triângulo de Skills para Agentes

| Skill | Papel | Quando Usar |
|-------|-------|-------------|
| `agent-skill-patterns` | 🧠 **PENSAR** — Design patterns | Definir QUAL padrão seguir |
| `autonomous-agent-loop` | 🔄 **ESTRUTURAR** — Loops autônomos | Definir COMO o agente otimiza |
| `agent-builder` | 🔧 **CONSTRUIR** — Implementação | Definir COM QUE construir |

### 📂 Componentes Core AgentScope

| Módulo | Classe | Função |
|--------|--------|--------|
| Message | `Msg` | Comunicação universal entre agentes |
| Model | `OpenAI/Anthropic/Gemini/OllamaChatModel` | Integração LLM |
| Formatter | `{Provider}ChatFormatter` | Converte Msg → formato da API |
| Memory | `InMemory/SQLAlchemy/RedisMemory` | Contexto e histórico |
| Tool | `Toolkit` + `ToolResponse` | Ferramentas executáveis |
| Agent | `ReActAgent` / `AgentBase` | Loop ReAct (Reason + Act) |
| Pipeline | `MsgHub` + `sequential_pipeline` | Orquestração multi-agente |
| MCP | `HttpStatelessClient` | Conexão nativa com MCP servers |

---

## 🕸️ GAN Graph Executável (Workflow engine)

**Arquivo:** `.claude/workflows/gan-graph.js` — torna executável o grafo de 3 papéis do `agents/protocols/gan-loop.md` via tool `Workflow` do Claude Code.

**Grafo por round:** `Generate (worker) → Review (reviewer CEGO — recebe só o spec, inspeciona o repo sozinho) → Evaluate (evaluator — julga o produto E audita se o reviewer deixou passar issues)`. Loop até convergência.

**Invocação:** `Workflow({name: 'gan-graph', args: {task: '...'}})` — ou `scriptPath` apontando p/ o arquivo. `args` aceita objeto ou string JSON.

| Arg | Default | Função |
|---|---|---|
| `task` | obrigatório | O que implementar |
| `spec` | `null` | Se fornecido, pula fase Plan (planner.md) |
| `maxRounds` | `3` | Modo simplificado do gan-loop.md; full loop = 5-15 |
| `scoreMin` | `7.0` | Convergência: verdict PASS + score ≥ min + zero blocking |
| `blockSeverities` | `['CRITICAL','HIGH']` | Severidades que impedem PASS (contrato `data/severity-config.json`) |
| `workDir` | `null` | Restringe escopo de arquivos do worker/reviewer |
| `reviewerModel` / `evaluatorModel` | herda sessão | Verificação em modelo mais barato (token-efficiency) |

**Saídas de status:** `PASS` | `STAGNATION` (2 rounds sem redução de issues — adaptive-depth) | `MAX_ROUNDS` | `BLOCKED` | `AGENT_ERROR`.

**Fonte única de verdade:** os prompts mandam cada subagente **ler** `agents/worker.md` / `reviewer.md` / `evaluator.md` / `planner.md` — a doutrina não é duplicada no script.

🛡️ **Gate humano permanece:** task que toque cripto/LGPD/sanitização BD/operação destrutiva → worker retorna `blocked=true` e o grafo para com status `BLOCKED` (`rules/human-architectural-gate.md`).
