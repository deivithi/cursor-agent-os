# 🔗 Padrões de Integração — AgentScope + Stack Deivithi

> Como conectar agentes AgentScope com o ecossistema existente.

---

## 1. AgentScope + n8n (Webhook ↔ Agente)

### Padrão: n8n Trigga Agente via API

```
n8n Webhook → HTTP Request → AgentScope API → Resposta → n8n continua
```

**Lado AgentScope (FastAPI wrapper):**

```python
from fastapi import FastAPI
from agentscope.agent import ReActAgent
from agentscope.message import Msg
import asyncio

app = FastAPI()
agent = ReActAgent(name="Processor", ...)  # configurado

@app.post("/process")
async def process(data: dict):
    msg = Msg("user", str(data), "user")
    response = await agent(msg)
    return {"result": response.get_text_content()}
```

**Lado n8n:**
- Node: HTTP Request
- Method: POST
- URL: `http://localhost:8000/process`
- Body: JSON com dados do workflow

### Padrão: Agente Usa n8n MCP

```python
from agentscope.mcp import HttpStatelessClient

n8n_mcp = HttpStatelessClient(
    name="n8n",
    transport="streamable_http",
    url="http://localhost:5678/mcp",
)
toolkit.register_mcp_client(n8n_mcp)
```

---

## 2. AgentScope + Supabase (Memória Persistente)

### Padrão: Supabase como Backend de Memória

```python
from agentscope.memory import AsyncSQLAlchemyMemory

# Conexão direta via SQLAlchemy
memory = AsyncSQLAlchemyMemory(
    connection_string="postgresql+asyncpg://user:pass@host:5432/db"
)

agent = ReActAgent(
    name="Agent",
    memory=memory,  # Memória persistente em Supabase PostgreSQL
    ...
)
```

### Padrão: Supabase MCP para Operações

```python
from agentscope.mcp import HttpStatelessClient

supabase_mcp = HttpStatelessClient(
    name="supabase",
    transport="streamable_http",
    url="https://supabase-mcp-endpoint...",
)
toolkit.register_mcp_client(supabase_mcp)
```

---

## 3. AgentScope + MCPs Existentes

AgentScope tem MCP client nativo. Qualquer MCP server pode ser conectado:

```python
from agentscope.mcp import HttpStatelessClient, StdIOStatefulClient

# MCP HTTP (Context7, Tavily, etc.)
context7 = HttpStatelessClient(
    name="context7",
    transport="streamable_http",
    url="https://mcp.context7.com/mcp",
)

# MCP stdio (markitdown, memory, etc.)
# Usar StdIOStatefulClient para MCPs locais
markitdown = StdIOStatefulClient(
    name="markitdown",
    command="markitdown-mcp",
    args=[],
)

# Registrar todos no toolkit
toolkit.register_mcp_client(context7)
toolkit.register_mcp_client(markitdown)
```

---

## 4. AgentScope + Skills do Nosso Ecossistema

Nossas skills seguem o padrão SKILL.md — compatível nativo com AgentScope:

```python
# Registrar skills existentes
toolkit.register_tool_function(view_text_file)  # OBRIGATÓRIO

toolkit.register_agent_skill("./.claude/skills/lead-audit")
toolkit.register_agent_skill("./.claude/skills/commission-audit")
toolkit.register_agent_skill("./.claude/skills/code-review")
```

> O agente lerá automaticamente o SKILL.md de cada skill quando precisar.

---

## 5. Deploy Patterns

### Local (Desenvolvimento)

```bash
# Script direto
python agent.py

# Com uvicorn (API)
uvicorn agent_api:app --host 0.0.0.0 --port 8000
```

### Serverless (Vercel/Cloudflare)

```python
# Adaptar para serverless handler
# Limitação: sem estado entre requests (usar memória externa)
```

### AgentScope Runtime (Produção)

```bash
# Agent-as-API via Runtime
# Docs: https://runtime.agentscope.io

# Runtime oferece:
# - Sandbox seguro para tools
# - Agent-as-API endpoints
# - State persistence
# - Kubernetes clustering
# - Load balancing
```

### Com PM2 (como n8n)

```bash
# Usar PM2 para manter agente rodando
pm2 start agent.py --name "lead-scorer" --interpreter python
pm2 save
```

---

## 6. Padrão Completo: Triângulo de Skills

Ao construir um agente, usar as 3 skills complementares:

```
1. /agent-skill-patterns (PENSAR)
   └── Qual padrão usar? (Tool Wrapper, Reviewer, Pipeline...)
   └── Precisa de Diamond Gate? Severity Scoring?

2. /autonomous-agent-loop (ESTRUTURAR)
   └── É agente autônomo? Definir single metric
   └── Loop: keep/discard/crash
   └── Blast radius: escopo limitado

3. /agent-builder (CONSTRUIR) ← esta skill
   └── Escolher componentes (Model, Formatter, Memory, Tools)
   └── Implementar com AgentScope
   └── Testar e deployar
```
