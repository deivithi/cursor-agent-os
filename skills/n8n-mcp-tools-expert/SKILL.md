---
name: n8n-mcp-tools-expert
description: >
  Guia de uso das 21 MCP tools do n8n-mcp: seleção de tool, parâmetros,
  padrões comuns e armadilhas.
domain: automation
subdomain: n8n-mcp
version: 1.0.0
author: deivithi
tags:
  - n8n
  - mcp
  - tools
  - api
---

# 🔧 n8n MCP Tools Expert

> **"21 tools, cada uma com parâmetros específicos. Usar a tool certa com os parâmetros certos é a diferença entre workflow criado em 1 minuto e 30 minutos de debugging."**

## 📁 File Structure
- `SKILL.md` — Você está aqui.

## 🔗 Related Skills
- `n8n-node-configuration` — O que os resultados de get_node significam
- `n8n-workflow-patterns` — Qual sequência de tools usar para cada padrão
- `n8n-validation-expert` — Interpretar resultados de validate_workflow

---

## 🎯 Seleção Rápida — "Qual Tool Usar?"

| Intenção | Tool | Exemplo |
|----------|------|---------|
| n8n está rodando? | `n8n_health_check` | — |
| Listar workflows | `n8n_list_workflows` | — |
| Ver workflow completo | `n8n_get_workflow` | `{id, mode: "full"}` |
| Criar workflow novo | `n8n_create_workflow` | `{name, nodes, connections}` |
| Editar workflow (parcial) | `n8n_update_partial_workflow` | `{id, intent, operations}` |
| Substituir workflow inteiro | `n8n_update_full_workflow` | `{id, nodes, connections}` |
| Validar workflow | `n8n_validate_workflow` | `{id, profile: "strict"}` |
| Testar workflow | `n8n_test_workflow` | `{id}` |
| Ver execuções | `n8n_executions` | `{workflow_id, limit}` |
| Ver detalhe de execução | `n8n_executions` | `{execution_id}` |
| Deletar workflow | `n8n_delete_workflow` | `{id}` |
| Buscar node por nome | `search_nodes` | `{query: "telegram"}` |
| Ver config de um node | `get_node` | `{nodeType, detail}` |
| Validar config de node | `validate_node` | `{nodeType, parameters}` |
| Buscar templates | `search_templates` | `{query: "email summarizer"}` |
| Ver template | `get_template` | `{template_id}` |
| Deploy template | `n8n_deploy_template` | `{template_id}` |
| Versões do workflow | `n8n_workflow_versions` | `{id}` |
| Docs de tool | `tools_documentation` | `{tool_name}` |
| Autofix workflow | `n8n_autofix_workflow` | `{id}` |

---

## 📋 Referência Detalhada

### Health & Status

#### `n8n_health_check`
- **Parâmetros:** nenhum
- **Retorna:** status, versão, uptime
- **Quando:** Sempre no início (Fase 0 do `/n8n`)

#### `n8n_list_workflows`
- **Parâmetros:** nenhum (opcionais: `active`, `tags`)
- **Retorna:** lista de workflows com ID, nome, status
- **Quando:** Encontrar workflow por nome, listar todos

---

### Workflow CRUD

#### `n8n_get_workflow`
- **Parâmetros:** `id` (obrigatório), `mode` (opcional: `"summary"` | `"full"`)
- **Retorna:** JSON do workflow
- **Quando:** Antes de editar — entender a estrutura atual

#### `n8n_create_workflow`
- **Parâmetros:** `name`, `nodes` (array), `connections` (object)
- **Retorna:** workflow criado com ID
- **⚠️ SEMPRE validar depois de criar**

#### `n8n_update_partial_workflow`
- **Parâmetros:**
  - `id` (obrigatório)
  - `intent` (obrigatório — descrição clara do que está fazendo)
  - `operations` (array de operações)
- **Operações disponíveis:**
  - `addNode` — adicionar node
  - `updateNode` — atualizar node existente
  - `removeNode` — remover node
  - `addConnection` — conectar nodes
  - `removeConnection` — desconectar nodes
  - `activateWorkflow` — ativar
  - `deactivateWorkflow` — desativar
  - `updateSettings` — alterar settings do workflow
- **⚠️ SEMPRE incluir `intent`** — documenta a mudança
- **⚠️ Auto-sanitização**: corrige automaticamente IF/Switch com operadores mal formatados

#### `n8n_update_full_workflow`
- **Parâmetros:** `id`, `nodes`, `connections`
- **Quando:** Reescrever workflow completo (cuidado — substitui TUDO)

#### `n8n_delete_workflow`
- **Parâmetros:** `id`
- **⚠️ IRREVERSÍVEL** — confirmar com o usuário antes

---

### Validação & Teste

#### `n8n_validate_workflow`
- **Parâmetros:** `id`, `profile` (opcional)
- **Profiles:**
  - `runtime` — desenvolvimento (default)
  - `strict` — produção (recomendado)
  - `ai-friendly` — workflows com nodes LLM
- **Retorna:** `valid: true/false`, erros, warnings, conexões
- **Quando:** Após TODA modificação

#### `n8n_test_workflow`
- **Parâmetros:** `id`, opcionalmente `triggerData`
- **Retorna:** resultado da execução
- **Quando:** Testar workflow antes de ativar

#### `n8n_autofix_workflow`
- **Parâmetros:** `id`
- **O que faz:** Tenta corrigir problemas comuns automaticamente
- **Quando:** Se validate_workflow retorna erros simples

---

### Node Discovery

#### `search_nodes`
- **Parâmetros:** `query` (string de busca)
- **Retorna:** lista de nodes com `nodeType` e `workflowNodeType`
- **⚠️ DOIS formatos:**
  - `nodeType` → para `get_node`, `validate_node`
  - `workflowNodeType` → para `n8n_create_workflow`, `n8n_update_partial_workflow`

#### `get_node`
- **Parâmetros:** `nodeType`, `detail` (`"summary"` | `"standard"` | `"full"`)
- **Retorna:** operações disponíveis, campos, opções
- **Quando:** Antes de configurar um node — descobrir campos obrigatórios

#### `validate_node`
- **Parâmetros:** `nodeType`, `parameters`
- **Retorna:** se a configuração é válida
- **Quando:** Validar config de um node antes de incluir no workflow

---

### Execuções

#### `n8n_executions`
- **Para listar:** `{workflow_id, limit: 5}`
- **Para detalhe:** `{execution_id}`
- **Retorna:** status, dados de cada node, erros
- **Quando:** Debug — ver o que aconteceu em uma execução

---

### Templates

#### `search_templates`
- **Parâmetros:** `query`
- **Retorna:** templates da comunidade n8n
- **Quando:** Buscar inspiração ou base para novo workflow

#### `get_template` / `n8n_deploy_template`
- **Parâmetros:** `template_id`
- **Quando:** Instanciar template como workflow real

---

## 🎯 Fluxos Comuns

### Criar Workflow do Zero

```
1. search_nodes({query: "telegram"})     → nodeType + workflowNodeType
2. get_node({nodeType, detail: "standard"})  → campos obrigatórios
3. n8n_create_workflow({name, nodes, connections})
4. n8n_validate_workflow({id, profile: "runtime"})
5. [corrigir erros se houver]
6. n8n_validate_workflow({id, profile: "strict"})
7. n8n_update_partial_workflow({id, operations: [{type: "activateWorkflow"}]})
```

### Editar Workflow Existente

```
1. n8n_get_workflow({id, mode: "full"})    → entender estrutura
2. n8n_update_partial_workflow({id, intent: "...", operations: [...]})
3. n8n_validate_workflow({id, profile: "strict"})
4. [corrigir se necessário]
```

### Debug de Workflow

```
1. n8n_executions({workflow_id, limit: 5})   → encontrar execução com erro
2. n8n_executions({execution_id})             → ver detalhe do erro
3. Identificar node + erro
4. n8n_get_workflow({id, mode: "full"})       → ver config do node
5. n8n_update_partial_workflow({...})          → corrigir
6. n8n_validate_workflow({id})                 → validar
7. n8n_test_workflow({id})                     → testar
```

---

## ⚠️ Gotchas

### 1. nodeType vs workflowNodeType
```
search_nodes retorna AMBOS:
- nodeType: "nodes-base.telegram"           → para get_node, validate_node
- workflowNodeType: "n8n-nodes-base.telegram"  → para create/update workflow
```
**Usar o formato ERRADO causa erro silencioso — o node é criado mas não funciona.**

### 2. intent é obrigatório em update_partial
Sem `intent`, a operação funciona mas não documenta a mudança. **SEMPRE incluir.**

### 3. Auto-sanitização pode mascarar erros
`n8n_update_partial_workflow` auto-corrige operadores de IF/Switch. Isso é bom, mas significa que você pode não perceber que a config original estava errada.

### 4. Validação com profile errado
`runtime` é mais permissivo que `strict`. **Sempre usar `strict` antes de ativar para produção.**

### 5. n8n_test_workflow precisa de dados de trigger
Se o workflow tem Webhook ou Email trigger, o test precisa de `triggerData` simulado. Sem isso, pode falhar ou retornar vazio.

---

## Regras Invioláveis

1. **SEMPRE usar n8n_health_check primeiro** — se n8n não está rodando, nada funciona
2. **SEMPRE usar o formato correto de nodeType** — search retorna dois formatos, usar o certo para cada contexto
3. **SEMPRE validar após modificação** — n8n_validate_workflow com profile adequado
4. **SEMPRE incluir intent** em n8n_update_partial_workflow
5. **NUNCA deletar sem confirmar** — n8n_delete_workflow é irreversível
6. **NUNCA ativar sem validar** — validação limpa é pré-requisito para ativação
