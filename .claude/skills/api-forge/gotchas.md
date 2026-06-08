# ⚠️ Gotchas — API Forge

> Problemas conhecidos encontrados durante o uso do API Forge. Construído iterativamente a partir de falhas reais.
> **Consulte este arquivo quando algo falhar ou produzir resultado inesperado.**

---

## 1. Encoding de tokens no Windows causa falha na descriptografia

- **Sintoma:** `forge-decrypt.sh` retorna erro `bad decrypt` ou token corrompido no Windows
- **Causa raiz:** O OpenSSL no Git Bash (Windows) pode interpretar caracteres especiais diferentemente do Linux. Tokens com `+`, `/` ou `=` no base64 podem ser truncados se não estiverem entre aspas
- **Solução:** Sempre usar aspas duplas ao passar tokens: `"$TOKEN"`. Verificar que o OpenSSL usado é o do Git Bash (`/usr/bin/openssl`), não o do Windows nativo
- **Prevenção:** No script `forge-encrypt.sh`, adicionar validação de encoding pós-encriptação
- **Descoberto em:** 2026-03-18

---

## 2. Rate limiting silencioso com APIs que retornam 200 em vez de 429

- **Sintoma:** Respostas da API voltam vazias ou com dados parciais, mas o status code é 200 (não 429)
- **Causa raiz:** Algumas APIs (ex: Salesforce Bulk API, certas APIs Google) fazem throttling silencioso — reduzem a quantidade de dados retornados em vez de rejeitar a request
- **Solução:** Além de checar headers `X-RateLimit-*`, validar que o response body contém dados completos. Comparar `Content-Length` esperado vs recebido
- **Prevenção:** Adicionar assertion de completude no script gerado, não apenas de status code
- **Descoberto em:** 2026-03-18

---

## 3. OpenAPI specs com $ref circular causam loop infinito no parser

- **Sintoma:** Claude entra em loop tentando resolver referências `$ref` que apontam umas para as outras em specs OpenAPI complexas
- **Causa raiz:** Specs com schemas recursivos (ex: `TreeNode` que contém `children: TreeNode[]`) geram referências circulares que o parser markdown não consegue resolver
- **Solução:** Ao encontrar `$ref` circular, truncar na segunda ocorrência e adicionar comentário `[referência circular — ver schema original]`
- **Prevenção:** Antes de processar a spec, rodar `jq` para detectar `$ref` circulares e mapear profundidade máxima
- **Descoberto em:** 2026-03-18

---

<!--
INSTRUÇÕES PARA MANUTENÇÃO:
1. Adicione novos gotchas NO TOPO (mais recentes primeiro, renumere)
2. Use o formato acima para consistência
3. Se um gotcha for resolvido permanentemente, mova para ## Resolvidos no final
4. Gotchas devem ser específicos e acionáveis — não genéricos
5. Inclua o sintoma exato para facilitar busca futura
-->
