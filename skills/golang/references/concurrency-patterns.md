# ⚡ Concurrency Patterns — Go

> 10 patterns canônicos. Cada um c/ código + quando usar + link oficial.

---

## 1. Pipeline

Stages conectados por channels. Cada stage lê de input, processa, escreve em output.
📖 https://go.dev/blog/pipelines

```go
func gen(ctx context.Context, nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for _, n := range nums {
            select {
            case out <- n:
            case <-ctx.Done(): return
            }
        }
    }()
    return out
}

func sq(ctx context.Context, in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for n := range in {
            select {
            case out <- n * n:
            case <-ctx.Done(): return
            }
        }
    }()
    return out
}
```

---

## 2. Fan-out / Fan-in

Fan-out: vários workers consomem de um channel. Fan-in: merge de múltiplos channels em um.
📖 https://go.dev/blog/pipelines#fan-out-fan-in

```go
func fanOut(ctx context.Context, in <-chan int, n int, work func(int) int) []<-chan int {
    out := make([]<-chan int, n)
    for i := 0; i < n; i++ {
        c := make(chan int)
        out[i] = c
        go func() {
            defer close(c)
            for v := range in {
                select {
                case c <- work(v):
                case <-ctx.Done(): return
                }
            }
        }()
    }
    return out
}

func fanIn(ctx context.Context, chans ...<-chan int) <-chan int {
    out := make(chan int)
    var wg sync.WaitGroup
    for _, c := range chans {
        wg.Add(1)
        go func(c <-chan int) {
            defer wg.Done()
            for v := range c {
                select {
                case out <- v:
                case <-ctx.Done(): return
                }
            }
        }(c)
    }
    go func() { wg.Wait(); close(out) }()
    return out
}
```

---

## 3. Worker Pool

N goroutines consumindo de jobs channel. Tamanho fixo = backpressure.
📖 https://pkg.go.dev/sync#WaitGroup

```go
func workerPool(ctx context.Context, jobs <-chan Job, workers int) <-chan Result {
    results := make(chan Result)
    var wg sync.WaitGroup
    for i := 0; i < workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for j := range jobs {
                select {
                case results <- process(j):
                case <-ctx.Done(): return
                }
            }
        }()
    }
    go func() { wg.Wait(); close(results) }()
    return results
}
```

---

## 4. Rate Limiter

Limitar taxa de operações. `time.Ticker` ou `golang.org/x/time/rate`.
📖 https://pkg.go.dev/golang.org/x/time/rate

```go
import "golang.org/x/time/rate"

limiter := rate.NewLimiter(rate.Every(100*time.Millisecond), 10) // 10/s, burst 10
for _, r := range requests {
    if err := limiter.Wait(ctx); err != nil { return err }
    go handle(r)
}
```

---

## 5. Context Cancellation

Propagação de cancel + timeout em toda a chain.
📖 https://go.dev/blog/context

```go
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()

result, err := longRunning(ctx)
```

**Regra:** 1º param sempre; nunca armazenar em struct; `context.Value` só p/ request-scoped data opaca.

---

## 6. errgroup

Goroutines c/ erro propagado + cancellation automática.
📖 https://pkg.go.dev/golang.org/x/sync/errgroup

```go
import "golang.org/x/sync/errgroup"

g, ctx := errgroup.WithContext(ctx)
for _, url := range urls {
    url := url
    g.Go(func() error {
        return fetch(ctx, url)
    })
}
if err := g.Wait(); err != nil { return err }
```

`SetLimit(N)` limita concorrência (Go 1.20+).

---

## 7. Semáforo (buffered channel)

Limitar concorrência s/ dependência externa.

```go
sem := make(chan struct{}, 10) // 10 concurrent max
var wg sync.WaitGroup
for _, task := range tasks {
    wg.Add(1)
    sem <- struct{}{}
    go func(t Task) {
        defer wg.Done()
        defer func() { <-sem }()
        process(t)
    }(task)
}
wg.Wait()
```

---

## 8. Pub/Sub

Broadcast p/ múltiplos subscribers.

```go
type Broker[T any] struct {
    mu   sync.RWMutex
    subs map[chan T]struct{}
}

func (b *Broker[T]) Subscribe() chan T {
    ch := make(chan T, 16)
    b.mu.Lock()
    b.subs[ch] = struct{}{}
    b.mu.Unlock()
    return ch
}

func (b *Broker[T]) Publish(v T) {
    b.mu.RLock()
    defer b.mu.RUnlock()
    for ch := range b.subs {
        select {
        case ch <- v:
        default: // drop se subscriber lento
        }
    }
}
```

---

## 9. Batching

Acumula itens até N ou timeout, então processa em lote.

```go
func batcher[T any](ctx context.Context, in <-chan T, size int, flush time.Duration, handle func([]T)) {
    batch := make([]T, 0, size)
    t := time.NewTimer(flush)
    defer t.Stop()
    for {
        select {
        case v, ok := <-in:
            if !ok {
                if len(batch) > 0 { handle(batch) }
                return
            }
            batch = append(batch, v)
            if len(batch) >= size {
                handle(batch)
                batch = batch[:0]
                t.Reset(flush)
            }
        case <-t.C:
            if len(batch) > 0 {
                handle(batch)
                batch = batch[:0]
            }
            t.Reset(flush)
        case <-ctx.Done():
            return
        }
    }
}
```

---

## 10. Retry c/ Exponential Backoff

Resiliência p/ operações transientes.

```go
func retry(ctx context.Context, attempts int, fn func() error) error {
    var err error
    delay := 100 * time.Millisecond
    for i := 0; i < attempts; i++ {
        if err = fn(); err == nil { return nil }
        if !isRetryable(err) { return err }
        select {
        case <-ctx.Done(): return ctx.Err()
        case <-time.After(delay):
        }
        delay *= 2
        if delay > 10*time.Second { delay = 10 * time.Second }
    }
    return fmt.Errorf("after %d attempts: %w", attempts, err)
}
```

Biblioteca: https://github.com/cenkalti/backoff

---

## Regras Gerais

1. **Sempre** ter context no path crítico
2. **Sempre** fechar channels no producer
3. **Sempre** testar com `-race`
4. **Sempre** ter WaitGroup/select cancellation p/ não vazar goroutines
5. Prefer channels a mutex quando natural; mutex quando proteger state composto
6. `errgroup` > WaitGroup quando precisar de erro propagado
