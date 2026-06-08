# 🐹 Golang — Rule de Ativação

> Ativa skill `.claude/skills/golang/SKILL.md` quando contexto envolver Go.

## Quando ativar

**Keywords:** `go`, `golang`, `.go`, `goroutine`, `channel`, `go mod`, `go build`, `go test`, `go run`, `go vet`, `gofmt`, `go.mod`, `go.sum`, `go.work`, `gin`, `echo`, `fiber`, `chi`, `cobra`, `viper`, `pgx`, `gorm`, `sqlx`, `sqlc`, `testify`, `net/http`, `context.Context`, `sync.Mutex`, `errgroup`, `grpc-go`, `microserviço Go`, `CLI em Go`, `API Go`, `worker Go`.

**Arquivos:** `*.go`, `go.mod`, `go.sum`, `go.work`, `.golangci.yml`, `Dockerfile` com `FROM golang`, `.github/workflows/*.yml` com `setup-go`.

## Comportamento

1. **Carregar** `.claude/skills/golang/SKILL.md` (hub principal)
2. **Consultar** `references/official-sources.md` para URLs oficiais — toda recomendação DEVE citar `go.dev`/`pkg.go.dev`
3. **Aplicar workflow:** fundamentos → stdlib first → idiomatic → concurrency-safe → tests (-race) → deploy
4. **Rodar checklist pré-entrega Go** antes de declarar tarefa concluída (gofmt, vet, staticcheck, test -race, golangci-lint, govulncheck, mod tidy)
5. **Cross-link** com skills: `clean-code-rules` (seção Go), `vibe-deploy-guard`, `test-driven-development`, `code-review`, `supabase-factory` (se Postgres)

## Defaults travados

- **Versão:** Go 1.24+ (política oficial: 2 majors recentes suportadas — verificar https://go.dev/dl/ antes de citar versão exata)
- **Estilo:** `gofmt` sempre, `goimports` automático, `golangci-lint` em CI
- **HTTP:** stdlib `net/http` + Chi como escolha idiomática (Gin/Echo/Fiber apenas c/ justificativa)
- **Postgres:** `pgx/v5` > `lib/pq` (recomendação oficial da comunidade pgx)
- **Tests:** table-driven + `t.Parallel()` + testify quando simplificar + `-race` obrigatório
- **Logging:** `log/slog` (Go 1.21+, padrão de produção)
- **CLI:** cobra + viper
- **Concorrência:** channels + context.Context + errgroup — nunca goroutine sem estratégia de término
- **DB queries:** sempre placeholders (`$1`, `$2`), nunca concat de string
- **Docker:** multi-stage com `distroless/static` ou `scratch`
- **CI obrigatório:** `go test -race`, `go vet`, `staticcheck`, `golangci-lint`, `govulncheck`

## Safety carve-out (VERBOSE, sem caverna)

Operações abaixo pedem confirmação explícita:

- `go install` global (`GOBIN`) — polui PATH do usuário
- `go get` diretamente em produção (usar `go mod tidy` local + PR)
- Habilitar **CGO** — mata cross-compilation, adiciona dependência de libc, degrada performance
- Uso de package `unsafe` — justificativa obrigatória + comentário explicando invariantes
- `panic` fora de `main`/`init` — rejeitar e sugerir `error` retornado
- Uso de `math/rand` em contexto de segurança — bloquear, forçar `crypto/rand`
- Sobrescrever `http.DefaultClient` sem timeout — bloquear
- Acesso a runtime `GOMAXPROCS`/`GOGC`/`GOMEMLIMIT` em código de lib — reservado a `main`
- `reflect` em hot path sem benchmark — flaggear

## Integração com ecossistema

| Skill | Integração |
|---|---|
| `clean-code-rules` | Extensão Go (seção 🐹 Go) — naming, functions, errors, imports, formatting, anti-patterns |
| `vibe-deploy-guard` | 18 checks aplicados a Go (SQL injection, secrets, CORS, RLS) |
| `test-driven-development` | TDD cycle com `testing.T`, table-driven, `-race` |
| `code-review` | Review focado em race, context propagation, error wrapping, `%w` |
| `scaffolding` | Usa `templates/` desta skill (cli-cobra, http-service, worker) |
| `supabase-factory` | Consultar ANTES de criar serviço Go que precisa de banco novo |
| `spec-driven-core` | Planning → volta aqui para detalhes Go idiomáticos |
| `graphify` | Grafo AST de código Go (se projetos Go existirem no workspace) |
| `agent-builder` | Agentes IA em Go (quando aplicável) |

## Fonte de verdade

- `.claude/skills/golang/SKILL.md` — hub principal (~500 linhas)
- `.claude/skills/golang/references/official-sources.md` — ~180 URLs oficiais catalogadas
- `.claude/skills/golang/references/concurrency-patterns.md` — 10 patterns canônicos
- `.claude/skills/golang/references/stdlib-cheatsheet.md` — 25 pacotes essenciais
- `.claude/skills/golang/references/toolchain.md` — comandos + linters + CI
- `.claude/skills/golang/references/idiomatic-go.md` — Effective Go + Google Style condensado
- `.claude/skills/golang/references/febracis-integration.md` — Supabase + n8n + Vercel
- `.claude/skills/golang/references/performance-profiling.md` — pprof + escape analysis
- `.claude/skills/golang/references/testing-playbook.md` — table-driven, fuzzing, httptest
- `.claude/skills/golang/gotchas.md` — 30+ armadilhas conhecidas
- `.claude/skills/golang/templates/` — boilerplate pronto (CLI, HTTP service, worker, Docker, golangci)
