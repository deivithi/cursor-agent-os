---
name: mcp-rl
description: >
  Treinar modelos pequenos com Reinforcement Learning para dominar MCP tools.
  ART framework, GRPO, RULER scoring, MCP server como environment de treino.
  Keywords: MCP RL, reinforcement learning, tool use training, ART, GRPO, RULER, fine-tune agents.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write
metadata:
  author: deivithi
  version: "1.0"
  source: "patchy631/ai-engineering-hub (art_mcp_rl)"
---

# MCP-RL — Treinar Agentes com RL para Dominar MCP Tools

Pipeline para treinar modelos pequenos (3B-14B) via Reinforcement Learning a se tornarem experts em usar MCP servers. Em vez de depender de prompting e hoping, o modelo **pratica milhares de vezes** usando as tools e aprende quais estratégias funcionam. Um modelo de 3B aprende a explorar schemas, encadear tools e responder perguntas multi-step — skills que não tinha out of the box.

## Quando Usar

- Treinar modelo local (Ollama) para dominar MCP servers específicos (n8n, Supabase, GBrain)
- Criar agentes especializados em tool use para domínios específicos
- Substituir modelos grandes por modelos pequenos fine-tuned em tool chains
- Pesquisa/experimentação com RL para agentes

## Quando NÃO Usar (→ Handoff)

- Usar MCP tools com modelo grande (Claude/GPT) → usar `mcp-builder` diretamente
- Construir MCP server novo → usar `mcp-builder` ou `api-to-mcp`
- Fine-tuning para geração de texto (não tool use) → fora do escopo

## Conceitos-Chave

### ART (Agent Reinforcement Trainer)
Framework da OpenPipe para treinar LLMs com GRPO (Group Relative Policy Optimization). O agente interage com tools, recebe rewards, e melhora iterativamente.

### RULER (LLM-as-Judge)
Sistema de scoring automático que usa outro LLM para avaliar a qualidade das respostas do agente. Sem necessidade de dados rotulados manualmente.

### MCP Server como Environment
O MCP server funciona como **environment de RL** — o agente envia ações (tool calls), recebe observações (tool outputs), e é recompensado pela qualidade da resposta final.

## Workflow

### Fase 1 — Preparar o MCP Server (Environment)

```
Definir as tools do MCP server que o agente vai aprender:

Exemplo (database agent):
    ├── list_tables()      → descobrir tabelas disponíveis
    ├── describe_table(t)  → ver schema e colunas
    └── run_query(sql)     → executar SELECT queries

Exemplo (n8n agent):
    ├── list_workflows()   → ver workflows disponíveis
    ├── get_workflow(id)   → ver nodes e conexões
    └── execute_workflow()  → rodar workflow
```

**Regra:** Tools devem ser read-only para treino. O agente aprende a consultar, não a modificar.

### Fase 2 — Gerar Cenários de Treino

```python
# Usar LLM grande para gerar perguntas variadas sobre o domínio
scenarios = [
    "Quais funcionários do departamento de vendas ganham mais que a média?",
    "Liste os projetos atrasados com seus responsáveis",
    "Qual o budget total por departamento, ordenado do maior para menor?",
    # ... centenas de variações
]
```

**Dica:** Variar complexidade — 30% simples (1 tool call), 50% médias (2-3 calls), 20% complexas (4+ calls com JOINs/encadeamento).

### Fase 3 — Configurar Reward Scoring (RULER)

```python
# RULER avalia a resposta final do agente
reward_criteria = {
    "correctness": "A resposta está factualmente correta?",
    "completeness": "Todos os dados pedidos foram retornados?",
    "efficiency": "O agente usou número mínimo de tool calls?",
    "error_handling": "O agente se recuperou graciosamente de erros?"
}

# Score: 0.0 (péssimo) a 1.0 (perfeito)
# Sem dados rotulados — RULER usa LLM-as-judge
```

### Fase 4 — Treinar com GRPO

```
Loop de treinamento:
    1. Agente recebe pergunta
    2. Agente decide quais tools chamar (policy)
    3. Tools retornam resultados
    4. Agente pode chamar mais tools ou gerar resposta
    5. RULER avalia resposta → reward score
    6. GRPO atualiza weights do modelo
    7. Repetir por N episódios

Hiperparâmetros sugeridos (Qwen 3B):
    - Learning rate: 1e-6
    - Batch size: 4-8 (GPU-dependent)
    - Episodes: 500-2000
    - GPU: T4 16GB mínimo (Colab funciona)
```

### Fase 5 — Avaliar e Deployar

```
Métricas de avaliação:
    - Tool call accuracy: % de calls corretas
    - Task completion rate: % de perguntas respondidas corretamente
    - Efficiency: média de tool calls por task
    - Error recovery: % de recuperações após tool error

Deploy:
    - Exportar modelo fine-tuned para Ollama
    - Conectar como provider em MCP client
    - Testar em queries reais antes de produção
```

## Progressive Disclosure

| Complexidade | Comportamento |
|-------------|---------------|
| **Simples** | Explicar conceito + apontar para tutorial ART. Não treinar |
| **Médio** | Configurar environment MCP + gerar cenários + rodar treino básico (Colab) |
| **Complexo** | Pipeline completo: environment custom + RULER custom + treino GRPO + avaliação + deploy Ollama |

## Stack Técnico

| Componente | Ferramenta | Alternativa |
|-----------|-----------|-------------|
| RL Framework | [OpenPipe ART](https://github.com/OpenPipe/ART) | TRL (HuggingFace) |
| Reward Scoring | RULER (LLM-as-judge) | Manual labels |
| Base Model | Qwen 2.5 3B Instruct | Qwen 3B, Llama 3.2 3B |
| MCP Server | FastMCP + SQLite | Qualquer MCP server |
| GPU | T4 16GB (Colab free) | A100 para modelos maiores |
| Deploy | Ollama | vLLM, llama.cpp |

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Criar o MCP server que será environment | `mcp-builder` | Server não existe ainda |
| Avaliar qualidade do agente treinado | `evals` | Métricas de avaliação |
| Deploy do modelo em produção | `cicd` | CI/CD pipeline |

## Gotchas

1. **GPU obrigatória** → Sem GPU, não roda. T4 (Colab free) é o mínimo para 3B. Para 14B, precisa A100
2. **RULER depende de LLM externo** → Scoring usa OpenRouter/OpenAI. Custo de API para avaliação durante treino
3. **Overfitting em cenários limitados** → Gerar pelo menos 200+ cenários variados. Modelo decorar ≠ generalizar
4. **Read-only para treino** → NUNCA dar tools de escrita durante treino. Agente pode executar ações destrutivas aleatoriamente durante exploração
5. **Não substitui Claude para tarefas gerais** → Modelo 3B fine-tuned domina tool use ESPECÍFICO. Para raciocínio geral, continuar com Claude

## Referências

- `patchy631/ai-engineering-hub/art_mcp_rl` — Tutorial completo MCP-RL com ART + RULER + Qwen 3B
- [OpenPipe ART](https://github.com/OpenPipe/ART) — Framework de RL para agentes
- [GRPO Paper](https://arxiv.org/abs/2402.03300) — Group Relative Policy Optimization
- Conceito: MCP Server como RL Environment — treinar em vez de promptar
