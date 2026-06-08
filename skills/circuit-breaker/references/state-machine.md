# Circuit Breaker — State Machine Reference

## Diagrama de Transicoes

```
                    ┌─────────────────────────────────┐
                    │            CLOSED                │
                    │  (trafego normal, contando       │
                    │   falhas consecutivas)           │
                    └───────┬────────────▲────────────┘
                            │            │
              failureCount  │            │  sucesso em
              >= threshold  │            │  HALF-OPEN
                            │            │
                            ▼            │
                    ┌────────────────────┴────────────┐
                    │             OPEN                 │
                    │  (trafego bloqueado,             │
                    │   retorna fallback)              │
                    └───────┬─────────────────────────┘
                            │
              Date.now() -  │
              lastFailure   │
              >= resetTimeout
                            │
                            ▼
                    ┌─────────────────────────────────┐
                    │          HALF-OPEN               │
                    │  (1 requisicao de teste)         │
                    │                                  │
                    │  sucesso → CLOSED                │
                    │  falha   → OPEN                  │
                    └─────────────────────────────────┘
```

## Regras de Transicao

| De | Para | Condicao | Acao |
|----|------|----------|------|
| CLOSED | OPEN | `failureCount >= failureThreshold` | Bloquear trafego, registrar `lastFailureTime` |
| OPEN | HALF-OPEN | `Date.now() - lastFailureTime >= resetTimeout` | Permitir 1 requisicao de teste |
| HALF-OPEN | CLOSED | Requisicao de teste retorna sucesso | Resetar `failureCount = 0`, liberar trafego |
| HALF-OPEN | OPEN | Requisicao de teste falha | Atualizar `lastFailureTime`, manter bloqueio |
| CLOSED | CLOSED | Requisicao falha mas `failureCount < threshold` | Incrementar `failureCount` |
| CLOSED | CLOSED | Requisicao sucesso | Resetar `failureCount = 0` |

## Estrutura de Estado

```javascript
const circuitBreakerState = {
  state: 'CLOSED',           // 'CLOSED' | 'OPEN' | 'HALF-OPEN'
  failureCount: 0,           // contador de falhas consecutivas
  lastFailureTime: null,     // timestamp da ultima falha (ms)
  halfOpenRequests: 0        // requisicoes enviadas em HALF-OPEN
};
```

## Implementacao Completa — Classe JS

Versao encapsulada para uso em Code nodes do n8n. Puro JS, sem dependencias.

```javascript
class CircuitBreaker {
  constructor(staticData, serviceName, options = {}) {
    this.staticData = staticData;
    this.key = `cb_${serviceName}`;
    this.serviceName = serviceName;
    this.failureThreshold = options.failureThreshold || 5;
    this.resetTimeout = options.resetTimeout || 60000;
    this.maxHalfOpenRequests = options.maxHalfOpenRequests || 1;

    // Inicializar estado se nao existe
    if (!this.staticData[this.key]) {
      this.staticData[this.key] = {
        state: 'CLOSED',
        failureCount: 0,
        lastFailureTime: null,
        halfOpenRequests: 0
      };
    }
  }

  get _state() {
    return this.staticData[this.key];
  }

  /**
   * Verifica se a requisicao pode prosseguir.
   * Retorna: { allowed: boolean, state: string, meta: object }
   */
  canExecute() {
    const s = this._state;
    const now = Date.now();

    // OPEN: verificar se pode transicionar para HALF-OPEN
    if (s.state === 'OPEN') {
      const elapsed = now - s.lastFailureTime;
      if (elapsed >= this.resetTimeout) {
        s.state = 'HALF-OPEN';
        s.halfOpenRequests = 0;
      } else {
        return {
          allowed: false,
          state: 'OPEN',
          meta: {
            retryAfterMs: this.resetTimeout - elapsed,
            service: this.serviceName
          }
        };
      }
    }

    // HALF-OPEN: verificar limite de requisicoes de teste
    if (s.state === 'HALF-OPEN') {
      if (s.halfOpenRequests >= this.maxHalfOpenRequests) {
        return {
          allowed: false,
          state: 'HALF-OPEN_FULL',
          meta: { service: this.serviceName }
        };
      }
      s.halfOpenRequests++;
    }

    return {
      allowed: true,
      state: s.state,
      meta: { service: this.serviceName }
    };
  }

  /**
   * Registrar sucesso. Reseta o circuito para CLOSED.
   */
  recordSuccess() {
    const s = this._state;
    s.state = 'CLOSED';
    s.failureCount = 0;
    s.halfOpenRequests = 0;
    return { state: 'CLOSED', event: 'SUCCESS' };
  }

  /**
   * Registrar falha. Pode abrir o circuito.
   * Retorna: { state: string, event: string, alert: boolean }
   */
  recordFailure() {
    const s = this._state;
    s.failureCount++;
    s.lastFailureTime = Date.now();

    if (s.failureCount >= this.failureThreshold || s.state === 'HALF-OPEN') {
      const previousState = s.state;
      s.state = 'OPEN';
      return {
        state: 'OPEN',
        event: previousState === 'HALF-OPEN' ? 'HALF-OPEN_FAILED' : 'CIRCUIT_OPENED',
        failureCount: s.failureCount,
        alert: true
      };
    }

    return {
      state: 'CLOSED',
      event: 'FAILURE_RECORDED',
      failureCount: s.failureCount,
      alert: false
    };
  }

  /**
   * Retorna snapshot do estado atual (read-only).
   */
  getStatus() {
    const s = this._state;
    return {
      service: this.serviceName,
      state: s.state,
      failureCount: s.failureCount,
      lastFailureTime: s.lastFailureTime
        ? new Date(s.lastFailureTime).toISOString()
        : null,
      config: {
        failureThreshold: this.failureThreshold,
        resetTimeout: this.resetTimeout,
        maxHalfOpenRequests: this.maxHalfOpenRequests
      }
    };
  }

  /**
   * Reset manual — forca circuito para CLOSED.
   * Usar apenas em emergencia ou durante debug.
   */
  forceReset() {
    const s = this._state;
    s.state = 'CLOSED';
    s.failureCount = 0;
    s.lastFailureTime = null;
    s.halfOpenRequests = 0;
    return { state: 'CLOSED', event: 'FORCE_RESET' };
  }
}
```

## Uso no n8n Code Node

```javascript
// Gate node (antes do HTTP Request)
const staticData = $getWorkflowStaticData('global');
const cb = new CircuitBreaker(staticData, 'api-pagamento', {
  failureThreshold: 5,
  resetTimeout: 60000
});

const check = cb.canExecute();

if (!check.allowed) {
  return [{ json: { blocked: true, ...check } }];
}

return [{ json: { ...items[0].json, _cbState: check.state } }];
```

```javascript
// Result Handler node (depois do HTTP Request)
const staticData = $getWorkflowStaticData('global');
const cb = new CircuitBreaker(staticData, 'api-pagamento');

const isError = items[0].json._error || (items[0].json.statusCode || 200) >= 500;

const result = isError ? cb.recordFailure() : cb.recordSuccess();

return [{ json: { ...items[0].json, circuitBreaker: result } }];
```

## Notas sobre a Implementacao

1. **Sem timers reais** — a maquina de estados e avaliada a cada execucao, nao em tempo real
2. **Sem locks** — em execucoes paralelas, pode haver leve imprecisao no contador de falhas
3. **Classe inline** — como o Code node do n8n nao suporta `require()`, a classe deve ser colada inteira no node ou dividida entre Gate e Result Handler
4. **`forceReset()`** — utilitario para debug; pode ser chamado por um workflow separado de admin/monitoring
