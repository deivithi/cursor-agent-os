---
name: api-to-mcp
description: >
  Convert any REST API (via OpenAPI/Swagger spec) into a working MCP server automatically.
  Reads spec → generates typed MCP tools → configures transport → registers in .mcp.json.
  Complementa api-forge (slash commands) com MCP servers reais.
domain: developer-tools
subdomain: mcp-integration
version: 1.0.0
author: deivithi
license: Apache-2.0
tags:
  - openapi
  - swagger
  - mcp
  - rest-api
  - code-generation
  - model-context-protocol
  - api-integration
  - automation
---

# API-to-MCP — Qualquer REST API → MCP Server Automático

> **"De OpenAPI spec para MCP tools em 60 segundos."**

## 📁 File Structure
- `SKILL.md` — Você está aqui. Workflow completo abaixo.
- `references/tools-comparison.md` — Comparação das ferramentas de conversão.
- `gotchas.md` — ⚠️ Problemas conhecidos.

## 🔗 Related Skills
- `api-forge` — Gera slash commands nativos (complementar: api-forge = commands, api-to-mcp = MCP tools)
- `n8n-mcp-tools-expert` — Quando o MCP gerado precisa integrar com workflows n8n
- `cyber` — Auditar segurança do MCP server gerado (OWASP API Top 10)

---

## 1. Overview

### O que esta skill faz

Converte qualquer REST API documentada com OpenAPI 3.x ou Swagger 2.0 em um **MCP server funcional** que Claude Code (e outros clientes MCP) podem usar como tools nativas.

### Quando usar

| Cenário | Use api-to-mcp | Use api-forge |
|---------|----------------|---------------|
| Quer tools MCP nativas no Claude Code | ✅ | ❌ |
| Quer slash commands customizados | ❌ | ✅ |
| API com muitos endpoints (20+) | ✅ (auto-gera tudo) | ⚠️ (manual) |
| Precisa auth encriptado com AES-256 | ❌ | ✅ |
| Quer usar a API em outros clientes MCP | ✅ | ❌ |
| API simples (2-5 endpoints) | ⚠️ (overkill) | ✅ |

---

## 2. Workflow

### Fase 1 — Obter a Spec

```
INPUT: URL ou arquivo da OpenAPI spec
├── URL direta: https://api.example.com/openapi.json
├── Swagger UI: extrair spec URL do /docs ou /swagger
├── Arquivo local: ./specs/api-spec.yaml
└── Manual: criar spec mínima a partir da documentação
```

**Detectar spec automaticamente:**
```bash
# Tentar endpoints comuns
curl -s https://api.example.com/openapi.json | head -5
curl -s https://api.example.com/api-docs | head -5
curl -s https://api.example.com/swagger.json | head -5
curl -s https://api.example.com/v3/api-docs | head -5
```

**Se não houver spec:** Criar spec mínima manualmente:
```yaml
openapi: "3.0.0"
info:
  title: "API Name"
  version: "1.0.0"
servers:
  - url: https://api.example.com
paths:
  /endpoint:
    get:
      operationId: getEndpoint
      summary: "Description"
      parameters:
        - name: param1
          in: query
          schema:
            type: string
      responses:
        "200":
          description: "Success"
```

### Fase 2 — Escolher Engine de Conversão

#### Engine A: `openapi-mcp-generator` (RECOMENDADO)

**Melhor para:** APIs externas, geração completa de servidor, TypeScript/Node.js.

```bash
# Instalar globalmente (uma vez)
npm install -g openapi-mcp-generator

# Gerar MCP server a partir da spec
openapi-mcp-generator --input spec.json --output ./mcp-servers/api-name

# Instalar dependências e iniciar
cd ./mcp-servers/api-name && npm install
```

**Output:** Projeto Node.js completo com:
- `index.ts` — Server MCP com todos os endpoints como tools
- `package.json` — Dependências tipadas
- `.env.example` — Variáveis de auth
- Schemas Zod gerados automaticamente

**Auth via .env:**
```env
# Bearer Token
BEARER_TOKEN_DEFAULT=your-token-here

# API Key
API_KEY_DEFAULT=your-key-here

# Basic Auth
BASIC_AUTH_USERNAME=user
BASIC_AUTH_PASSWORD=pass

# OAuth2
OAUTH2_CLIENT_ID=client-id
OAUTH2_CLIENT_SECRET=client-secret
OAUTH2_TOKEN_URL=https://auth.example.com/token
```

**Transports disponíveis:**
- `stdio` — Para uso local com Claude Code (PADRÃO)
- `sse` — Server-Sent Events para acesso remoto
- `streamable-http` — HTTP stateful

#### Engine B: `FastMCP.from_openapi()` (Python)

**Melhor para:** Quando já tem Python no projeto, prototipagem rápida.

```python
import httpx
from fastmcp import FastMCP

# Carregar spec
spec = httpx.get("https://api.example.com/openapi.json").json()

# Criar client com auth
client = httpx.AsyncClient(
    base_url="https://api.example.com",
    headers={"Authorization": "Bearer TOKEN"}
)

# Converter para MCP server
mcp = FastMCP.from_openapi(
    openapi_spec=spec,
    client=client,
    name="my-api-mcp"
)

# Rodar
mcp.run(transport="stdio")
```

**Filtrar endpoints (RouteMap):**
```python
from fastmcp.server.openapi import RouteMap, MCPType

mcp = FastMCP.from_openapi(
    openapi_spec=spec,
    client=client,
    route_maps=[
        # Excluir rotas admin
        RouteMap(pattern=r"^/admin/.*", mcp_type=MCPType.EXCLUDE),
        # GET endpoints como Resources
        RouteMap(methods=["GET"], mcp_type=MCPType.RESOURCE),
        # POST/PUT/DELETE como Tools
        RouteMap(methods=["POST", "PUT", "DELETE"], mcp_type=MCPType.TOOL),
    ],
)
```

### Fase 3 — Registrar no Claude Code

**Adicionar ao `.mcp.json`:**

```json
{
  "mcpServers": {
    "my-api": {
      "command": "node",
      "args": ["./mcp-servers/api-name/dist/index.js"],
      "env": {
        "BEARER_TOKEN_DEFAULT": "${MY_API_TOKEN}"
      }
    }
  }
}
```

**Para Engine B (Python):**
```json
{
  "mcpServers": {
    "my-api": {
      "command": "python",
      "args": ["./mcp-servers/api-name/server.py"],
      "env": {
        "API_TOKEN": "${MY_API_TOKEN}"
      }
    }
  }
}
```

### Fase 4 — Validar

```bash
# Verificar que o MCP server inicia sem erros
node ./mcp-servers/api-name/dist/index.js

# No Claude Code: verificar tools disponíveis
# As tools devem aparecer como mcp__my-api__operationId
```

**Checklist de validação:**
- [ ] Server inicia sem erros
- [ ] Tools aparecem no Claude Code (system-reminder)
- [ ] Auth funciona (chamada de teste)
- [ ] Schemas de input estão corretos
- [ ] Erros da API são propagados adequadamente

### Fase 5 — Otimizar (Opcional)

**Filtrar endpoints desnecessários:**
```bash
# openapi-mcp-generator suporta x-mcp extension na spec
# Adicionar ao OpenAPI spec:
# x-mcp:
#   enabled: false  # Desabilitar endpoint específico
```

**Renomear tools para clareza:**
```python
# FastMCP
mcp = FastMCP.from_openapi(
    openapi_spec=spec,
    client=client,
    mcp_names={
        "getUserById": "get_user",
        "listOrders": "list_orders",
    }
)
```

---

## 3. Decision Matrix

| Critério | Engine A (openapi-mcp-generator) | Engine B (FastMCP) |
|----------|----------------------------------|-------------------|
| **Linguagem** | TypeScript/Node.js | Python |
| **Instalação** | `npm install -g` | `pip install fastmcp` |
| **Output** | Projeto completo gerável | Script Python inline |
| **Auth** | .env com convenções | httpx client headers |
| **Filtrar endpoints** | `x-mcp` extension | RouteMap com regex |
| **Transport** | stdio, SSE, StreamableHTTP | stdio, SSE |
| **Ideal para** | Produção, APIs grandes | Prototipagem, Python |
| **Windows** | ✅ Nativo | ✅ (precisa venv) |

**Regra de decisão:**
- API grande (20+ endpoints) + produção → **Engine A**
- Protótipo rápido + já tem Python → **Engine B**
- Dúvida? → **Engine A** (mais portável, Node.js nativo)

---

## 4. Exemplos Práticos

### Exemplo 1: Salesforce REST API → MCP

```bash
# 1. Baixar spec
curl -o salesforce-spec.json \
  "https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/openapi.json"

# 2. Gerar server
openapi-mcp-generator --input salesforce-spec.json --output ./mcp-servers/salesforce

# 3. Configurar auth (.env)
echo "BEARER_TOKEN_DEFAULT=$SF_ACCESS_TOKEN" > ./mcp-servers/salesforce/.env

# 4. Registrar em .mcp.json
```

### Exemplo 2: API Interna com Swagger 2.0

```bash
# 1. Converter Swagger 2.0 → OpenAPI 3.0 se necessário
npx swagger2openapi ./legacy-spec.yaml -o ./spec-v3.json

# 2. Gerar normalmente
openapi-mcp-generator --input spec-v3.json --output ./mcp-servers/internal-api
```

### Exemplo 3: API sem spec (manual)

```bash
# 1. Criar spec mínima (ver template na Fase 1)
# 2. Gerar server normalmente
# 3. Testar e iterar
```

---

## 5. Anti-Patterns

| ❌ Anti-Pattern | ✅ Correto |
|----------------|-----------|
| Converter API com 200+ endpoints sem filtrar | Filtrar com `x-mcp` ou RouteMap — LLMs funcionam melhor com <30 tools |
| Hardcoded tokens no código | Sempre usar .env + variáveis de ambiente |
| Ignorar rate limits da API | Adicionar retry com backoff no client |
| Converter spec desatualizada | Sempre validar spec contra API real antes |
| Usar MCP para APIs simples (2-3 endpoints) | Para APIs simples, `api-forge` ou chamadas diretas são mais eficientes |

---

## 6. Referência Rápida

```
                    ┌──────────────┐
                    │  OpenAPI Spec │
                    │  (JSON/YAML)  │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │ api-to-mcp   │
                    │  Engine A/B  │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
       ┌──────▼──────┐ ┌──▼───┐ ┌─────▼─────┐
       │ MCP Server  │ │ .env │ │ .mcp.json │
       │ (TypeScript │ │(auth)│ │ (registro)│
       │  or Python) │ │      │ │           │
       └──────┬──────┘ └──────┘ └───────────┘
              │
       ┌──────▼──────┐
       │ Claude Code │
       │ mcp__api__* │
       └─────────────┘
```
