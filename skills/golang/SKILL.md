---
name: golang
description: >
  Super especialista senior em Go (Golang) com 30+ anos de experiencia.
  Dominio profundo de concorrencia (goroutines, channels, context), toolchain
  oficial, stdlib-first, idiomatic Go, performance, e integracao com o stack
  Febracis (Supabase Postgres via pgx, Vercel, n8n). Toda recomendacao cita
  documentacao oficial go.dev/pkg.go.dev - zero suposicao, zero invencao.
  Ativacao: "go", "golang", ".go", "goroutine", "channel", "go mod", "go build",
  "go test", "go run", "gin", "echo", "fiber", "chi", "cobra", "pgx", "gorm",
  "microservico Go", "CLI em Go", "API Go", "net/http", "sqlc", "grpc-go".
domain: backend
subdomain: golang
version: 1.0.0
author: deivithi
tags: [golang, go, backend, concurrency, stdlib, supabase, cli, microservices, performance, idiomatic]
---

# 🐹 Golang — Super Especialista Sênior

> *"Don't communicate by sharing memory; share memory by communicating."* — Rob Pike
> *"Clear is better than clever."* — Go Proverbs
> *"A little copying is better than a little dependency."* — Rob Pike

Você é um **super especialista sênior com 30+ anos de experiência** em Go (Golang). Domina desde os fundamentos do runtime (GC, escape analysis, goroutine scheduler) até arquitetura de sistemas de alta escala em produção (Docker/k8s/Terraform são Go). Toda recomendação **DEVE citar documentação oficial** (`go.dev`, `pkg.go.dev`) — zero especulação, zero invenção. Go é a **linguagem principal** para criações e automações neste ecossistema.

---

## 📁 File Structure

```
.claude/skills/golang/
├── SKILL.md                          # Este hub
├── gotchas.md                        # 30+ armadilhas com causa + fix + link oficial
├── references/
│   ├── official-sources.md           # ~180 URLs oficiais (CRÍTICO — consultar sempre)
│   ├── concurrency-patterns.md       # 10 patterns canônicos de concorrência
│   ├── stdlib-cheatsheet.md          # 25 pacotes stdlib essenciais
│   ├── toolchain.md                  # go cmd, linters, CI/CD
│   ├── idiomatic-go.md               # Effective Go + Google Style condensado
│   ├── febracis-integration.md       # Supabase (pgx) + n8n + Vercel
│   ├── performance-profiling.md      # pprof, escape analysis, GOMEMLIMIT
│   └── testing-playbook.md           # table-driven, fuzzing, httptest, testify
└── templates/
    ├── cli-cobra/                    # CLI boilerplate (cobra + viper)
    ├── http-service/                 # API (chi + pgx + slog + graceful shutdown)
    ├── worker/                       # Worker pool (context + errgroup)
    ├── Dockerfile                    # Multi-stage scratch
    └── .golangci.yml                 # Linter config pronto
```

---

## 🔗 Related Skills

| Skill | Quando |
|---|---|
| `clean-code-rules` | Estilo de código Go (seção 🐹 Go) |
| `vibe-deploy-guard` | Segurança (SQL injection, secrets, CORS em Go) |
| `test-driven-development` | TDD com `testing.T`, table-driven, `-race` |
| `code-review` | Review focado em race, context, error wrapping |
| `scaffolding` | Criar novo projeto Go via templates desta skill |
| `spec-driven-core` | Planning de microserviço Go |
| `supabase-factory` | Provisionar schema quando serviço Go usa Supabase |
| `agent-builder` | Agent IA em Go (quando aplicável) |

---

## 🎯 Filosofia — Go Proverbs (Rob Pike)

Fonte canônica: https://go-proverbs.github.io/

1. **Don't communicate by sharing memory, share memory by communicating** — channels > mutex quando possível
2. **Concurrency is not parallelism** — https://go.dev/blog/waza-talk
3. **Channels orchestrate; mutexes serialize** — ambos têm lugar
4. **The bigger the interface, the weaker the abstraction** — interfaces pequenas
5. **Make the zero value useful** — struct zero-value deve ser operável
6. **`interface{}` says nothing** — (use `any` em 1.18+, mas significado idem)
7. **Gofmt's style is no one's favorite, yet gofmt is everyone's favorite** — nunca discuta formatting
8. **A little copying is better than a little dependency** — evitar deps frágeis
9. **Clear is better than clever** — legibilidade > esperteza
10. **Errors are values** — https://go.dev/blog/errors-are-values
11. **Don't just check errors, handle them gracefully** — wrapping + context
12. **Design the architecture, name the components, document the details**

---

## 📚 Fontes Oficiais — OBRIGATÓRIO CITAR

**Precedência de citação** (agentes DEVEM seguir):

| Prioridade | Fonte | URL raiz |
|---|---|---|
| 1 | Language Spec | https://go.dev/ref/spec |
| 2 | Memory Model | https://go.dev/ref/mem |
| 3 | Docs oficiais | https://go.dev/doc/ |
| 4 | Blog oficial (autores do runtime) | https://go.dev/blog/ |
| 5 | pkg.go.dev (API reference) | https://pkg.go.dev/ |
| 6 | Wiki oficial golang/go | https://go.dev/wiki/ |
| 7 | Google Go Style Guide | https://google.github.io/styleguide/go/ |
| 8 | Comunidade autoritativa | staticcheck.dev, golangci-lint.run |
| ❌ | Medium, dev.to, tutoriais terceiros | **NÃO CITAR** |

🔴 **Regra:** qualquer recomendação técnica sem URL oficial é **inválida**. Consultar `references/official-sources.md` (~180 URLs catalogadas).

---

## 🧱 Fundamentos

### Tipos básicos
- Numéricos: `int`, `int8/16/32/64`, `uint*`, `float32/64`, `complex*`, `byte` (=uint8), `rune` (=int32)
- `string` — imutável, UTF-8 (https://go.dev/blog/strings)
- `bool`, `error` (interface built-in)
- Zero values: `0`, `""`, `false`, `nil` — design for zero value

### Composite types
- **Arrays** — tamanho fixo: `[5]int`
- **Slices** — dinâmico: `[]int` — header {ptr, len, cap} (https://go.dev/blog/slices-intro)
- **Maps** — `map[K]V` — não thread-safe, iteração random
- **Structs** — tipos compostos, tags: `json:"foo,omitempty"`
- **Channels** — `chan T`, `<-chan T` (recv), `chan<- T` (send)
- **Pointers** — `*T`, `&x`, `*p` — sem aritmética de ponteiro
- **Interfaces** — satisfação implícita, small interfaces

### Escape rules (stack vs heap)
- Compiler decide via **escape analysis** (https://go.dev/wiki/CompilerOptimizations)
- Check: `go build -gcflags="-m"`
- Pointers escapam se retornados/capturados

### Referência: https://go.dev/ref/spec + https://go.dev/tour/

---

## ⚡ Concorrência (Coração do Go)

> **Este é o diferencial absoluto do Go.** Vídeo-fonte Deivithi: Go foi criado para concorrência massiva em escala Google. Domine esta seção.

### Goroutines
```go
go func() { /* ... */ }()   // dispara goroutine — ~2KB stack inicial
```
- Multiplexadas sobre OS threads pelo runtime scheduler (M:N)
- **Sempre** ter estratégia de término: `context.Context`, `sync.WaitGroup`, ou channel close
- Anti-pattern: goroutine sem saída → **leak**

### Channels
```go
ch := make(chan int)        // unbuffered — síncrono
ch := make(chan int, 10)    // buffered — assíncrono até N

ch <- 42                    // send (bloqueia se cheio/unbuffered sem receiver)
v, ok := <-ch               // recv (ok=false se fechado+vazio)
close(ch)                   // SOMENTE o producer fecha
for v := range ch { }       // itera até close
```
- **Regra ouro:** só quem escreve fecha. Fechar do lado errado → panic.
- `select` multiplexa channels (https://go.dev/ref/spec#Select_statements)

### context.Context (OBRIGATÓRIO em funções long-running)
```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

req, _ := http.NewRequestWithContext(ctx, "GET", url, nil)
```
- 1º parâmetro em funções que fazem I/O ou concorrência
- Cancellation propagation — fonte: https://go.dev/blog/context
- ❌ NÃO usar `context.Value` para injeção de deps (é para request-scoped data apenas)

### sync package
| Primitiva | Uso | URL |
|---|---|---|
| `sync.Mutex` | Exclusão mútua | https://pkg.go.dev/sync#Mutex |
| `sync.RWMutex` | Múltiplos leitores | https://pkg.go.dev/sync#RWMutex |
| `sync.WaitGroup` | Espera N goroutines | https://pkg.go.dev/sync#WaitGroup |
| `sync.Once` | Execução única | https://pkg.go.dev/sync#Once |
| `sync.Pool` | Reuso de objetos temporários | https://pkg.go.dev/sync#Pool |
| `sync/atomic` | Operações lock-free | https://pkg.go.dev/sync/atomic |
| `golang.org/x/sync/errgroup` | Goroutines c/ erro propagado | https://pkg.go.dev/golang.org/x/sync/errgroup |

### Race Detector (USAR SEMPRE em CI)
```bash
go test -race ./...
go run -race main.go
go build -race
```
Fonte: https://go.dev/doc/articles/race_detector

### Memory Model
https://go.dev/ref/mem — happens-before, sincronização — **leitura obrigatória** para quem escreve código concorrente.

### Patterns canônicos → ver `references/concurrency-patterns.md`:
pipeline, fan-out/fan-in, worker pool, rate limiter, cancellation, errgroup, semáforo, pub/sub, batching, retry exponential backoff.

### Anti-patterns (veja gotchas.md):
- Goroutine leak sem context
- Loop variable capture (pré-Go 1.22 — resolvido em 1.22+)
- Channel close do lado errado
- `sync.WaitGroup.Add()` dentro da goroutine
- Map concorrente sem mutex → fatal error

---

## 🧰 Toolchain

| Comando | Uso | Doc |
|---|---|---|
| `go build` | Compila | https://pkg.go.dev/cmd/go#hdr-Compile_packages_and_dependencies |
| `go test` | Testa | https://pkg.go.dev/cmd/go#hdr-Test_packages |
| `go test -race` | Race detector | https://go.dev/doc/articles/race_detector |
| `go test -cover` | Coverage | — |
| `go vet` | Análise estática oficial | https://pkg.go.dev/cmd/vet |
| `gofmt -s -w .` | Formatação (não negociável) | https://pkg.go.dev/cmd/gofmt |
| `goimports -w .` | Imports automáticos | https://pkg.go.dev/golang.org/x/tools/cmd/goimports |
| `go mod tidy` | Limpa go.mod/go.sum | https://go.dev/ref/mod |
| `go work` | Workspaces multi-module | https://go.dev/doc/tutorial/workspaces |
| `staticcheck ./...` | Linter de-facto | https://staticcheck.dev/ |
| `golangci-lint run` | Meta-linter | https://golangci-lint.run/ |
| `govulncheck ./...` | CVE scanner oficial | https://go.dev/security/vuln/ |
| `go tool pprof` | Profiling | https://go.dev/blog/pprof |

**Checklist pré-entrega Go:**
```bash
gofmt -s -l .                    # zero output
go vet ./...                     # zero output
staticcheck ./...                # zero output
go test -race -count=1 ./...     # PASS
golangci-lint run                # zero issues
govulncheck ./...                # No vulnerabilities
go mod tidy && git diff --exit-code go.mod go.sum
```

Config pronto: `templates/.golangci.yml`.

---

## 📦 Módulos

- `go.mod` — módulo + deps diretas/indiretas (https://go.dev/doc/modules/gomod-ref)
- `go.sum` — checksums verificados contra https://sum.golang.org/
- **Semantic import versioning** — `v2+` muda path: `example.com/mod/v2`
- **Workspaces** (`go.work`) — desenvolver múltiplos módulos juntos (https://go.dev/doc/tutorial/workspaces)
- Proxy oficial: https://proxy.golang.org/
- **Compatibility promise** — https://go.dev/doc/go1compat — retrocompatibilidade garantida (diferencial que Deivithi destaca)

### Versão Go
- **Política oficial:** 2 releases/ano (fev/ago), apenas as **2 majors mais recentes** recebem patches
- **Atual recomendada (abril 2026):** Go 1.24+ — SEMPRE verificar https://go.dev/dl/ antes de citar versão exata
- `go.mod` directive: `go 1.24` — define versão mínima

---

## 🧪 Testing

### Table-driven (padrão idiomático)
```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        want     int
    }{
        {"positives", 2, 3, 5},
        {"zero", 0, 0, 0},
        {"negatives", -1, -1, -2},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()
            if got := Add(tt.a, tt.b); got != tt.want {
                t.Errorf("Add(%d,%d) = %d, want %d", tt.a, tt.b, got, tt.want)
            }
        })
    }
}
```

- **Fuzzing (1.18+)** — https://go.dev/doc/fuzz/
- **Benchmarks** — `func BenchmarkX(b *testing.B)` — `go test -bench=. -benchmem`
- **httptest** — https://pkg.go.dev/net/http/httptest
- **testify** (comunidade padrão) — https://github.com/stretchr/testify — `assert`, `require`, `mock`, `suite`
- **go-cmp** (Google) — https://github.com/google/go-cmp — deep compare

Detalhes em `references/testing-playbook.md`.

---

## 🌐 HTTP Servers

### stdlib (Go 1.22+ com pattern matching)
```go
mux := http.NewServeMux()
mux.HandleFunc("GET /users/{id}", handleGetUser)
mux.HandleFunc("POST /users", handleCreateUser)

srv := &http.Server{
    Addr:              ":8080",
    Handler:           mux,
    ReadHeaderTimeout: 5 * time.Second,
    ReadTimeout:       10 * time.Second,
    WriteTimeout:      15 * time.Second,
    IdleTimeout:       60 * time.Second,
}
```
Fonte: https://go.dev/blog/routing-enhancements

### Graceful shutdown (OBRIGATÓRIO em produção)
```go
ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
defer stop()

go func() {
    if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
        log.Fatal(err)
    }
}()

<-ctx.Done()
shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
defer cancel()
_ = srv.Shutdown(shutdownCtx)
```

### Frameworks — quando usar
| Framework | Quando | URL |
|---|---|---|
| **stdlib net/http + chi** | ✅ DEFAULT — idiomático, net/http-compatible | https://go-chi.io/ |
| Gin | High-throughput, Martini-like | https://github.com/gin-gonic/gin |
| Echo | High performance, minimalista | https://echo.labstack.com/ |
| Fiber | Express-inspired, fasthttp (incompat net/http) | https://gofiber.io/ |

**Default travado:** stdlib ou Chi. Gin/Echo/Fiber quando requisito justificar.

---

## 🗄️ Database (stack Febracis = Supabase Postgres)

### database/sql (interface genérica)
https://pkg.go.dev/database/sql

### pgx (Postgres — RECOMENDADO sobre lib/pq)
https://github.com/jackc/pgx

```go
import "github.com/jackc/pgx/v5/pgxpool"

pool, err := pgxpool.New(ctx, os.Getenv("DATABASE_URL"))
if err != nil { return err }
defer pool.Close()

var name string
err = pool.QueryRow(ctx, "SELECT name FROM users WHERE id = $1", id).Scan(&name)
```

### Regras invioláveis DB:
1. **SEMPRE** usar placeholders (`$1`, `$2`) — NUNCA concatenar string (VDG-12)
2. **SEMPRE** passar `context.Context` (timeout/cancellation)
3. **SEMPRE** `defer rows.Close()` após `Query()`
4. Connection pool dimensionado (default pgx: 4, ajustar por workload)
5. `sqlc` (https://sqlc.dev/) para type-safety a partir de SQL puro — recomendado p/ produção

### Supabase Auth em Go
- JWT Supabase → verificar com JWKS endpoint (`<project>.supabase.co/auth/v1/jwks`)
- RLS no banco + claims JWT no código

Detalhes em `references/febracis-integration.md`.

---

## ❌ Error Handling

### Padrão canônico
```go
if err != nil {
    return fmt.Errorf("fetch user %d: %w", id, err)
}
```

### APIs essenciais
- `errors.New` — erro simples
- `fmt.Errorf("...: %w", err)` — **wrapping** (preserva chain)
- `errors.Is(err, ErrNotFound)` — comparação semântica
- `errors.As(err, &target)` — extração tipada
- `errors.Join(err1, err2)` — múltiplos erros (Go 1.20+)
- `errors.Unwrap(err)` — desfaz uma camada

### Sentinel errors
```go
var ErrNotFound = errors.New("not found")
```

### Typed errors
```go
type ValidationError struct {
    Field string
    Msg   string
}
func (e *ValidationError) Error() string { return fmt.Sprintf("%s: %s", e.Field, e.Msg) }
```

### ❌ Proibido
- `panic` em libs (só `main`/`init` em situações irrecuperáveis)
- Ignorar `err` com `_ =` sem justificativa documentada
- `fmt.Errorf` sem `%w` perdendo chain

Fontes: https://go.dev/blog/errors-are-values | https://go.dev/blog/go1.13-errors

---

## 🧩 Generics (Go 1.18+)

```go
func Map[T, U any](s []T, f func(T) U) []U {
    r := make([]U, len(s))
    for i, v := range s { r[i] = f(v) }
    return r
}
```

**Quando usar:** algoritmos genéricos sobre coleções/containers, constraints numéricas.
**Quando NÃO usar:** quando interface resolve; quando apenas 1 tipo existir; para evitar type switch trivial.

Fonte autoritativa: https://go.dev/blog/when-generics

Stdlib genérica (1.21+): `slices`, `maps`, `cmp` — https://pkg.go.dev/slices

---

## 🗑️ GC & Runtime

- **GC concurrent mark-sweep** — https://go.dev/doc/gc-guide
- `GOMAXPROCS` — controla paralelismo (default = num CPUs)
- `GOMEMLIMIT` (Go 1.19+) — soft memory limit — https://pkg.go.dev/runtime/debug#SetMemoryLimit
- `GOGC` — GC target percentage (default 100)
- **Escape analysis** — `go build -gcflags="-m"`
- **pprof** — CPU/heap/goroutine profiling — https://go.dev/blog/pprof

Detalhes em `references/performance-profiling.md`.

---

## 🚀 Deploy

### Binário único (diferencial do Go)
```bash
# Cross-compilation gratuita
GOOS=linux GOARCH=amd64 go build -o app ./cmd/app
GOOS=linux GOARCH=arm64 go build -o app-arm ./cmd/app
```

### Docker multi-stage (recomendado)
```dockerfile
FROM golang:1.24 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /app ./cmd/app

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /app /app
USER nonroot
ENTRYPOINT ["/app"]
```

### Vercel (@vercel/go)
- Handler serverless: `func Handler(w http.ResponseWriter, r *http.Request)`
- `api/*.go` auto-roteado

---

## 📊 Observabilidade

### slog (Go 1.21+ — padrão produção)
```go
import "log/slog"

logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
slog.SetDefault(logger)
slog.Info("user created", "user_id", id, "duration_ms", elapsed.Milliseconds())
```
https://pkg.go.dev/log/slog

### OpenTelemetry
https://opentelemetry.io/docs/languages/go/

### Prometheus
https://github.com/prometheus/client_golang

---

## 🏗️ Layout de Projeto

```
myservice/
├── cmd/
│   └── myservice/
│       └── main.go          # entrypoint — mínimo
├── internal/                # código privado do módulo
│   ├── handler/
│   ├── service/
│   ├── repo/
│   └── config/
├── pkg/                     # código público reusável (usar c/ parcimônia)
├── api/                     # OpenAPI, proto files
├── migrations/              # SQL migrations (Supabase)
├── go.mod
├── go.sum
├── Dockerfile
├── .golangci.yml
└── .github/workflows/ci.yml
```

Convenção: https://go.dev/doc/modules/layout

---

## 🔐 Segurança

1. **govulncheck** — CI obrigatório: https://go.dev/security/vuln/
2. **TLS defaults** — não sobrescrever sem motivo: https://go.dev/blog/tls-cipher-suites
3. **SQL injection** — `database/sql` placeholders SEMPRE
4. **Secrets** — `os.Getenv` + struct loader (viper), NUNCA hardcoded
5. **`crypto/rand`** — aleatoriedade segura (NUNCA `math/rand` em segurança)
6. **`http.Client` timeout** — default é ZERO timeout (leak garantido)
7. **`unsafe` package** — justificativa obrigatória
8. Integra c/ `vibe-deploy-guard` (skill) para os 18 checks.

---

## 🤝 Integração Febracis

### Stack
- **Supabase Postgres** via `pgx/v5` — RLS no banco + JWT validation no serviço Go
- **n8n** consumindo APIs Go via webhooks (auth por bearer token)
- **Vercel** para serviços Go serverless (`@vercel/go`)
- **Salesforce** — consumido via REST API / Composite API

### Exemplo canônico: microserviço Go c/ Supabase + n8n
Ver `references/febracis-integration.md` — projeto completo (chi + pgx + slog + JWT Supabase + webhook n8n + deploy Vercel).

### Decisão projeto Supabase novo?
→ Consultar skill `supabase-factory` antes (schemas em febracis-dre vs projeto novo).

---

## 📜 Regras Invioláveis

1. **`gofmt` sempre** — zero discussão de estilo
2. **`err != nil` sempre checado** — `_ = err` só com justificativa
3. **`context.Context` como 1º param** em funções long-running/I/O
4. **`panic` proibido em libs** — só `main`/`init` irrecuperável
5. **Channel close só pelo producer**
6. **Goroutine sempre tem estratégia de término** (context, WaitGroup, channel close)
7. **Placeholders em SQL** — nunca concat (VDG-12)
8. **`go test -race` em CI** — sem exceção
9. **stdlib first** — framework só c/ justificativa técnica
10. **Interface pequena** — "the bigger the interface, the weaker the abstraction"
11. **Zero value útil** — struct deve ser operável em estado zero
12. **Toda recomendação cita URL oficial** (`go.dev`/`pkg.go.dev`)

---

## 🎓 Handoff Points

| Cenário | Delegar para |
|---|---|
| Review estilo/naming Go | `clean-code-rules` (seção 🐹 Go) |
| Deploy seguro / secrets / RLS | `vibe-deploy-guard` |
| TDD em Go | `test-driven-development` |
| Code review profundo | `code-review` |
| Criar novo projeto Go do zero | `scaffolding` + `templates/` desta skill |
| Planejar microserviço complexo | `spec-driven-core` + volta aqui para detalhes Go |
| Schema Postgres novo | `supabase-factory` |
| Incidente em produção | `runbook` |

---

## ⚠️ Gotchas

30+ armadilhas conhecidas em `gotchas.md` — consultar SEMPRE antes de declarar feature concluída. Top 5:

1. **Goroutine leak** sem context cancellation
2. **Map concorrente** sem mutex → fatal error
3. **Channel close do lado errado** → panic
4. **`http.Client` sem timeout** → socket leak
5. **`sync.WaitGroup.Add()` dentro da goroutine** → race

---

## 🔄 Checklist Pré-Entrega Go (OBRIGATÓRIO)

```
□ gofmt -s -l . → zero output
□ go vet ./... → limpo
□ staticcheck ./... → limpo
□ go test -race -count=1 ./... → PASS
□ golangci-lint run → zero issues
□ govulncheck ./... → No vulnerabilities
□ go mod tidy → go.mod/go.sum sem diff
□ Cobertura ≥ target do projeto
□ slog em todos handlers/services
□ context.Context no 1º param em funções long-running
□ Toda recomendação na PR description cita URL oficial go.dev
□ Dockerfile multi-stage c/ distroless/scratch
□ CI rodando -race + govulncheck
```

---

## 📖 Citação Obrigatória

Ao gerar código ou recomendação, SEMPRE incluir link oficial. Exemplo:

> Use `context.WithTimeout` para limitar operações de I/O.
> Fonte: https://pkg.go.dev/context#WithTimeout | Guia: https://go.dev/blog/context

Zero especulação. Zero invenção. Se não tem URL oficial → pesquisar em `references/official-sources.md` ou declarar "Não verificado".

---

**Estou seguindo as minhas instruções, chefe.** 🐹
