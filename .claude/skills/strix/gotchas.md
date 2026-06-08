# Strix — Gotchas e Problemas Conhecidos

## 1. Conflito de litellm com instalação global

**Problema:** `pip install strix-agent` no Python global falha porque Strix exige `litellm<1.82.0` e o ecossistema usa 1.82.6+.

**Solução:** Sempre usar venv dedicado `~/.strix-env/`. O wrapper script (`config/strix/strix-wrapper.sh`) já ativa automaticamente.

**Não é falso positivo.** Instalar no global quebra outras ferramentas.

---

## 2. LLM_API_KEY vazia = scan silencioso

**Problema:** Se `LLM_API_KEY` está vazia no `.strix.env`, o scan inicia mas falha sem mensagem clara.

**Solução:** Verificar antes de rodar:
```bash
grep -q "LLM_API_KEY=." config/strix/.strix.env || echo "WARN: LLM_API_KEY vazia!"
```

---

## 3. Windows paths com espaços

**Problema:** O workspace está em `Documents/VS CODE` (com espaço). Strix pode falhar com paths não-quoted.

**Solução:** Sempre usar aspas duplas nos paths:
```bash
strix -t "/c/Users/PC/OneDrive/Documents/VS CODE/Aria" -m quick -n
```

---

## 4. localhost em Docker containers

**Problema:** Se migrar para Docker no futuro, `localhost:5678` (n8n) não é acessível de dentro do container.

**Solução:** Usar `host.docker.internal:5678` ou `network_mode: host`.

**Não se aplica agora** — setup atual é via venv nativo (sem Docker).

---

## 5. Strix v0.8.x é pré-1.0

**Problema:** Breaking changes possíveis entre releases. Flags e output format podem mudar.

**Solução:** Pin da versão: `pip install strix-agent==0.8.3`. Atualizar só após testar.

---

## 6. Scan deep em projetos grandes = muitos tokens

**Problema:** Deep scan no Aria inteiro (frontend + backend + agent) pode consumir 80K+ tokens.

**Solução:**
- Usar Haiku para scans de rotina (~$0.04/scan)
- Reservar Sonnet para deep scans mensais (~$0.43/scan)
- Multi-target (`-t ./Aria/frontend -t ./Aria/backend`) é mais eficiente que `-t ./Aria`

---

## 7. OpenRouter free tier — rate limits

**Problema:** Modelos `:free` no OpenRouter têm limite de 20 req/min e ~200 req/dia. Deep scans em projetos grandes podem bater o limite.

**Solução:**
- Quick/standard scans (~1-5 chamadas) não batem o limite
- Deep scans podem precisar de retry (wrapper já faz retry via Execute Command no n8n)
- Se bater rate limit, trocar temporariamente para outro modelo free (3 opções no .strix.env)
- Se precisar de mais: migrar para Anthropic API key (custo ~$2.43/mês)

**Não é bug do Strix** — é limitação do free tier do OpenRouter.

---

## 8. LLM_API_BASE obrigatório para OpenRouter

**Problema:** Sem `LLM_API_BASE=https://openrouter.ai/api/v1`, o Strix tenta chamar a API do modelo diretamente (ex: DeepSeek API) e falha com auth error.

**Solução:** Sempre incluir `LLM_API_BASE` no `.strix.env`. O wrapper script já carrega automaticamente.

---

## 9. Exit code 2 não é erro

**Problema:** Strix retorna exit code 2 quando encontra vulnerabilidades. Scripts que checam `$? -ne 0` como erro vão confundir findings com crashes.

**Solução:**
```bash
strix -t ./app -m quick -n
EXIT=$?
if [ $EXIT -eq 2 ]; then
  echo "Vulnerabilities found"
elif [ $EXIT -eq 1 ]; then
  echo "Scan error"
elif [ $EXIT -eq 0 ]; then
  echo "Clean"
fi
```
