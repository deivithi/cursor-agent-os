# 🧰 Toolchain — Comandos, Linters, CI

## Comandos `go` essenciais

```bash
go build ./...                    # compila tudo
go build -o bin/app ./cmd/app     # binário específico
go build -trimpath -ldflags="-s -w" ./cmd/app   # build produção (sem paths, stripped)
go run ./cmd/app                  # compila + roda
go test ./...                     # roda todos tests
go test -race -count=1 ./...      # race detector + sem cache
go test -cover -coverprofile=c.out ./...
go tool cover -html=c.out         # view coverage no browser
go test -bench=. -benchmem ./...  # benchmarks + memória
go test -fuzz=FuzzX -fuzztime=30s ./pkg  # fuzzing
go vet ./...                      # análise estática oficial
gofmt -s -l .                     # lista arquivos mal formatados (zero = OK)
gofmt -s -w .                     # formata in-place
goimports -w .                    # formata + organiza imports
go mod init example.com/app
go mod tidy                       # limpa go.mod/go.sum
go mod download                   # baixa deps em cache
go mod graph                      # grafo de deps
go mod why <pkg>                  # por que pacote está no grafo
go work init ./a ./b              # workspace multi-module
go version
go env                            # env vars go
go tool pprof cpu.prof            # profiling
GOOS=linux GOARCH=arm64 go build  # cross-compile
```

Fonte: https://pkg.go.dev/cmd/go

## Linters

### staticcheck (de-facto standard)
```bash
go install honnef.co/go/tools/cmd/staticcheck@latest
staticcheck ./...
```
https://staticcheck.dev/

### golangci-lint (meta-linter)
```bash
# instalação: https://golangci-lint.run/usage/install/
golangci-lint run
golangci-lint run --fix  # auto-fix quando possível
```
https://golangci-lint.run/

### govulncheck (CVE scanner oficial)
```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
```
https://go.dev/security/vuln/

## `.golangci.yml` recomendado

```yaml
run:
  timeout: 5m
  go: "1.24"

linters:
  disable-all: true
  enable:
    - errcheck        # erros não checados
    - gosimple        # simplificações
    - govet           # análise estática
    - ineffassign     # atribuições inefetivas
    - staticcheck     # todo catálogo staticcheck
    - unused          # código morto
    - gofmt
    - goimports
    - gosec           # segurança
    - bodyclose       # http body não fechado
    - contextcheck    # context propagation
    - errorlint       # error wrapping correto
    - gocritic
    - revive          # substituto moderno do golint
    - unconvert
    - unparam

linters-settings:
  errcheck:
    check-type-assertions: true
  gosec:
    excludes:
      - G104  # audited error handling

issues:
  exclude-dirs:
    - vendor
  max-issues-per-linter: 0
  max-same-issues: 0
```

Catálogo: https://golangci-lint.run/usage/linters/

## CI (GitHub Actions)

```yaml
name: go-ci
on:
  push:
    branches: [main]
  pull_request:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: "1.24"
          cache: true
      - run: go mod download
      - run: gofmt -s -l . | (! grep .)
      - run: go vet ./...
      - run: go build ./...
      - run: go test -race -count=1 -coverprofile=coverage.out ./...
      - uses: golangci/golangci-lint-action@v6
        with:
          version: latest
      - run: go install golang.org/x/vuln/cmd/govulncheck@latest && govulncheck ./...
```

## Checklist Pré-Entrega

```bash
gofmt -s -l .                        # zero output
go vet ./...                         # limpo
staticcheck ./...                    # limpo
go test -race -count=1 ./...         # PASS
golangci-lint run                    # zero issues
govulncheck ./...                    # No vulnerabilities
go mod tidy && git diff --exit-code go.mod go.sum  # sem diff
```

Fonte: https://go.dev/doc/cmd
