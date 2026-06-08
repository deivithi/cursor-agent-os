---
name: circuit-breaker
description: Implement circuit breaker pattern in n8n workflows. State machine (closed/open/half-open) using Code nodes with persistent state. Prevents cascading failures by stopping calls to failing services and providing graceful fallbacks. Use when integrating external APIs, preventing timeout storms, or adding resilience to production workflows.
---

# Circuit Breaker — n8n Skill

## O que e

Padrao de resiliencia que protege workflows contra falhas em cascata. Quando um servico externo comeca a falhar, o circuit breaker **interrompe as chamadas** antes que elas acumulem timeouts, protegendo o workflow inteiro.

Analogia: funciona como um disjuntor eletrico — quando detecta sobrecarga, desarma para proteger o circuito.

## Quando usar

- Integracoes com APIs externas (pagamento, CRM, email)
- Workflows que chamam servicos com SLA instavel
- Prevencao de timeout storms em execucoes de alto volume
- Qualquer chamada HTTP que pode falhar e travar o fluxo

## Quando NAO usar

- Operacoes internas do n8n (mover dados entre nodes)
- Transformacoes de dados (Code nodes puros)
- Workflows que ja tem retry nativo suficiente

---

## Maquina de Estados

```
    [CLOSED] ──falha >= threshold──> [OPEN]
       ^                                |
       |                          timeout expira
       |                                |
       |                                v
       └──sucesso──────────── [HALF-OPEN]
                                  |
                              falha──> [OPEN]
```

### Estados

| Estado | Comportamento | Transicao |
|--------|--------------|-----------|
| **CLOSED** | Requisicoes passam normalmente. Contador de falhas ativo | → OPEN quando falhas >= `failureThreshold` |
| **OPEN** | Requisicoes bloqueadas. Retorna fallback imediatamente | → HALF-OPEN quando `resetTimeout` expira |
| **HALF-OPEN** | Permite `maxHalfOpenRequests` requisicoes de teste | → CLOSED se sucesso / → OPEN se falha |

---

## Configuracao

```javascript
const CONFIG = {
  failureThreshold: 5,       // falhas consecutivas para abrir
  resetTimeout: 60000,        // ms para tentar half-open (60s)
  maxHalfOpenRequests: 1,     // requisicoes de teste em half-open
  serviceName: 'api-pagamento' // identificador unico do servico
};
```

---

## Implementacao — Code Node (n8n)

### Node 1: Circuit Breaker Gate

Coloque **antes** do node HTTP Request. Decide se a requisicao deve prosseguir ou ser bloqueada.

```javascript
// Circuit Breaker Gate — Code Node
const CONFIG = {
  failureThreshold: 5,
  resetTimeout: 60000,
  maxHalfOpenRequests: 1,
  serviceName: 'api-pagamento'
};

// Persistencia via staticData do workflow
const staticData = $getWorkflowStaticData('global');
const key = `cb_${CONFIG.serviceName}`;

if (!staticData[key]) {
  staticData[key] = {
    state: 'CLOSED',
    failureCount: 0,
    lastFailureTime: null,
    halfOpenRequests: 0
  };
}

const cb = staticData[key];
const now = Date.now();

// Logica de transicao
if (cb.state === 'OPEN') {
  const elapsed = now - cb.lastFailureTime;
  if (elapsed >= CONFIG.resetTimeout) {
    cb.state = 'HALF-OPEN';
    cb.halfOpenRequests = 0;
  } else {
    // Circuito aberto — bloquear
    return [{
      json: {
        circuitBreaker: true,
        action: 'BLOCKED',
        state: 'OPEN',
        service: CONFIG.serviceName,
        retryAfterMs: CONFIG.resetTimeout - elapsed,
        fallback: true
      }
    }];
  }
}

if (cb.state === 'HALF-OPEN') {
  if (cb.halfOpenRequests >= CONFIG.maxHalfOpenRequests) {
    return [{
      json: {
        circuitBreaker: true,
        action: 'BLOCKED',
        state: 'HALF-OPEN_FULL',
        service: CONFIG.serviceName,
        fallback: true
      }
    }];
  }
  cb.halfOpenRequests++;
}

// CLOSED ou HALF-OPEN com vaga — permitir
return [{
  json: {
    ...items[0].json,
    circuitBreaker: true,
    action: 'ALLOWED',
    state: cb.state,
    service: CONFIG.serviceName
  }
}];
```

### Node 2: Circuit Breaker Result Handler

Coloque **depois** do node HTTP Request (ambas as saidas: sucesso e erro).

```javascript
// Circuit Breaker Result Handler — Code Node
const CONFIG = {
  failureThreshold: 5,
  resetTimeout: 60000,
  serviceName: 'api-pagamento'
};

const staticData = $getWorkflowStaticData('global');
const key = `cb_${CONFIG.serviceName}`;
const cb = staticData[key];

// Detectar se houve erro (vem pela saida de erro do node anterior)
const isError = items[0].json._error || items[0].json.statusCode >= 500;

if (isError) {
  cb.failureCount++;
  cb.lastFailureTime = Date.now();

  if (cb.failureCount >= CONFIG.failureThreshold) {
    const previousState = cb.state;
    cb.state = 'OPEN';

    return [{
      json: {
        circuitBreaker: true,
        event: previousState === 'HALF-OPEN' ? 'HALF-OPEN_FAILED' : 'CIRCUIT_OPENED',
        failureCount: cb.failureCount,
        service: CONFIG.serviceName,
        alert: true  // flag para integrar com error-alerting
      }
    }];
  }

  return [{
    json: {
      ...items[0].json,
      circuitBreaker: true,
      event: 'FAILURE_RECORDED',
      failureCount: cb.failureCount,
      threshold: CONFIG.failureThreshold
    }
  }];
}

// Sucesso — resetar
cb.state = 'CLOSED';
cb.failureCount = 0;
cb.halfOpenRequests = 0;

return [{
  json: {
    ...items[0].json,
    circuitBreaker: true,
    event: 'SUCCESS',
    state: 'CLOSED'
  }
}];
```

---

## Persistencia de Estado

### Opcao 1: `$getWorkflowStaticData('global')` (recomendado)

- Persiste entre execucoes do mesmo workflow
- Resetado se o workflow for salvo/reimportado
- Zero dependencia externa
- **Limitacao:** nao compartilha entre workflows diferentes

### Opcao 2: n8n Data Table (multi-workflow)

Para compartilhar estado entre workflows, use uma Data Table do n8n:

```javascript
// Leitura: usar node "n8n Data Table" com operacao "Get"
// Escrita: usar node "n8n Data Table" com operacao "Upsert"
// Chave: serviceName | Campos: state, failureCount, lastFailureTime
```

---

## Estrategias de Fallback

Quando o circuito esta OPEN, use um IF node apos o Gate para rotear:

| Estrategia | Quando usar | Implementacao |
|------------|------------|---------------|
| **Resposta cacheada** | Dados que mudam pouco (ex: catalogo) | Guardar ultimo sucesso no staticData |
| **Valor padrao** | Campos opcionais (ex: score de lead) | Retornar valor default no Code node |
| **Skip** | Enriquecimento nao critico | Pular o node e seguir o fluxo |
| **Alerta + fila** | Operacoes criticas (ex: pagamento) | Enviar para fila de retry + alertar |

### Exemplo: Fallback com cache

```javascript
// No Result Handler, apos sucesso:
staticData[`${key}_cache`] = {
  data: items[0].json,
  cachedAt: Date.now()
};

// No Gate, quando bloqueado:
const cached = staticData[`${key}_cache`];
if (cached) {
  return [{ json: { ...cached.data, _fromCache: true } }];
}
```

---

## Integracao com Error-Alerting

Quando o circuito abre (`event: 'CIRCUIT_OPENED'`), integre com a skill de error-alerting:

1. Apos o Result Handler, adicione um IF node: `{{ $json.alert === true }}`
2. Na saida `true`, conecte ao canal de alertas (Slack, email, webhook)
3. Inclua no alerta: `serviceName`, `failureCount`, `timestamp`

```
[Result Handler] → [IF alert=true] → [Slack/Email] → "Circuit OPEN: api-pagamento (5 falhas)"
```

---

## Arquitetura no Workflow

```
[Trigger] → [CB Gate] → [IF action=ALLOWED]
                              |YES            |NO
                              v                v
                        [HTTP Request]    [Fallback]
                          |ok    |err         |
                          v       v           |
                      [CB Result Handler]     |
                          |                   |
                          v                   v
                      [IF alert?]        [Continue...]
                        |YES
                        v
                    [Alerting]
```

---

## Anti-patterns

| Anti-pattern | Problema | Solucao |
|-------------|----------|---------|
| CB em operacoes internas | Overhead desnecessario, nunca vai abrir | Usar apenas para chamadas externas |
| Threshold muito baixo (1-2) | Abre com falhas transitorias normais | Minimo recomendado: 3-5 |
| Sem monitoramento | Circuito abre e ninguem sabe | Sempre integrar com alerting |
| Reset timeout muito curto | Fica oscilando open/half-open | Minimo 30s, ideal 60-120s |
| Mesmo CB para servicos diferentes | Uma API derruba outra | Um circuit breaker por servico |
| Ignorar o estado HALF-OPEN | Envia trafico total apos timeout | Limitar a 1 requisicao de teste |
| Nao ter fallback | Workflow falha de qualquer jeito | Sempre definir estrategia de fallback |

---

## Quality Checklist

```
[ ] Circuit breaker usa staticData para persistencia entre execucoes?
[ ] Cada servico externo tem seu proprio circuit breaker (serviceName unico)?
[ ] failureThreshold >= 3?
[ ] resetTimeout >= 30000ms?
[ ] maxHalfOpenRequests = 1 (nao envia trafico total)?
[ ] Fallback definido para quando circuito esta OPEN?
[ ] Alerta configurado para evento CIRCUIT_OPENED?
[ ] IF node roteia corretamente entre ALLOWED e BLOCKED?
[ ] Result Handler trata ambas saidas (sucesso e erro) do HTTP node?
[ ] Testado manualmente: simular 5+ erros e verificar que circuito abre?
[ ] Testado: apos resetTimeout, circuito entra em HALF-OPEN?
[ ] Testado: sucesso em HALF-OPEN fecha o circuito?
```

---

*Estou seguindo as minhas instrucoes, chefe.*
