# 🚀 Performance & Profiling — Go

> Regra ouro: **meça antes de otimizar**. Go dá pprof + benchmarks + escape analysis nativos.

---

## 1. Benchmarks

```go
func BenchmarkProcess(b *testing.B) {
    input := setupLargeInput()
    b.ResetTimer()
    b.ReportAllocs()
    for i := 0; i < b.N; i++ {
        _ = process(input)
    }
}
```

```bash
go test -bench=. -benchmem -benchtime=3s ./...
go test -bench=BenchmarkProcess -cpu=1,2,4,8 ./...  # varia GOMAXPROCS
```

Comparar runs: `golang.org/x/perf/cmd/benchstat`:
```bash
go install golang.org/x/perf/cmd/benchstat@latest
go test -bench=. -count=10 > old.txt
# ... mudanças ...
go test -bench=. -count=10 > new.txt
benchstat old.txt new.txt
```

Fonte: https://pkg.go.dev/testing#hdr-Benchmarks

---

## 2. pprof — CPU Profiling

```go
import _ "net/http/pprof"

go func() {
    slog.Info("pprof", "addr", "localhost:6060")
    http.ListenAndServe("localhost:6060", nil)
}()
```

```bash
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30
# no prompt:
(pprof) top
(pprof) list <func>
(pprof) web       # abre SVG (requer graphviz)
```

Via test:
```bash
go test -cpuprofile=cpu.prof -bench=.
go tool pprof cpu.prof
```

Fonte: https://go.dev/blog/pprof | https://pkg.go.dev/net/http/pprof

---

## 3. Heap Profiling

```bash
curl -o heap.prof http://localhost:6060/debug/pprof/heap
go tool pprof heap.prof
(pprof) top
(pprof) list <func>
```

Métricas:
- `inuse_space` — memória viva (default)
- `alloc_space` — total alocado ao longo do tempo
- `inuse_objects` / `alloc_objects` — contagem

---

## 4. Goroutine Profiling

```bash
curl http://localhost:6060/debug/pprof/goroutine?debug=1
# ou:
go tool pprof http://localhost:6060/debug/pprof/goroutine
```

Detecta leaks: muitas goroutines na mesma stack = provavelmente vazando.

---

## 5. Execution Tracer

```go
import "runtime/trace"

f, _ := os.Create("trace.out")
defer f.Close()
trace.Start(f)
defer trace.Stop()
// ... código ...
```

```bash
go tool trace trace.out  # abre UI web
```

Mostra: scheduler events, GC pauses, syscalls, goroutine lifetimes.

Fonte: https://pkg.go.dev/runtime/trace

---

## 6. Escape Analysis

```bash
go build -gcflags="-m" ./... 2>&1 | grep "escapes to heap"
go build -gcflags="-m=2" ./...  # verbose
```

Objetivo: reduzir heap allocations. Cada `escape` = aloc + pressão no GC.

Regras gerais:
- Retornar ponteiro → escapa
- Capturar em closure → escapa
- Interface satisfaction → pode escapar (devido a boxing)
- Slice crescendo além de capacidade estimada → escapa

Fonte: https://go.dev/wiki/CompilerOptimizations

---

## 7. Runtime Knobs

| Env | Uso | Default |
|---|---|---|
| `GOMAXPROCS` | Paralelismo de OS threads | Num CPUs |
| `GOGC` | GC target % (heap growth antes de GC) | 100 |
| `GOMEMLIMIT` | Soft memory limit (1.19+) | off |
| `GODEBUG=gctrace=1` | Log de cada GC | off |
| `GODEBUG=schedtrace=1000` | Log scheduler a cada 1s | off |

Exemplo production:
```bash
GOMEMLIMIT=512MiB GOGC=50 ./app
```

Fonte: https://go.dev/doc/gc-guide | https://pkg.go.dev/runtime

---

## 8. Common Optimizations

### sync.Pool p/ objetos temporários
```go
var bufPool = sync.Pool{
    New: func() any { return new(bytes.Buffer) },
}
buf := bufPool.Get().(*bytes.Buffer)
defer func() { buf.Reset(); bufPool.Put(buf) }()
```

### `strings.Builder` em concatenações em loop
```go
var b strings.Builder
b.Grow(1024) // pre-aloc
for _, s := range parts { b.WriteString(s) }
result := b.String()
```

### Pre-allocate slices
```go
results := make([]int, 0, len(input))  // cap = len(input) evita regrowth
```

### Evitar reflect em hot path
Code gen (`sqlc`, `easyjson`, protobuf) >> reflect.

---

## 9. Quando NÃO otimizar

1. Código ainda não está em produção
2. Ainda não mediu (profile vazio)
3. Complexidade algorítmica já dominante (otimizar micro antes de O(n²))
4. Hot path consume <1% do tempo total
5. Otimização torna código ilegível sem ganho comprovado (benchmark)

**Go Proverb:** "Premature optimization is the root of all evil" (Knuth).

---

## Checklist de Performance Review

```
□ Benchmark antes + depois
□ benchstat mostra ganho estatisticamente significativo
□ -race ainda passa
□ Heap allocations reduzidas (não aumentadas)
□ Sem reflect em hot path
□ sync.Pool se objetos temporários grandes
□ Pre-allocated slices quando tamanho conhecido
□ GC trace mostra pausas aceitáveis (<10ms p99)
□ GOMEMLIMIT configurado em produção
□ pprof CPU mostra tempo distribuído (não gargalo único)
```

## Fontes

- https://go.dev/doc/diagnostics
- https://go.dev/blog/pprof
- https://go.dev/doc/gc-guide
- https://go.dev/wiki/Performance
- https://go.dev/wiki/CompilerOptimizations
