# 📚 Stdlib Cheatsheet — 25 Pacotes Essenciais

> 1-liner por pacote + URL pkg.go.dev. Ordem alfabética.

| Pacote | Uso | URL |
|---|---|---|
| `bufio` | I/O com buffering (Scanner, Reader, Writer) | https://pkg.go.dev/bufio |
| `bytes` | Operações em byte slices + Buffer | https://pkg.go.dev/bytes |
| `context` | Cancelamento, deadlines, valores cross-API | https://pkg.go.dev/context |
| `crypto/rand` | Aleatoriedade segura (tokens, UUIDs) | https://pkg.go.dev/crypto/rand |
| `crypto/tls` | TLS 1.2/1.3, certificados | https://pkg.go.dev/crypto/tls |
| `database/sql` | Interface genérica SQL, connection pool | https://pkg.go.dev/database/sql |
| `encoding/binary` | Serialização binária, endianness | https://pkg.go.dev/encoding/binary |
| `encoding/json` | Marshal/Unmarshal, struct tags, Decoder | https://pkg.go.dev/encoding/json |
| `errors` | Is, As, Join, Unwrap, New | https://pkg.go.dev/errors |
| `fmt` | Formatação I/O (Printf, Errorf com %w) | https://pkg.go.dev/fmt |
| `io` | Reader, Writer, Closer, Copy (interfaces fundamentais) | https://pkg.go.dev/io |
| `log/slog` | Structured logging (padrão produção 1.21+) | https://pkg.go.dev/log/slog |
| `net` | TCP/UDP/Unix sockets, DNS | https://pkg.go.dev/net |
| `net/http` | Server/client HTTP, ServeMux (1.22+ patterns) | https://pkg.go.dev/net/http |
| `net/http/httptest` | Testing HTTP (ResponseRecorder, Server) | https://pkg.go.dev/net/http/httptest |
| `os` | Interação c/ SO, args, env, arquivos, sinais | https://pkg.go.dev/os |
| `os/signal` | Sinais SO (SIGTERM, graceful shutdown) | https://pkg.go.dev/os/signal |
| `reflect` | Reflexão runtime (parcimônia) | https://pkg.go.dev/reflect |
| `regexp` | Regex RE2 (linear time) | https://pkg.go.dev/regexp |
| `runtime` | Runtime Go, GOMAXPROCS, GC | https://pkg.go.dev/runtime |
| `runtime/pprof` | Profiling CPU/heap/goroutine | https://pkg.go.dev/runtime/pprof |
| `strings` | Manipulação strings + Builder | https://pkg.go.dev/strings |
| `sync` | Mutex, RWMutex, WaitGroup, Once, Pool, Map | https://pkg.go.dev/sync |
| `sync/atomic` | Operações atômicas lock-free | https://pkg.go.dev/sync/atomic |
| `testing` | Unit tests, benchmarks, fuzzing | https://pkg.go.dev/testing |
| `time` | Tempo, durações, timers, tickers | https://pkg.go.dev/time |

## Pacotes Genéricos (Go 1.21+)

| Pacote | Uso | URL |
|---|---|---|
| `slices` | Ops genéricas em slices (Contains, Sort, Clone, Index) | https://pkg.go.dev/slices |
| `maps` | Ops genéricas em maps (Keys, Values, Equal, Clone) | https://pkg.go.dev/maps |
| `cmp` | Ordered constraint, Compare, Less | https://pkg.go.dev/cmp |

## Extensões Oficiais (`golang.org/x/*`)

| Pacote | Uso | URL |
|---|---|---|
| `errgroup` | Goroutines c/ erro propagado + cancel | https://pkg.go.dev/golang.org/x/sync/errgroup |
| `semaphore` | Semáforo ponderado | https://pkg.go.dev/golang.org/x/sync/semaphore |
| `rate` | Rate limiter (token bucket) | https://pkg.go.dev/golang.org/x/time/rate |
| `vuln` | govulncheck (CVE scanner) | https://pkg.go.dev/golang.org/x/vuln |

## Regra de Ouro

**stdlib first.** Frameworks externos só quando justificar (benchmark, feature stdlib não oferece, padrão de mercado). Fonte: "A little copying is better than a little dependency" (Go Proverb).
