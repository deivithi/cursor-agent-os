# Circuit Breaker — Gotchas

## 1. Sandbox do Code Node

O n8n pode rodar Code nodes em modo sandbox (configuravel no `n8n` settings). No modo sandbox:

- **Sem acesso ao filesystem** — `fs`, `path`, `os` nao estao disponiveis
- **Sem `require()`** — nao da para importar modulos Node.js
- **Sem variáveis de ambiente** — `process.env` nao existe

**Impacto:** Persistencia baseada em arquivo (JSON no disco) **nao funciona** no sandbox. Use sempre `$getWorkflowStaticData('global')` que funciona em ambos os modos.

**Como verificar:** No n8n, va em Settings > Community nodes > Node process. Se estiver `own` = sandbox ativo.

---

## 2. Persistencia com staticData

`$getWorkflowStaticData('global')` persiste entre execucoes, mas tem limitacoes:

- **Resetado ao reimportar/duplicar workflow** — o staticData vive no banco do n8n, associado ao workflow ID. Exportar/importar cria novo ID
- **Nao compartilha entre workflows** — cada workflow tem seu proprio staticData. Para compartilhar estado de circuit breaker entre workflows, use Data Tables do n8n ou um store externo (Redis, banco)
- **Sem tamanho maximo documentado** — mas evite armazenar payloads grandes. Guarde apenas o estado minimo (state, failureCount, lastFailureTime, cache pequeno)
- **Race condition em execucoes paralelas** — se o workflow executa em paralelo (multiplos triggers simultaneos), dois nodes podem ler o mesmo staticData antes de um atualizar. O n8n nao garante atomicidade. Em volume muito alto, considere um lock externo ou aceite a imprecisao (o circuit breaker abre com +/- 1-2 falhas de diferenca)

---

## 3. Precisao de Timers

O n8n nao tem timers reais rodando entre execucoes. O `resetTimeout` funciona assim:

- No momento da execucao, o Code node calcula `Date.now() - lastFailureTime`
- Se nenhuma execucao acontecer durante o periodo de timeout, o circuito **fica OPEN indefinidamente** ate a proxima execucao
- O timeout so e avaliado quando o workflow roda novamente

**Consequencia pratica:** Se o workflow roda a cada 5 minutos e o `resetTimeout` e 60s, o circuito ficara OPEN por no minimo 5 minutos (ate a proxima execucao), nao 60 segundos.

**Mitigacao:** Para workflows com baixa frequencia, considere um Schedule Trigger separado que roda a cada 30-60s apenas para verificar e resetar circuit breakers. Ou ajuste o `resetTimeout` considerando o intervalo real de execucao.

---

## 4. Half-Open: Apenas 1 Requisicao de Teste

O estado HALF-OPEN existe para **testar com cautela** se o servico voltou. A regra e:

- `maxHalfOpenRequests = 1` — apenas UMA requisicao passa como teste
- Se essa requisicao falhar → volta para OPEN imediatamente
- Se essa requisicao ter sucesso → volta para CLOSED, trafego total liberado

**Erro comum:** Configurar `maxHalfOpenRequests` alto (ex: 10) pensando em "testar melhor". Isso derrota o proposito — se o servico ainda esta fora, voce manda 10 requisicoes para falhar em vez de 1.

**Em execucoes paralelas:** Se 3 execucoes chegam simultaneamente no HALF-OPEN, as 3 podem incrementar `halfOpenRequests` antes de qualquer uma completar. Use o valor 1 e aceite que em paralelo pode ir 2-3 ao inves de 1. O importante e nao mandar trafego total.

---

## 5. Deteccao de Erro no n8n

O HTTP Request node do n8n tem duas formas de sinalizar erro:

1. **Saida de erro** (quando "Continue on Error" esta ativo) — o item vai para a segunda saida com `$json._error`
2. **Workflow para** (quando "Continue on Error" esta desativado) — o circuit breaker Result Handler nunca executa

**Configuracao obrigatoria:** O HTTP Request node que esta protegido pelo circuit breaker **DEVE** ter "Continue on Error = ON". Caso contrario, erros param o workflow e o circuit breaker nunca registra a falha.

Tambem considere tratar status codes:
- `5xx` → falha do servico → contar no circuit breaker
- `4xx` → erro do cliente → **nao contar** (o servico esta funcionando, a requisicao e que esta errada)
- `429 Too Many Requests` → **contar** (rate limit e sinal de sobrecarga)

---

## 6. Multiplos Servicos no Mesmo Workflow

Se o workflow chama 3 APIs diferentes, voce precisa de 3 circuit breakers independentes:

```
[CB Gate: api-A] → [HTTP api-A] → [CB Result: api-A]
[CB Gate: api-B] → [HTTP api-B] → [CB Result: api-B]
[CB Gate: api-C] → [HTTP api-C] → [CB Result: api-C]
```

**Erro fatal:** Usar o mesmo `serviceName` para servicos diferentes. Se a API-A falha, o circuit breaker abre e bloqueia chamadas para API-B e API-C que estao funcionando perfeitamente.

---

## 7. Cache no Fallback

Ao usar a estrategia de fallback com cache (`staticData[key_cache]`):

- **Nao guarde payloads enormes** — o staticData fica no banco do n8n. Payloads de 10MB+ podem degradar performance
- **Defina TTL para o cache** — dados cacheados de 3 dias atras podem ser piores que nenhum dado
- **Rotule dados cacheados** — sempre inclua `_fromCache: true` e `_cachedAt` para que nodes posteriores saibam que o dado nao e fresco
