# 🐹 Golang — Gotchas (30+ Armadilhas Conhecidas)

> Consultar SEMPRE antes de declarar feature Go concluída. Cada entrada: causa + fix + link oficial.

---

## 1. Loop variable capture em goroutines (pré-Go 1.22)

**Causa:** em Go < 1.22, variável de loop era compartilhada entre iterações — goroutines capturavam o valor final.
**Fix:**
- Go 1.22+ — semântica muda: cada iteração tem sua própria variável ([release notes](https://go.dev/doc/go1.22#language))
- Em código < 1.22: `v := v` dentro do loop antes da goroutine
```go
for _, v := range items {
    v := v // shadow para pré-1.22
    go process(v)
}
```
**Docs:** https://go.dev/doc/go1.22#language | https://go.dev/ref/spec#For_statements

---

## 2. Nil map write → panic

**Causa:** map declarado mas não inicializado (`var m map[string]int`) não pode receber escrita.
**Fix:** `m := make(map[string]int)` ou `m := map[string]int{}`
**Docs:** https://go.dev/ref/spec#Map_types

---

## 3. Slice aliasing e `append` surprise

**Causa:** `append` pode ou não realocar. Slices que compartilham array subjacente se afetam mutuamente.
**Fix:** quando precisar de cópia independente: `dst := append([]T(nil), src...)` ou `slices.Clone(src)` (Go 1.21+)
**Docs:** https://go.dev/blog/slices-intro | https://pkg.go.dev/slices#Clone

---

## 4. Channel close do lado errado

**Causa:** só o **producer** deve fechar. Consumer fechando → panic "send on closed channel".
**Fix:**
```go
// producer
defer close(ch)
for _, v := range items { ch <- v }

// consumer — nunca fecha
for v := range ch { process(v) }
```
**Docs:** https://go.dev/ref/spec#Close

---

## 5. Goroutine leak sem context cancellation

**Causa:** goroutine espera em channel/I/O sem estratégia de saída → vive para sempre.
**Fix:** `context.Context` com cancellation + `select`:
```go
select {
case <-ctx.Done():
    return ctx.Err()
case v := <-ch:
    process(v)
}
```
**Docs:** https://go.dev/blog/context | https://pkg.go.dev/context

---

## 6. `defer` dentro de loop → acúmulo

**Causa:** `defer` executa no fim da função, não da iteração. Loop grande = memória/handles acumulados.
**Fix:** extrair corpo do loop para função:
```go
for _, f := range files {
    func() {
        r, err := os.Open(f)
        if err != nil { return }
        defer r.Close()
        // ...
    }()
}
```
**Docs:** https://go.dev/blog/defer-panic-and-recover

---

## 7. Typed nil != nil (interface quirk)

**Causa:** interface guarda (type, value). `var err *MyErr = nil; return err` retorna interface com type=*MyErr, value=nil — não é igual a `nil` puro.
**Fix:** retornar `nil` explícito:
```go
if myErr == nil { return nil }
return myErr
```
**Docs:** https://go.dev/doc/faq#nil_error

---

## 8. `time.After` em loops longos → memory leak

**Causa:** `time.After` cria novo timer a cada chamada; se select não consome, timer fica vivo até disparar.
**Fix:** usar `time.NewTimer` + `Reset`:
```go
t := time.NewTimer(d)
defer t.Stop()
for {
    select {
    case <-t.C:
    case <-ctx.Done(): return
    }
    t.Reset(d)
}
```
**Docs:** https://pkg.go.dev/time#After (nota oficial sobre leak)

---

## 9. `context.Value` para injetar dependências

**Causa:** anti-pattern. `context.Value` é para **request-scoped data opaca** (trace IDs, auth tokens), não para DI de deps.
**Fix:** passar deps como parâmetros explícitos ou via struct receiver.
**Docs:** https://go.dev/blog/context#TOC_3.2. (seção "Package userip")

---

## 10. State de pacote em testes

**Causa:** variáveis globais mutáveis (ex: `os.Setenv`) poluem entre testes.
**Fix:** `t.Setenv("KEY", "val")` — reverte automaticamente no fim do teste.
**Docs:** https://pkg.go.dev/testing#T.Setenv

---

## 11. `fmt.Errorf` sem `%w` perde chain

**Causa:** `fmt.Errorf("failed: %v", err)` cria novo erro sem wrapping — `errors.Is/As` não funcionam.
**Fix:** usar `%w`:
```go
return fmt.Errorf("fetch user %d: %w", id, err)
```
**Docs:** https://go.dev/blog/go1.13-errors

---

## 12. `for range` sobre channel sem close → deadlock

**Causa:** `for v := range ch` espera até channel fechar. Se ninguém fechar, goroutine trava.
**Fix:** garantir `close(ch)` no producer (via `defer`).
**Docs:** https://go.dev/ref/spec#For_range

---

## 13. `sync.WaitGroup.Add()` dentro da goroutine → race

**Causa:** se `Add` roda dentro da goroutine, `Wait` pode ser chamado antes → WaitGroup conta errado.
**Fix:** `Add` **antes** de `go`:
```go
for _, task := range tasks {
    wg.Add(1) // ANTES do go
    go func(t Task) {
        defer wg.Done()
        process(t)
    }(task)
}
wg.Wait()
```
**Docs:** https://pkg.go.dev/sync#WaitGroup.Add

---

## 14. Map concorrente sem mutex → fatal error

**Causa:** map não é thread-safe. Escrita concorrente → `fatal error: concurrent map writes` (não captura com recover).
**Fix:** `sync.Mutex` + map, ou `sync.Map` (se padrão write-once-read-many).
**Docs:** https://pkg.go.dev/sync#Map | https://go.dev/doc/articles/race_detector

---

## 15. `panic` atravessa goroutines e mata processo

**Causa:** panic em goroutine que não tem `recover` → runtime termina todo o processo.
**Fix:** em libs/handlers, `defer` com `recover`:
```go
defer func() {
    if r := recover(); r != nil {
        slog.Error("panic recovered", "err", r, "stack", debug.Stack())
    }
}()
```
Mas o ideal é **não entrar em panic em lib**.
**Docs:** https://go.dev/blog/defer-panic-and-recover

---

## 16. `os.Exit` não roda `defer`

**Causa:** `os.Exit` termina imediato — `defer`s não executam.
**Fix:** estrutura main limpa:
```go
func main() {
    if err := run(); err != nil {
        slog.Error("fatal", "err", err)
        os.Exit(1)
    }
}
func run() error { /* defers aqui rodam */ }
```
**Docs:** https://pkg.go.dev/os#Exit

---

## 17. JSON `omitempty` em `bool` (false é omitido)

**Causa:** `omitempty` omite zero value. Bool zero = false. Se você quer distinguir "não informado" de "false", usar `*bool`.
**Fix:**
```go
type Req struct {
    Enabled *bool `json:"enabled,omitempty"`
}
```
**Docs:** https://pkg.go.dev/encoding/json#Marshal

---

## 18. Struct tags typo → zero erro em compile

**Causa:** `json:"usr_name"` em vez de `json:"user_name"` não dá erro, só quebra em runtime.
**Fix:** habilitar linter `tagliatelle` em golangci-lint; rodar teste de marshal/unmarshal.
**Docs:** https://golangci-lint.run/usage/linters/

---

## 19. `math/rand` em contexto de segurança

**Causa:** `math/rand` é previsível (PRNG). Usar em tokens/session → vulnerabilidade.
**Fix:** `crypto/rand` para qualquer coisa de segurança:
```go
import "crypto/rand"
b := make([]byte, 32)
_, err := rand.Read(b)
```
**Docs:** https://pkg.go.dev/crypto/rand

---

## 20. `http.Client` default sem timeout → socket leak

**Causa:** `http.DefaultClient` tem timeout = 0 (infinito). Server lento → socket preso indefinidamente.
**Fix:**
```go
client := &http.Client{Timeout: 10 * time.Second}
// ou, melhor: per-request via context
req, _ := http.NewRequestWithContext(ctx, "GET", url, nil)
```
**Docs:** https://pkg.go.dev/net/http#Client

---

## 21. `ioutil.*` deprecado desde Go 1.16

**Causa:** pacote `io/ioutil` substituído por `io` + `os`.
**Fix:** `ioutil.ReadAll` → `io.ReadAll`; `ioutil.ReadFile` → `os.ReadFile`; `ioutil.TempFile` → `os.CreateTemp`.
**Docs:** https://go.dev/doc/go1.16#ioutil

---

## 22. `interface{}` vs `any` (Go 1.18+)

**Causa:** `interface{}` ainda compila, mas `any` é o alias oficial desde 1.18.
**Fix:** prefer `any`. Linter `revive` flagga `use-any`.
**Docs:** https://pkg.go.dev/builtin#any

---

## 23. `reflect` em hot path → performance degradada

**Causa:** reflect é lento (ordens de magnitude vs acesso direto). Em hot paths (serialização massiva, loops críticos) vira gargalo.
**Fix:** code gen (sqlc, easyjson, protobuf) ou generics (1.18+) no lugar de reflect.
**Docs:** https://go.dev/blog/laws-of-reflection

---

## 24. `sync.Map` nem sempre é melhor

**Causa:** `sync.Map` otimiza casos específicos (write-once/read-many, chaves disjuntas). Para uso geral, `map + sync.Mutex` é mais rápido.
**Fix:** benchmark antes de trocar.
**Docs:** https://pkg.go.dev/sync#Map (nota oficial sobre quando usar)

---

## 25. Import cycle

**Causa:** Go rejeita ciclos de import em compile time.
**Fix:** extrair tipos/interfaces compartilhados para pacote terceiro (`internal/domain/`). Aplicar DIP.
**Docs:** https://go.dev/ref/spec#Import_declarations

---

## 26. CGO mata cross-compilation

**Causa:** habilitar CGO (`CGO_ENABLED=1`) requer libc do target no build → cross-compile complicado.
**Fix:** manter `CGO_ENABLED=0` sempre que possível. Preferir stdlib/pure-Go.
**Docs:** https://pkg.go.dev/cmd/cgo

---

## 27. Excesso de generics

**Causa:** generics transformam código simples em abstração difícil de ler.
**Fix:** guia oficial "When to use generics":
- ✅ funções sobre slices/maps/channels genéricas
- ✅ data structures genéricas
- ❌ quando interface resolve
- ❌ por abstração premature
**Docs:** https://go.dev/blog/when-generics

---

## 28. `t.Parallel` + state compartilhado → race

**Causa:** tests paralelos escrevem em mesma variável global.
**Fix:** state local por teste; `t.Setenv` para env vars; construtor de fixtures por teste.
**Docs:** https://pkg.go.dev/testing#T.Parallel

---

## 29. `context.Background()` em handler HTTP

**Causa:** perde cancellation do request (cliente desconectou → server continua processando).
**Fix:** usar `r.Context()`:
```go
func handler(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()
    result, err := svc.Do(ctx, ...) // propaga cancel
}
```
**Docs:** https://pkg.go.dev/net/http#Request.Context

---

## 30. `database/sql` sem `rows.Close()` → connection leak

**Causa:** `rows` mantém conn no pool até `Close()`. Sem defer → conn vaza.
**Fix:**
```go
rows, err := db.QueryContext(ctx, q, args...)
if err != nil { return err }
defer rows.Close()
for rows.Next() { /* ... */ }
if err := rows.Err(); err != nil { return err }
```
**Docs:** https://pkg.go.dev/database/sql#Rows.Close

---

## 31. `errors.Is` com erro não-sentinel

**Causa:** `errors.Is(err, SomeStruct{...})` compara identidade, não conteúdo.
**Fix:** usar sentinel (`var ErrX = errors.New(...)`) ou implementar método `Is(target error) bool` no tipo custom.
**Docs:** https://pkg.go.dev/errors#Is

---

## 32. Shadowing com `:=`

**Causa:** `if err := f(); err != nil` cria `err` novo no bloco — não reaproveita externo.
**Fix:** cuidado com `:=` em blocos aninhados; linter `govet` detecta.
**Docs:** https://pkg.go.dev/cmd/vet#hdr-Shadowed_variables

---

## 33. `json.Unmarshal` sobre struct sem tags → case-insensitive mas frágil

**Causa:** Go faz case-insensitive match em fields exportados sem tag — aceita `USER_ID`, `userid`, `user_id` todos mapeando para `UserId`. Pode causar bugs sutis.
**Fix:** sempre declarar tags explícitas: `json:"user_id"`.
**Docs:** https://pkg.go.dev/encoding/json#Unmarshal

---

## 34. Valores em `defer` são avaliados **imediato**

**Causa:** `defer fmt.Println(x)` captura valor atual de `x`, não valor no fim.
**Fix:** se quer captura tardia, usar closure: `defer func() { fmt.Println(x) }()`.
**Docs:** https://go.dev/ref/spec#Defer_statements

---

## 35. `float64` para dinheiro

**Causa:** float binário não representa decimais exatos (0.1 + 0.2 ≠ 0.3).
**Fix:** inteiros em centavos, ou biblioteca `shopspring/decimal`.
**Docs:** (IEEE 754) — ver https://go.dev/ref/spec#Numeric_types

---

## Referência Cruzada

| Gotcha | Skills relacionadas |
|---|---|
| 4, 5, 13, 14, 15 | `code-review`, `test-driven-development` (`-race`) |
| 19, 20 | `vibe-deploy-guard` |
| 29, 30 | `vibe-deploy-guard` (VDG-12 SQL), `supabase-factory` |
| 11, 31 | `clean-code-rules` (Go — error handling) |

**Checklist:** rodar `go test -race`, `staticcheck`, `golangci-lint`, `govulncheck` antes de qualquer entrega captura 80% destas.
