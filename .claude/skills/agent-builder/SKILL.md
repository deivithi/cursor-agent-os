---
name: agent-builder
description: >-
  Guia prático para construir agentes IA production-ready usando AgentScope.
  Cobre arquitetura ReAct, ferramentas, memória, multi-agentes, MCP, skills e deploy.
  Use quando o usuário pedir "criar agente", "construir agente", "agente IA",
  "AgentScope", "ReAct agent", "multi-agent", "agent builder",
  "implementar agente", "agent framework", "orquestração de agentes",
  "agent-to-agent", "A2A", ou qualquer tarefa de implementação de agentes.
  Complementa agent-skill-patterns (design) e autonomous-agent-loop (loops).
license: Apache-2.0
domain: ai-infrastructure
subdomain: agent-implementation
version: 1.0.0
author: deivithi
tags:
  - agentscope
  - agents
  - react
  - multi-agent
  - mcp
  - tools
  - memory
  - deploy
  - production
metadata:
  skill-author: Deivithi
  source: https://github.com/agentscope-ai/agentscope
  docs: https://doc.agentscope.io
  extracted: 2026-03-22
  created: 2026-03-22
---

# 🤖 Agent Builder — Construção Prática de Agentes IA

> O triângulo completo: **agent-skill-patterns** (PENSAR) → **autonomous-agent-loop** (ESTRUTURAR) → **agent-builder** (CONSTRUIR).
> Framework principal: **AgentScope** (Alibaba, 18.4K ⭐, Apache 2.0, Python 3.10+).

---

## 📁 Estrutura de Arquivos

- `SKILL.md` — Este arquivo (workflow principal)
- `gotchas.md` — Armadilhas conhecidas e soluções
- `references/architecture.md` — Arquitetura core detalhada (6 módulos)
- `references/model-formatter-matrix.md` — Mapeamento provider → model → formatter
- `references/recipes.md` — Templates prontos para agentes comuns
- `references/comparison-matrix.md` — AgentScope vs CrewAI vs LangGraph vs AutoGen
- `references/integration-patterns.md` — Integração com n8n, Supabase, MCPs

---

## 🔗 Related Skills

- `agent-skill-patterns` — **COMO PENSAR**: 5 padrões de design (Tool Wrapper, Generator, Reviewer, Inversion, Pipeline) + Severity Scoring, Diamond Gates
- `autonomous-agent-loop` — **COMO ESTRUTURAR**: 10 padrões Karpathy (Forever Loop, Single Metric, Keep/Discard, Blast Radius)
- `/n8n` — Orquestração de workflows que triggam agentes
- `/api-forge` — Integração segura de APIs externas como tools do agente
- `/deploy-checklist` — Validação pré-deploy para agentes em produção

---

## 🧠 Princípios Fundamentais

```
📌 Async-first — Tudo em AgentScope é async/await
📌 Formatter DEVE combinar com Model — Pareamento obrigatório
📌 Skills precisam de tools de leitura — Sem read_file, skills não funcionam
📌 Tool groups > Tools avulsas — Evitar paradoxo da escolha
📌 Message é o contrato — Msg unifica toda comunicação
📌 Estado é serializável — state_dict/load_state_dict para persistência
📌 MCP nativo — Sem wrappers, conexão direta
```

---

## ⚡ Quick Start (5 minutos)

### Passo 0: Instalação

```bash
pip install agentscope
# Com suporte distribuído:
pip install agentscope[distribute]
# Dependência para skills:
pip install python-frontmatter
```

### Passo 1: Agente Mínimo Funcional

```python
import asyncio
from agentscope.agent import ReActAgent
from agentscope.model import OpenAIChatModel
from agentscope.formatter import OpenAIChatFormatter
from agentscope.memory import InMemoryMemory
from agentscope.tool import Toolkit
from agentscope.message import Msg

# 1. Modelo
model = OpenAIChatModel(
    model_name="gpt-4o",
    api_key="sk-...",
    stream=True,
    enable_thinking=False,  # IMPORTANTE para tool-use
)

# 2. Toolkit com ferramentas
toolkit = Toolkit()

# 3. Agente ReAct
agent = ReActAgent(
    name="Assistente",
    sys_prompt="Você é um assistente útil.",
    model=model,
    formatter=OpenAIChatFormatter(),
    toolkit=toolkit,
    memory=InMemoryMemory(),
)

# 4. Executar (async obrigatório)
async def main():
    response = await agent(Msg("user", "Olá!", "user"))
    print(response.get_text_content())

asyncio.run(main())
```

### Passo 2: Adicionar Tools

```python
from agentscope.tool import ToolResponse

def buscar_clima(cidade: str) -> ToolResponse:
    """Busca a previsão do tempo para uma cidade.

    Args:
        cidade: Nome da cidade para consultar.
    """
    # Implementação real aqui
    return ToolResponse(
        status="success",
        content=f"Tempo em {cidade}: 25°C, ensolarado"
    )

toolkit.register_tool_function(buscar_clima)
```

### Passo 3: Adicionar Skills

```python
from agentscope.tool import execute_shell_command, view_text_file

# Agente PRECISA de tools de leitura para usar skills
toolkit.register_tool_function(view_text_file)
toolkit.register_tool_function(execute_shell_command)

# Registrar skill (pasta com SKILL.md)
toolkit.register_agent_skill("./skills/minha-skill")
```

---

## 🏗️ Workflow Principal: Construir um Agente

### Fase 1: Definir o Propósito

Antes de codificar, responda:

| Pergunta | Exemplo |
|----------|---------|
| O que o agente FAZ? | Audita leads e gera relatório |
| Quais TOOLS precisa? | Consultar Salesforce, gerar PDF |
| Precisa de MEMÓRIA? | Sim, manter contexto entre sessões |
| É MULTI-AGENT? | Não, agente solo com pipeline |
| Qual MODELO usar? | Claude (Anthropic) para raciocínio |
| Como será DEPLOYADO? | API endpoint via Runtime |

> 🔗 Use `agent-skill-patterns` (Inversion Pattern) para esta fase de descoberta.

### Fase 2: Escolher Componentes

Consulte `references/architecture.md` para detalhes de cada módulo.

| Módulo | Opções | Quando |
|--------|--------|--------|
| **Model** | OpenAI, Anthropic, DashScope, Gemini, Ollama | Conforme provider |
| **Formatter** | Deve COMBINAR com o Model escolhido | Sempre pareado |
| **Memory** | InMemory, SQLAlchemy, Redis | Escopo e persistência |
| **Tools** | Funções Python, MCP clients, built-ins | Conforme necessidade |
| **Skills** | Pastas com SKILL.md | Conhecimento especializado |

> 📋 Consulte `references/model-formatter-matrix.md` para pareamento correto.

### Fase 3: Implementar

#### 3a. Agente Solo (mais comum)

Use o template do Quick Start acima. Para agentes mais complexos, consulte `references/recipes.md`.

#### 3b. Multi-Agent com MsgHub

```python
from agentscope.pipeline import MsgHub, sequential_pipeline

researcher = ReActAgent(name="Pesquisador", ...)
analyst = ReActAgent(name="Analista", ...)
writer = ReActAgent(name="Redator", ...)

async def pipeline_multi():
    async with MsgHub(
        participants=[researcher, analyst, writer],
        announcement=Msg("Host", "Analisem o relatório de leads.", "assistant")
    ) as hub:
        await sequential_pipeline([researcher, analyst, writer])

asyncio.run(pipeline_multi())
```

#### 3c. Integração MCP

```python
from agentscope.mcp import HttpStatelessClient

# Conectar a MCP server externo
mcp_client = HttpStatelessClient(
    name="n8n_mcp",
    transport="streamable_http",
    url="http://localhost:5678/mcp",
)

# Registrar TODAS as tools do MCP no toolkit
toolkit.register_mcp_client(mcp_client)
```

### Fase 4: Testar e Validar

```python
# Teste unitário de tool
result = buscar_clima("São Paulo")
assert result.status == "success"

# Teste de integração do agente
async def test_agent():
    msg = await agent(Msg("user", "Qual o clima em SP?", "user"))
    assert "São Paulo" in msg.get_text_content()

asyncio.run(test_agent())
```

### Fase 5: Deploy

| Método | Complexidade | Quando |
|--------|-------------|--------|
| Script local | ⭐ | Desenvolvimento, testes |
| API endpoint | ⭐⭐ | Integração com n8n/webhooks |
| AgentScope Runtime | ⭐⭐⭐ | Produção, escala, K8s |

Consulte `references/integration-patterns.md` para deploy patterns.

---

## 🔧 Agente Customizado (do Zero)

Quando `ReActAgent` não é suficiente:

```python
from agentscope.agent import AgentBase
from agentscope.message import Msg

class AuditorAgent(AgentBase):
    def __init__(self, rules: list[str]) -> None:
        super().__init__()
        self.name = "Auditor"
        self.rules = rules
        self.sys_prompt = f"Audite dados usando: {', '.join(rules)}"
        self.model = AnthropicChatModel(
            model_name="claude-sonnet-4-6",
            api_key="...",
            stream=True,
        )
        self.formatter = AnthropicChatFormatter()
        self.memory = InMemoryMemory()

    async def reply(self, msg: Msg | list[Msg] | None) -> Msg:
        await self.memory.add(msg)
        prompt = await self.formatter.format([
            Msg("system", self.sys_prompt, "system"),
            *await self.memory.get_memory(),
        ])
        response = await self.model(prompt)
        result = Msg(self.name, response.content, "assistant")
        await self.memory.add(result)
        await self.print(result)
        return result

    async def observe(self, msg: Msg | list[Msg] | None) -> None:
        await self.memory.add(msg)

    async def handle_interrupt(self) -> Msg:
        return Msg(self.name, "Auditoria interrompida.", "assistant")
```

---

## 🔴 Anti-Patterns

### ❌ AP-01: Esquecer async/await

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | Chamar `agent(msg)` sem `await` |
| **Consequência** | Retorna coroutine, não Msg — falha silenciosa |
| **Regra** | TUDO é async. Sempre `await agent(msg)` e `asyncio.run()` |

### ❌ AP-02: Formatter errado para o Model

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | Usar `OpenAIChatFormatter` com `AnthropicChatModel` |
| **Consequência** | Erro de formato na API, resposta quebrada |
| **Regra** | Consultar `references/model-formatter-matrix.md`. Pareamento 1:1 obrigatório |

### ❌ AP-03: Skills sem tools de leitura

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | `register_agent_skill()` sem `view_text_file` no toolkit |
| **Consequência** | Agente sabe que a skill existe mas não consegue ler o SKILL.md |
| **Regra** | SEMPRE registrar `view_text_file` ou `execute_shell_command` antes de skills |

### ❌ AP-04: enable_thinking=True com tool-use

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | Modelo com thinking habilitado tentando usar tools |
| **Consequência** | Conflito entre thinking blocks e tool calls |
| **Regra** | `enable_thinking=False` para agentes que usam ferramentas |

### ❌ AP-05: MCP client não fechado (stateful)

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | Abrir múltiplos MCP stateful clients sem fechar em ordem LIFO |
| **Consequência** | Conexões órfãs, erros de sessão |
| **Regra** | Fechar stateful clients em ordem LIFO (último aberto = primeiro fechado) |

---

## ✅ Checklist de Qualidade

Antes de considerar um agente pronto:

```
□ Instalação: agentscope + python-frontmatter instalados?
□ Async: Todo código usa async/await + asyncio.run()?
□ Model + Formatter: Pareamento correto? (ver matrix)
□ enable_thinking: False para agentes com tools?
□ Tools: Retornam ToolResponse com status?
□ Skills: view_text_file registrado no toolkit?
□ Memory: Tipo adequado ao escopo (InMemory vs Redis)?
□ Testes: Tool unitário + agente integração?
□ MCP: Clients fechados em ordem LIFO?
□ Deploy: Método escolhido e validado?
```

---

## 📐 Cheat Sheet — Decisão Rápida

```
Preciso de um agente?
├── Solo, com ferramentas → ReActAgent + Toolkit
├── Solo, lógica custom → Herdar AgentBase
├── Multi-agente, sequencial → MsgHub + sequential_pipeline
├── Multi-agente, broadcast → MsgHub com broadcast
├── Com MCP externo → HttpStatelessClient + register_mcp_client
├── Com skills → register_agent_skill + view_text_file
├── Com memória longa → SQLAlchemy ou Redis memory
├── Deploy local → asyncio.run() em script
├── Deploy API → AgentScope Runtime (Agent-as-API)
└── Deploy escala → Runtime + Kubernetes
```

---

## 📚 Referências

- **Repositório:** https://github.com/agentscope-ai/agentscope
- **Documentação:** https://doc.agentscope.io
- **Samples:** https://github.com/agentscope-ai/agentscope-samples
- **Runtime:** https://runtime.agentscope.io
- **Paper:** https://arxiv.org/html/2508.16279v1
