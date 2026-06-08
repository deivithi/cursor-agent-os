# 🍳 Recipes — Templates Prontos de Agentes

> Copie e adapte. Cada recipe é um agente funcional completo.
> Substitua `API_KEY`, tools e prompts conforme necessidade.

---

## Recipe 1: Agente Pesquisador (Solo + Tools)

Agente que busca informações usando ferramentas e sintetiza respostas.

```python
import asyncio, os
from agentscope.agent import ReActAgent
from agentscope.model import AnthropicChatModel
from agentscope.formatter import AnthropicChatFormatter
from agentscope.memory import InMemoryMemory
from agentscope.tool import Toolkit, ToolResponse, view_text_file

def web_search(query: str) -> ToolResponse:
    """Busca informações na web.

    Args:
        query: Termo de busca.
    """
    # Integrar com Tavily, Serper, etc.
    return ToolResponse(status="success", content=f"Resultados para: {query}")

toolkit = Toolkit()
toolkit.register_tool_function(web_search)

agent = ReActAgent(
    name="Pesquisador",
    sys_prompt="Você é um pesquisador. Busque informações e sintetize respostas precisas.",
    model=AnthropicChatModel(
        model_name="claude-sonnet-4-6",
        api_key=os.environ["ANTHROPIC_API_KEY"],
        stream=True,
        enable_thinking=False,
    ),
    formatter=AnthropicChatFormatter(),
    toolkit=toolkit,
    memory=InMemoryMemory(),
    max_iters=5,
)

async def main():
    response = await agent(Msg("user", "Quais as tendências de IA em 2026?", "user"))
    print(response.get_text_content())

asyncio.run(main())
```

---

## Recipe 2: Pipeline Multi-Agente (Pesquisador → Analista → Redator)

```python
import asyncio
from agentscope.agent import ReActAgent
from agentscope.model import OpenAIChatModel
from agentscope.formatter import OpenAIChatFormatter
from agentscope.memory import InMemoryMemory
from agentscope.pipeline import MsgHub, sequential_pipeline
from agentscope.message import Msg

model = OpenAIChatModel(
    model_name="gpt-4o",
    api_key="...",
    stream=True,
    enable_thinking=False,
)
formatter = OpenAIChatFormatter()

researcher = ReActAgent(
    name="Pesquisador",
    sys_prompt="Pesquise dados e fatos relevantes sobre o tema.",
    model=model, formatter=formatter, memory=InMemoryMemory(),
)

analyst = ReActAgent(
    name="Analista",
    sys_prompt="Analise os dados do pesquisador. Identifique padrões e insights.",
    model=model, formatter=formatter, memory=InMemoryMemory(),
)

writer = ReActAgent(
    name="Redator",
    sys_prompt="Escreva um relatório executivo baseado na análise. Formato: resumo, insights, recomendações.",
    model=model, formatter=formatter, memory=InMemoryMemory(),
)

async def main():
    async with MsgHub(
        participants=[researcher, analyst, writer],
        announcement=Msg("Host", "Tema: impacto da IA generativa no varejo brasileiro", "assistant")
    ) as hub:
        result = await sequential_pipeline([researcher, analyst, writer])
        print(result.get_text_content())

asyncio.run(main())
```

---

## Recipe 3: Agente com MCP (Conectando a Ferramentas Externas)

```python
import asyncio
from agentscope.agent import ReActAgent
from agentscope.model import AnthropicChatModel
from agentscope.formatter import AnthropicChatFormatter
from agentscope.memory import InMemoryMemory
from agentscope.tool import Toolkit
from agentscope.mcp import HttpStatelessClient
from agentscope.message import Msg

# Conectar ao MCP server do n8n
mcp_client = HttpStatelessClient(
    name="n8n",
    transport="streamable_http",
    url="http://localhost:5678/mcp",
)

toolkit = Toolkit()
toolkit.register_mcp_client(mcp_client)

agent = ReActAgent(
    name="Automator",
    sys_prompt="Você gerencia workflows de automação via n8n.",
    model=AnthropicChatModel(
        model_name="claude-sonnet-4-6",
        api_key="...",
        stream=True,
        enable_thinking=False,
    ),
    formatter=AnthropicChatFormatter(),
    toolkit=toolkit,
    memory=InMemoryMemory(),
)

async def main():
    response = await agent(Msg("user", "Liste os workflows ativos", "user"))
    print(response.get_text_content())

asyncio.run(main())
```

---

## Recipe 4: Agente com Skills (Conhecimento Especializado)

```python
import asyncio
from agentscope.agent import ReActAgent
from agentscope.model import OpenAIChatModel
from agentscope.formatter import OpenAIChatFormatter
from agentscope.memory import InMemoryMemory
from agentscope.tool import Toolkit, view_text_file, execute_shell_command
from agentscope.message import Msg

toolkit = Toolkit()

# OBRIGATÓRIO: tools de leitura para acessar SKILL.md
toolkit.register_tool_function(view_text_file)
toolkit.register_tool_function(execute_shell_command)

# Registrar skills
toolkit.register_agent_skill("./skills/lead-audit")
toolkit.register_agent_skill("./skills/commission-audit")

agent = ReActAgent(
    name="Auditor",
    sys_prompt="Você é um auditor especializado em leads e comissões Febracis.",
    model=OpenAIChatModel(
        model_name="gpt-4o",
        api_key="...",
        stream=True,
        enable_thinking=False,
    ),
    formatter=OpenAIChatFormatter(),
    toolkit=toolkit,
    memory=InMemoryMemory(),
)

async def main():
    response = await agent(Msg("user", "Audite os leads do evento CIS de março", "user"))
    print(response.get_text_content())

asyncio.run(main())
```

---

## Recipe 5: Agente Customizado (Herança de AgentBase)

```python
import asyncio
from agentscope.agent import AgentBase
from agentscope.model import AnthropicChatModel
from agentscope.formatter import AnthropicChatFormatter
from agentscope.memory import InMemoryMemory
from agentscope.message import Msg

class LeadScoringAgent(AgentBase):
    """Agente que pontua leads baseado em regras de negócio."""

    def __init__(self, scoring_rules: dict) -> None:
        super().__init__()
        self.name = "LeadScorer"
        self.scoring_rules = scoring_rules
        self.sys_prompt = (
            f"Você pontua leads de 0-100 usando estas regras:\n"
            f"{self._format_rules()}\n"
            f"Retorne JSON: {{score: int, reasoning: str}}"
        )
        self.model = AnthropicChatModel(
            model_name="claude-haiku-4-5-20251001",
            api_key="...",
            stream=False,
            enable_thinking=False,
        )
        self.formatter = AnthropicChatFormatter()
        self.memory = InMemoryMemory()

    def _format_rules(self) -> str:
        return "\n".join(f"- {k}: +{v} pontos" for k, v in self.scoring_rules.items())

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
        return Msg(self.name, "Scoring interrompido.", "assistant")


# Uso
rules = {
    "Email corporativo": 20,
    "Cargo decisor (C-Level/VP)": 30,
    "Empresa 100+ funcionários": 15,
    "Interação com conteúdo": 10,
    "Evento presencial": 25,
}

scorer = LeadScoringAgent(scoring_rules=rules)

async def main():
    lead_data = "Lead: João Silva, CEO, joao@empresa.com, 500 funcionários, participou do CIS"
    result = await scorer(Msg("user", lead_data, "user"))
    print(result.get_text_content())

asyncio.run(main())
```
