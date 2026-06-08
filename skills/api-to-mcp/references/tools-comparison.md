# Ferramentas de Conversão OpenAPI → MCP

## Comparação Detalhada

| Ferramenta | Linguagem | Stars | Auth | Transport | Filtros | Ideal Para |
|-----------|-----------|-------|------|-----------|---------|------------|
| **openapi-mcp-generator** | TypeScript | 800+ | Bearer, API Key, Basic, OAuth2 | stdio, SSE, StreamableHTTP | x-mcp extension | Produção, Node.js |
| **FastMCP.from_openapi()** | Python | 12K+ (FastMCP) | Via httpx client | stdio, SSE | RouteMap regex | Protótipo, Python |
| **fastapi_mcp** | Python | 12K+ | FastAPI Depends() | ASGI | Por rota | Apps FastAPI existentes |
| **openapi-to-mcpserver** | Go | 500+ | Manual | HTTP | --validate flag | Higress gateway |
| **SwaggerToMCP** | TypeScript | 200+ | Básico | stdio | Manual | Conversão simples |
| **ConvertMCP.com** | Web | — | — | Multi-lang | — | Protótipo rápido online |

## Decisão para nosso ecossistema

**Engine A (PRINCIPAL):** `openapi-mcp-generator`
- ✅ npm global (nosso padrão para MCP servers)
- ✅ TypeScript/Node.js nativo
- ✅ Gera projeto completo (não precisa manter código)
- ✅ Auth via .env (padrão 12-factor)
- ✅ 3 transports

**Engine B (ALTERNATIVA):** `FastMCP.from_openapi()`
- ✅ Python (quando já temos venv)
- ✅ RouteMap granular
- ✅ Renomear tools facilmente
- ⚠️ Requer FastMCP instalado (pip)

## Fontes

- openapi-mcp-generator: https://github.com/harsha-iiiv/openapi-mcp-generator
- FastMCP: https://gofastmcp.com/integrations/openapi
- fastapi_mcp: https://github.com/tadata-org/fastapi_mcp
- openapi-to-mcpserver: https://github.com/higress-group/openapi-to-mcpserver
- SwaggerToMCP: https://github.com/grparry/SwaggerToMCP
- ConvertMCP.com: https://convertmcp.com/
