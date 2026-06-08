# 🏗️ Arquitetura Core — AgentScope

> Referência detalhada dos 6 módulos abstratos do framework.
> Consulte quando precisar entender componentes internos.

---

## 1. Message (`Msg`)

Estrutura universal de comunicação entre agentes.

```python
from agentscope.message import Msg, TextBlock, ImageBlock, ToolUseBlock, ToolResultBlock, ThinkingBlock

# Mensagem simples
msg = Msg(name="user", content="Olá", role="user")

# Mensagem multimodal
msg = Msg(name="Jarvis", role="assistant", content=[
    TextBlock(type="text", text="Aqui está a imagem"),
    ImageBlock(type="image", source=Base64Source(
        type="base64", media_type="image/jpeg", data="..."
    )),
])

# Métodos úteis
msg.get_text_content()                    # → str
msg.get_content_blocks(ToolUseBlock)      # → list[ToolUseBlock]
msg.has_content_blocks(ToolUseBlock)      # → bool
msg.to_dict()                             # → dict (serialize)
Msg.from_dict(data)                       # → Msg (deserialize)
```

**Campos:**

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `name` | str | Nome do remetente |
| `role` | str | "system", "assistant", "user" |
| `content` | str \| list[ContentBlock] | Texto ou blocos multimodais |
| `metadata` | dict (opcional) | Metadados adicionais |

---

## 2. Model

Classes de modelo por provider. Cada uma encapsula a API do provider.

```python
from agentscope.model import (
    OpenAIChatModel,
    AnthropicChatModel,
    DashScopeChatModel,
    GeminiChatModel,
    OllamaChatModel,
)
```

**Parâmetros comuns do construtor:**

| Param | Tipo | Descrição |
|-------|------|-----------|
| `model_name` | str | ID do modelo (ex: "gpt-4o", "claude-sonnet-4-6") |
| `api_key` | str | Chave da API |
| `stream` | bool | Streaming de resposta |
| `enable_thinking` | bool | Modo thinking (False para tool-use) |
| `client_kwargs` | dict | Args extras (ex: `base_url` para vLLM) |
| `generate_kwargs` | dict | Args de geração (ex: `temperature`, `max_tokens`) |

---

## 3. Formatter

Converte `Msg` para o formato esperado pela API do provider. **DEVE combinar com o Model.**

```python
from agentscope.formatter import (
    OpenAIChatFormatter,
    AnthropicChatFormatter,
    DashScopeChatFormatter,
    GeminiChatFormatter,
    OllamaChatFormatter,
    DeepSeekChatFormatter,
)
```

**Uso:**

```python
prompt = await formatter.format([
    Msg("system", "Prompt do sistema", "system"),
    *await memory.get_memory(),
])
response = await model(prompt)
```

> ⚠️ Ver `references/model-formatter-matrix.md` para pareamento completo.

---

## 4. Memory

Gerencia histórico de conversação e contexto.

```python
from agentscope.memory import InMemoryMemory

memory = InMemoryMemory()

await memory.add(msg)                           # Adicionar mensagem
await memory.add([msg1, msg2], marks="hint")    # Com marcador
msgs = await memory.get_memory()                # Recuperar todas
msgs = await memory.get_memory(mark="hint")     # Filtrar por marca
count = await memory.delete_by_mark("hint")     # Deletar por marca
await memory.clear()                            # Limpar tudo

# Persistência
state = await memory.state_dict()               # Serializar
await memory.load_state_dict(state)              # Restaurar
```

**Implementações:**

| Classe | Persistência | Quando usar |
|--------|-------------|-------------|
| `InMemoryMemory` | Não (RAM) | Desenvolvimento, agentes efêmeros |
| `AsyncSQLAlchemyMemory` | Sim (SQL) | Produção, histórico persistente |
| `RedisMemory` | Sim (Redis) | Alta performance, compartilhamento entre instâncias |

---

## 5. Tool & Toolkit

### Tool Function

Qualquer callable que retorna `ToolResponse`. Docstring com `Args:` é **obrigatória** para auto-schema.

```python
from agentscope.tool import ToolResponse

def consultar_lead(email: str, campos: list[str] = None) -> ToolResponse:
    """Consulta informações de um lead no Salesforce.

    Args:
        email: Email do lead para busca.
        campos: Lista de campos a retornar (padrão: todos).
    """
    # implementação
    return ToolResponse(status="success", content="...")
```

### Toolkit

Registro e gerenciamento de ferramentas.

```python
from agentscope.tool import Toolkit

toolkit = Toolkit()

# Registrar função
toolkit.register_tool_function(consultar_lead)

# Registrar com kwargs ocultos (não expostos ao agente)
toolkit.register_tool_function(fn, preset_kwargs={"api_key": "xxx"})

# Tool Groups (organização)
toolkit.create_tool_group(
    group_name="salesforce",
    description="Ferramentas de consulta Salesforce",
    active=False,
    notes="Ativar apenas quando necessário"
)
toolkit.register_tool_function(consultar_lead, group_name="salesforce")
toolkit.update_tool_groups(group_names=["salesforce"], active=True)

# Schema extension (Pydantic)
from pydantic import BaseModel, Field
class ThinkingModel(BaseModel):
    thinking: str = Field(description="Raciocínio antes da ação")
toolkit.set_extended_model("consultar_lead", ThinkingModel)
```

### Built-in Tools

```python
from agentscope.tool import execute_python_code, execute_shell_command, view_text_file
```

---

## 6. Agent

### AgentBase (classe abstrata)

3 métodos async obrigatórios:

| Método | Quando é chamado | O que faz |
|--------|-----------------|-----------|
| `reply(msg)` | Agente recebe mensagem e deve responder | Raciocina + age + retorna Msg |
| `observe(msg)` | Agente recebe informação sem precisar responder | Adiciona à memória |
| `handle_interrupt()` | Execução é interrompida externamente | Retorna Msg de resposta à interrupção |

### ReActAgent (pronto para uso)

Implementação completa do paradigma ReAct (Reasoning + Acting).

```python
agent = ReActAgent(
    name="Friday",
    sys_prompt="Você é um assistente útil.",
    model=model,
    formatter=formatter,
    toolkit=toolkit,          # opcional
    memory=InMemoryMemory(),  # opcional
    max_iters=10,             # opcional: limite de iterações
    parallel_tool_calls=True, # opcional: chamar tools em paralelo
)
```

**Loop interno do ReActAgent:**

```
1. _reasoning() → Modelo raciocina sobre a tarefa
2. _acting()    → Executa tool calls baseado no raciocínio
3. Observe      → Processa resultados das tools
4. Repete 1-3   → Até conclusão ou max_iters
5. reply()      → Retorna Msg final
```

---

## 7. Pipeline & MsgHub (Multi-Agent)

### Sequential Pipeline

```python
from agentscope.pipeline import sequential_pipeline

result = await sequential_pipeline([agent1, agent2, agent3])
```

### MsgHub (Orquestração Flexível)

```python
from agentscope.pipeline import MsgHub

async with MsgHub(
    participants=[agent1, agent2, agent3],
    announcement=Msg("Host", "Início da reunião.", "assistant")
) as hub:
    # Pipeline sequencial dentro do hub
    await sequential_pipeline([agent1, agent2, agent3])

    # Gerenciar participantes dinamicamente
    hub.add(agent4)
    hub.delete(agent3)

    # Broadcast para todos
    await hub.broadcast(Msg("Host", "Encerramento.", "assistant"))
```

---

## 8. MCP Integration

```python
from agentscope.mcp import HttpStatelessClient, HttpStatefulClient, StdIOStatefulClient

# Stateless (sem sessão — recomendado para início)
client = HttpStatelessClient(
    name="external_mcp",
    transport="streamable_http",
    url="https://mcp.example.com/mcp",
)

# Buscar função específica
func = await client.get_callable_function(func_name="tool_name")
result = await func(param="value")

# Registrar TODAS as tools do MCP no toolkit
toolkit.register_mcp_client(client)
```

> ⚠️ Stateful clients: fechar em ordem LIFO (ver gotchas.md #6).
