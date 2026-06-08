# api-to-mcp — Gotchas & Problemas Conhecidos

## 1. Spec Swagger 2.0 não é suportada diretamente
**Problema:** `openapi-mcp-generator` requer OpenAPI 3.x. Swagger 2.0 specs falham silenciosamente.
**Solução:** Converter antes com `npx swagger2openapi spec-v2.yaml -o spec-v3.json`.

## 2. APIs com muitos endpoints (50+) geram tools demais
**Problema:** LLMs perdem performance com >30 tools. APIs grandes geram dezenas de tools inúteis.
**Solução:** Filtrar endpoints com `x-mcp: { enabled: false }` na spec ou RouteMap no FastMCP. Focar nos endpoints que realmente serão usados.

## 3. OAuth2 requer setup manual de token refresh
**Problema:** `openapi-mcp-generator` não faz refresh automático de tokens OAuth2.
**Solução:** Usar um script wrapper que faz refresh antes de iniciar o server, ou usar FastMCP com `httpx` e `httpx-auth`.

## 4. Schemas complexos (oneOf, allOf, discriminator) podem falhar na conversão Zod
**Problema:** Specs com schemas polimórficos avançados podem gerar validators Zod incorretos.
**Solução:** Simplificar schemas na spec antes de converter, ou ajustar manualmente os Zod schemas gerados.

## 5. CORS/Network: MCP stdio não tem problemas, mas SSE sim
**Problema:** Transport SSE pode ter problemas de CORS em ambientes restritos.
**Solução:** Para uso local com Claude Code, sempre usar `stdio` (padrão). SSE só para acesso remoto.

## 6. Windows: paths com espaços no .mcp.json
**Problema:** Paths com espaços no campo `args` do `.mcp.json` podem quebrar no Windows.
**Solução:** Usar paths sem espaços ou escapar com aspas duplas: `"C:\\path to\\server.js"`.

## 7. Rate limiting não é automático
**Problema:** O MCP server gerado faz chamadas diretas à API sem throttling.
**Solução:** Adicionar rate limiting no client HTTP (axios interceptor ou httpx middleware) antes de produção.
