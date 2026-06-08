---
paths: ["**/*.js", "**/*.ts", "**/*.tsx", "**/*.jsx", "**/package.json"]
---

# JavaScript/TypeScript Code Rules

- Para n8n Code nodes em JS: usar `$input`, `$json`, `$node` syntax (prefixo $)
- Preferir const/let sobre var
- Async/await sobre .then() chains
- Para pipelines n8n → LLM: comprimir dados antes de enviar (princípio CALM — densidade semântica)
- Encoding: usar TextEncoder/TextDecoder para manipulação de bytes
- Dependências: verificar se já existem no package.json antes de instalar
