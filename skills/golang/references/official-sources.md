# 📚 Official Sources — Golang

> ~180 URLs oficiais agrupadas em 19 categorias. **Toda recomendação técnica DEVE citar uma destas URLs.**
> Atualizado: 2026-04-20. Precedência: `go.dev/ref/*` > `go.dev/doc/*` > `go.dev/blog/*` > `pkg.go.dev` > `wiki` > comunidade autoritativa.

---

## 1. Language Specification (Autoridade Máxima)

- https://go.dev/ref/spec — The Go Programming Language Specification (documento normativo)
- https://go.dev/ref/ — Índice de todas as referências técnicas oficiais
- https://go.dev/doc/ — Hub central de documentação
- https://go.dev/doc/go1.22 — Release notes Go 1.22 (http.ServeMux patterns, range over int, loop var semantics)
- https://go.dev/doc/go1.23 — Release notes Go 1.23 (range-over-func iterators, unique package)
- https://go.dev/doc/go1.24 — Release notes Go 1.24 (generic type aliases, tool dependencies em go.mod)
- https://go.dev/doc/go1compat — Go 1 Compatibility Promise

---

## 2. Standard Library — Pacotes Essenciais

- https://pkg.go.dev/std — Índice completo stdlib
- https://pkg.go.dev/fmt — Formatação I/O (%v, %+v, %w, %T)
- https://pkg.go.dev/net/http — HTTP server/client, ServeMux, Handler
- https://pkg.go.dev/context — Cancelamento, deadlines, valores cross-API
- https://pkg.go.dev/sync — Mutex, RWMutex, WaitGroup, Once, Pool, Map, Cond
- https://pkg.go.dev/sync/atomic — Operações atômicas lock-free
- https://pkg.go.dev/encoding/json — Marshal/Unmarshal, tags, streaming
- https://pkg.go.dev/database/sql — Interface genérica SQL, connection pool
- https://pkg.go.dev/io — Reader, Writer, Closer, Copy
- https://pkg.go.dev/os — SO, args, env, arquivos, sinais
- https://pkg.go.dev/time — Tempo, durações, timers, tickers
- https://pkg.go.dev/errors — Is, As, Join, Unwrap, New
- https://pkg.go.dev/testing — Unit tests, benchmarks, fuzzing
- https://pkg.go.dev/log/slog — Structured logging (Go 1.21+, padrão produção)
- https://pkg.go.dev/runtime — Runtime Go, GOMAXPROCS, GC, goroutines
- https://pkg.go.dev/bytes — Byte slices, Buffer
- https://pkg.go.dev/strings — Strings, Builder
- https://pkg.go.dev/bufio — I/O com buffering
- https://pkg.go.dev/encoding/binary — Serialização binária
- https://pkg.go.dev/net — TCP/UDP/Unix sockets, DNS
- https://pkg.go.dev/crypto/tls — TLS 1.2/1.3
- https://pkg.go.dev/crypto/rand — Aleatoriedade segura
- https://pkg.go.dev/reflect — Reflexão runtime (parcimônia)
- https://pkg.go.dev/os/signal — Sinais SO (SIGTERM, graceful shutdown)

---

## 3. Guias de Estilo Oficiais

- https://go.dev/doc/effective_go — Effective Go (canônico)
- https://google.github.io/styleguide/go/ — Google Go Style Guide
- https://google.github.io/styleguide/go/decisions — Style Decisions
- https://google.github.io/styleguide/go/best-practices — Best Practices
- https://go.dev/wiki/CodeReviewComments — Code Review Comments (wiki oficial)
- https://go-proverbs.github.io/ — Go Proverbs (Rob Pike)
- https://go.dev/talks/2012/splash.article — "Go at Google: Language Design..." (Pike)

---

## 4. Concorrência

- https://go.dev/doc/effective_go#concurrency — Seção de concorrência (Effective Go)
- https://go.dev/blog/pipelines — Pipelines e cancelamento com channels
- https://go.dev/blog/context — Uso correto de context.Context
- https://go.dev/blog/race-detector — Race detector
- https://pkg.go.dev/sync#Mutex
- https://pkg.go.dev/sync#WaitGroup
- https://pkg.go.dev/sync#RWMutex
- https://go.dev/ref/mem — The Go Memory Model (happens-before)
- https://go.dev/doc/articles/race_detector — Race Detector Article
- https://go.dev/talks/2012/concurrency.slide — "Go Concurrency Patterns" (Pike)
- https://go.dev/talks/2013/advconc.slide — "Advanced Go Concurrency Patterns"
- https://go.dev/blog/waza-talk — "Concurrency is not parallelism"
- https://pkg.go.dev/golang.org/x/sync/errgroup — errgroup

---

## 5. Módulos e Workspaces

- https://go.dev/ref/mod — Go Modules Reference
- https://go.dev/doc/modules/managing-dependencies
- https://go.dev/doc/modules/gomod-ref — go.mod file reference
- https://go.dev/doc/modules/layout — Organizing a Go module
- https://go.dev/ref/mod#go-sum-files — go.sum
- https://go.dev/doc/tutorial/workspaces — Tutorial workspaces
- https://go.dev/blog/get-familiar-with-workspaces
- https://proxy.golang.org/ — Go module proxy oficial
- https://sum.golang.org/ — Checksum database oficial

---

## 6. Testing, Benchmarks, Fuzzing

- https://pkg.go.dev/testing — Package testing
- https://go.dev/doc/tutorial/add-a-test — Tutorial de testes
- https://go.dev/blog/subtests — Subtests com t.Run
- https://go.dev/wiki/TableDrivenTests
- https://go.dev/doc/fuzz/ — Go Fuzzing (1.18+)
- https://go.dev/blog/fuzz-beta
- https://pkg.go.dev/testing#hdr-Benchmarks
- https://pkg.go.dev/testing/quick
- https://pkg.go.dev/net/http/httptest
- https://pkg.go.dev/testing/iotest
- https://github.com/stretchr/testify — [comunidade-autoritativa] Testify
- https://github.com/google/go-cmp — go-cmp (Google)

---

## 7. HTTP Servers e Routing

- https://pkg.go.dev/net/http
- https://pkg.go.dev/net/http#ServeMux — Go 1.22+ pattern matching
- https://go.dev/blog/routing-enhancements — Enhanced routing (1.22)
- https://pkg.go.dev/net/http#Handler
- https://pkg.go.dev/net/http#HandlerFunc
- https://go.dev/doc/articles/wiki/ — Writing web applications
- https://pkg.go.dev/net/http/httputil — Reverse proxy

---

## 8. Error Handling

- https://go.dev/blog/error-handling-and-go
- https://go.dev/blog/errors-are-values — "Errors are values" (Pike)
- https://go.dev/blog/go1.13-errors — errors.Is, As, %w
- https://pkg.go.dev/errors#Is
- https://pkg.go.dev/errors#As
- https://pkg.go.dev/errors#Join — Go 1.20+
- https://pkg.go.dev/errors#Unwrap
- https://go.dev/wiki/ErrorValueFAQ

---

## 9. Generics (Go 1.18+)

- https://go.dev/doc/tutorial/generics
- https://go.dev/blog/intro-generics
- https://go.dev/blog/when-generics
- https://go.dev/ref/spec#Type_parameters
- https://pkg.go.dev/slices — Package slices (Go 1.21+)
- https://pkg.go.dev/maps — Package maps (Go 1.21+)
- https://pkg.go.dev/cmp — Ordered, Compare, Less
- https://go.dev/blog/alias-names — Generic type aliases (Go 1.24)

---

## 10. Garbage Collector e Runtime

- https://go.dev/doc/gc-guide — A Guide to the Go Garbage Collector
- https://go.dev/blog/go15gc — Concurrent GC design
- https://tip.golang.org/doc/gc-guide — Tip version
- https://pkg.go.dev/runtime#GC
- https://pkg.go.dev/runtime/debug#SetMemoryLimit — GOMEMLIMIT (1.19+)
- https://go.dev/blog/ismmkeynote — "Getting to Go: GC Journey" (Rick Hudson)

---

## 11. Tooling Oficial

- https://pkg.go.dev/cmd/go — `go` command
- https://go.dev/doc/cmd — Índice de comandos
- https://pkg.go.dev/cmd/gofmt — gofmt
- https://pkg.go.dev/cmd/vet — go vet
- https://pkg.go.dev/cmd/compile — Compiler
- https://pkg.go.dev/cmd/link — Linker
- https://pkg.go.dev/golang.org/x/tools/cmd/goimports — goimports
- https://staticcheck.dev/ — [comunidade-autoritativa] Staticcheck
- https://staticcheck.dev/docs/checks/
- https://golangci-lint.run/ — [comunidade-autoritativa] golangci-lint
- https://golangci-lint.run/usage/linters/
- https://go.dev/security/vuln/ — Go vulnerability management
- https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck

---

## 12. Versionamento e Release Policy

- https://go.dev/doc/devel/release — Release History
- https://go.dev/doc/go1compat — Go 1 Compatibility Promise
- https://go.dev/wiki/Go-Release-Cycle — 2x/ano (fev/ago)
- https://go.dev/security — Security Policy (2 últimas majors)
- https://go.dev/dl/ — Downloads oficiais

**Política travada:** 2 releases/ano, apenas 2 majors recebem patches.
**Abril 2026 [Inferência]:** Go 1.24 / 1.25 / 1.26 — sempre verificar https://go.dev/dl/ antes de citar versão exata.

---

## 13. Performance, Profiling, Escape Analysis

- https://go.dev/blog/pprof — Profiling Go programs
- https://pkg.go.dev/net/http/pprof — pprof HTTP endpoints
- https://pkg.go.dev/runtime/pprof
- https://pkg.go.dev/runtime/trace — Execution tracer
- https://go.dev/doc/diagnostics — Diagnostics
- https://go.dev/wiki/CompilerOptimizations
- https://go.dev/wiki/Performance
- https://pkg.go.dev/cmd/compile#hdr-Compiler_Directives

---

## 14. Frameworks e Bibliotecas Populares [comunidade]

### Web Frameworks
- https://github.com/gin-gonic/gin — Gin (~78k stars)
- https://echo.labstack.com/
- https://github.com/labstack/echo
- https://gofiber.io/
- https://github.com/gofiber/fiber
- https://go-chi.io/
- https://github.com/go-chi/chi — **idiomático, default desta skill**

### Database / ORM
- https://github.com/jmoiron/sqlx
- https://github.com/jackc/pgx — **pgx, default Postgres**
- https://pkg.go.dev/github.com/jackc/pgx/v5
- https://gorm.io/
- https://github.com/go-gorm/gorm
- https://sqlc.dev/ — **sqlc, recomendado p/ produção**
- https://github.com/sqlc-dev/sqlc
- https://entgo.io/
- https://github.com/ent/ent

### gRPC
- https://grpc.io/docs/languages/go/
- https://github.com/grpc/grpc-go
- https://connectrpc.com/ — Connect (HTTP-native RPC)

### Observabilidade
- https://opentelemetry.io/docs/languages/go/
- https://github.com/prometheus/client_golang

### Validação / Config / CLI
- https://github.com/go-playground/validator
- https://github.com/spf13/viper
- https://github.com/spf13/cobra — usado por kubectl/docker

---

## 15. Infraestrutura Escrita em Go (Referências de Arquitetura)

- https://github.com/docker/docker — Docker Engine (moby)
- https://github.com/kubernetes/kubernetes — Kubernetes
- https://github.com/hashicorp/terraform — Terraform
- https://github.com/etcd-io/etcd
- https://github.com/prometheus/prometheus
- https://github.com/grafana/grafana
- https://github.com/traefik/traefik
- https://github.com/caddyserver/caddy
- https://github.com/cockroachdb/cockroach
- https://github.com/hashicorp/consul
- https://github.com/hashicorp/vault
- https://github.com/minio/minio

---

## 16. Segurança

- https://go.dev/security/ — Hub Go Security
- https://go.dev/security/best-practices
- https://pkg.go.dev/crypto — Pacotes crypto stdlib
- https://go.dev/blog/tls-cipher-suites — TLS defaults
- https://github.com/golang/go/security/advisories — Advisories oficiais

---

## 17. Talks e Artigos Canônicos (Leitura Obrigatória)

- https://go.dev/talks/2012/splash.article — "Go at Google" (Pike)
- https://go.dev/blog/laws-of-reflection
- https://go.dev/blog/slices-intro — Slices: usage and internals
- https://go.dev/blog/slices
- https://go.dev/blog/strings — Strings, bytes, runes, characters
- https://go.dev/blog/defer-panic-and-recover
- https://go.dev/blog/maps
- https://go.dev/blog/json

---

## 18. Wiki Oficial

- https://go.dev/wiki/ — Wiki hub
- https://go.dev/wiki/CommonMistakes
- https://go.dev/wiki/SliceTricks
- https://go.dev/wiki/Range — Range gotchas
- https://go.dev/wiki/LearnConcurrency

---

## 19. Playground e Tour

- https://go.dev/play/ — Go Playground (snippets executáveis)
- https://go.dev/tour/ — A Tour of Go

---

## Notas Operacionais

1. **Precedência:** `go.dev/ref/*` > `go.dev/doc/*` > `go.dev/blog/*` > `pkg.go.dev` > `wiki` > comunidade
2. **Verificação de versão:** cruzar features com release notes (generics 1.18, slog 1.21, ServeMux patterns 1.22, range-over-func 1.23, generic aliases 1.24)
3. **Links `tip`:** https://tip.golang.org/ — master branch (usar p/ features ainda não estáveis)
4. **Anti-padrões de citação:** evitar Medium/dev.to/tutoriais terceiros — preferir blog oficial `go.dev/blog`
5. **`github.com/golang/go/wiki`:** redireciona p/ `go.dev/wiki` desde 2023, ambas URLs funcionam
