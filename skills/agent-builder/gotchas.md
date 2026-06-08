# ⚠️ Gotchas — Agent Builder (AgentScope)

> Problemas conhecidos encontrados durante o uso desta skill e do framework AgentScope.
> Construído iterativamente a partir de falhas reais.
> Consulte este arquivo quando algo falhar ou produzir resultado inesperado.

---

## 1. Tudo é Async — Esquecer await Causa Falha Silenciosa

- **Sintoma:** Resultado é `<coroutine object ...>` em vez de `Msg`
- **Causa raiz:** AgentScope é 100% async. Chamar `agent(msg)` sem `await` retorna coroutine
- **Solução:** Sempre usar `await agent(msg)` e encapsular em `asyncio.run(main())`
- **Prevenção:** Usar `async def main()` como padrão obrigatório em todo script
- **Descoberto em:** 2026-03-22

---

## 2. Formatter Incompatível com Model Gera Erro de API

- **Sintoma:** `400 Bad Request`, `Invalid message format`, ou resposta vazia
- **Causa raiz:** Cada provider tem formato de mensagem diferente. Formatter converte Msg para o formato correto
- **Solução:** Consultar `references/model-formatter-matrix.md` e usar o par correto (ex: `AnthropicChatModel` → `AnthropicChatFormatter`)
- **Prevenção:** Sempre declarar model e formatter juntos, nunca separados
- **Descoberto em:** 2026-03-22

---

## 3. Skills Registradas Mas Agente Não Consegue Ler

- **Sintoma:** Agente menciona a skill no raciocínio mas nunca executa o SKILL.md
- **Causa raiz:** `register_agent_skill()` apenas adiciona o prompt informando a existência da skill. O agente precisa de tools de leitura de arquivo para acessar o conteúdo
- **Solução:** Registrar `view_text_file` e/ou `execute_shell_command` no toolkit ANTES de registrar skills
- **Prevenção:** Checklist: "Toolkit tem tool de leitura?" antes de qualquer `register_agent_skill()`
- **Descoberto em:** 2026-03-22

---

## 4. SKILL.md Sem Frontmatter Raise ValueError

- **Sintoma:** `ValueError: name and description are required in SKILL.md`
- **Causa raiz:** `register_agent_skill()` usa `python-frontmatter` para parsear YAML frontmatter. Campos `name` e `description` são obrigatórios
- **Solução:** Adicionar frontmatter YAML com `name` e `description` no topo do SKILL.md
- **Prevenção:** Usar template padrão que já inclui frontmatter
- **Descoberto em:** 2026-03-22

---

## 5. enable_thinking=True Conflita com Tool Calls

- **Sintoma:** Agente entra em loop de "pensamento" sem nunca chamar tools, ou gera thinking blocks misturados com tool_use blocks
- **Causa raiz:** Thinking mode e tool-use mode competem pelo mesmo espaço de resposta em alguns providers
- **Solução:** Setar `enable_thinking=False` no construtor do model para agentes que usam ferramentas
- **Prevenção:** Padrão de construção: sempre `enable_thinking=False` para ReActAgent
- **Descoberto em:** 2026-03-22

---

## 6. MCP Stateful Clients — Fechar em Ordem Errada Causa Erro

- **Sintoma:** `ConnectionError`, `Session not found`, ou hang no close
- **Causa raiz:** MCP stateful clients mantêm sessão. Fechar fora de ordem LIFO (Last In, First Out) causa referências pendentes
- **Solução:** Fechar na ordem inversa de abertura: último aberto = primeiro fechado
- **Prevenção:** Usar context managers (`async with`) ou manter lista de clients e fechar com `reversed()`
- **Descoberto em:** 2026-03-22

---

## 7. python-frontmatter Não Instalado

- **Sintoma:** `ModuleNotFoundError: No module named 'frontmatter'` ao usar `register_agent_skill()`
- **Causa raiz:** `python-frontmatter` é dependência implícita, não listada nas deps core do agentscope
- **Solução:** `pip install python-frontmatter`
- **Prevenção:** Incluir no requirements.txt do projeto
- **Descoberto em:** 2026-03-22

---

## 8. Tool Function Sem Docstring Gera Schema Vazio

- **Sintoma:** Agente não sabe quais parâmetros a tool aceita, chama sem argumentos
- **Causa raiz:** AgentScope gera JSON schema automaticamente a partir da docstring (seção `Args:`) da função. Sem docstring = schema vazio
- **Solução:** Sempre incluir docstring com `Args:` descrevendo cada parâmetro
- **Prevenção:** Validar que toda tool function tem docstring com `Args:` antes de registrar
- **Descoberto em:** 2026-03-22

---

## 9. Nomes de Skills Duplicados no Mesmo Toolkit

- **Sintoma:** `ValueError: Skill name already registered`
- **Causa raiz:** Toolkit não permite dois skills com mesmo `name` no frontmatter
- **Solução:** Garantir que cada SKILL.md tem `name` único
- **Prevenção:** Convenção: `name` no YAML = nome da pasta (kebab-case)
- **Descoberto em:** 2026-03-22

---

<!--
INSTRUÇÕES PARA MANUTENÇÃO:
1. Adicione novos gotchas NO TOPO (newer first)
2. Use o formato: Sintoma, Causa raiz, Solução, Prevenção, Descoberto em
3. Se resolvido permanentemente, mova para ## Resolvidos no final
4. Gotchas devem ser específicos e acionáveis — não genéricos
5. Inclua o sintoma exato para facilitar busca futura
-->
