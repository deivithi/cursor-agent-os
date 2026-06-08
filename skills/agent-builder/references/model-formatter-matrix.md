# 📋 Model ↔ Formatter Matrix

> Pareamento OBRIGATÓRIO entre Model e Formatter.
> Usar o formatter errado causa erros de API (400 Bad Request, formato inválido).

---

## Matriz de Pareamento

| Provider | Model Class | ChatFormatter | MultiAgentFormatter |
|----------|-------------|---------------|---------------------|
| **OpenAI** | `OpenAIChatModel` | `OpenAIChatFormatter` | `OpenAIMultiAgentFormatter` |
| **Anthropic** | `AnthropicChatModel` | `AnthropicChatFormatter` | `AnthropicMultiAgentFormatter` |
| **DashScope** | `DashScopeChatModel` | `DashScopeChatFormatter` | `DashScopeMultiAgentFormatter` |
| **Gemini** | `GeminiChatModel` | `GeminiChatFormatter` | `GeminiMultiAgentFormatter` |
| **Ollama** | `OllamaChatModel` | `OllamaChatFormatter` | `OllamaMultiAgentFormatter` |
| **DeepSeek** | `OpenAIChatModel`* | `DeepSeekChatFormatter` | `DeepSeekMultiAgentFormatter` |
| **vLLM** | `OpenAIChatModel`* | `OpenAIChatFormatter` | `OpenAIMultiAgentFormatter` |

> *DeepSeek e vLLM usam `OpenAIChatModel` com `client_kwargs={"base_url": "..."}`.

---

## Quando Usar Multi-Agent Formatter

| Cenário | Formatter |
|---------|-----------|
| Agente solo | `{Provider}ChatFormatter` |
| MsgHub com múltiplos agentes | `{Provider}MultiAgentFormatter` |

---

## Exemplos de Construção

### OpenAI (GPT-4o)

```python
from agentscope.model import OpenAIChatModel
from agentscope.formatter import OpenAIChatFormatter

model = OpenAIChatModel(
    model_name="gpt-4o",
    api_key=os.environ["OPENAI_API_KEY"],
    stream=True,
    enable_thinking=False,
)
formatter = OpenAIChatFormatter()
```

### Anthropic (Claude)

```python
from agentscope.model import AnthropicChatModel
from agentscope.formatter import AnthropicChatFormatter

model = AnthropicChatModel(
    model_name="claude-sonnet-4-6",
    api_key=os.environ["ANTHROPIC_API_KEY"],
    stream=True,
    enable_thinking=False,
)
formatter = AnthropicChatFormatter()
```

### Ollama (Local)

```python
from agentscope.model import OllamaChatModel
from agentscope.formatter import OllamaChatFormatter

model = OllamaChatModel(
    model_name="llama3.1:70b",
    client_kwargs={"base_url": "http://localhost:11434"},
    stream=True,
)
formatter = OllamaChatFormatter()
```

### vLLM (OpenAI-compatible)

```python
from agentscope.model import OpenAIChatModel
from agentscope.formatter import OpenAIChatFormatter

model = OpenAIChatModel(
    model_name="meta-llama/Llama-3.1-70B-Instruct",
    api_key="dummy",
    client_kwargs={"base_url": "http://localhost:8000/v1"},
    stream=True,
)
formatter = OpenAIChatFormatter()
```
