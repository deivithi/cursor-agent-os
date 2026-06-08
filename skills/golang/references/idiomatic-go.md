# 🎨 Idiomatic Go — Effective Go + Google Style Condensado

> Síntese de https://go.dev/doc/effective_go + https://google.github.io/styleguide/go/ + https://go.dev/wiki/CodeReviewComments

---

## Naming

- **Packages:** curto, lower case, sem underscore. `http`, `json`, `sql` — não `utils`, `helpers`.
- **Exported:** `MixedCaps` (PascalCase). Ex: `NewServer`, `UserID`.
- **Unexported:** `mixedCaps` (camelCase). Ex: `newServer`, `userID`.
- **Acronyms consistentes:** `ID` não `Id`, `URL` não `Url`, `HTTP` não `Http`.
- **Receiver names:** 1-2 letras consistentes. `func (s *Server)`, não `func (this *Server)`.
- **Interfaces:** sufixo `-er` quando 1 método. `Reader`, `Writer`, `Stringer`.
- **Context:** sempre `ctx context.Context` como 1º param.
- **Errors:** sentinel = `ErrNotFound`; typed = `*NotFoundError`.

## Functions

- **Uma responsabilidade.** Nome descritivo → corpo curto.
- **Return early / guard clauses.** Evita nesting profundo.
- **Erro como último return.** `(T, error)`.
- **Max 2-3 params.** 4+ → struct.
- **Named returns** apenas em funções curtas onde nomear ajuda doc. Abusar polui.

```go
func FetchUser(ctx context.Context, id int64) (*User, error) {
    if id <= 0 {
        return nil, ErrInvalidID
    }
    row := db.QueryRowContext(ctx, "SELECT ... WHERE id=$1", id)
    var u User
    if err := row.Scan(&u.ID, &u.Name); err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, ErrNotFound
        }
        return nil, fmt.Errorf("scan user %d: %w", id, err)
    }
    return &u, nil
}
```

## Interfaces

- **"The bigger the interface, the weaker the abstraction."** (Go Proverb)
- **Accept interfaces, return structs.**
- **Define interface no consumer**, não no producer.
- Interface pequena (1-3 métodos) é o padrão stdlib.

```go
// ❌ Ruim — definido no package que implementa
package userstore
type UserStore interface { /* 15 métodos */ }

// ✅ Bom — consumer define o que precisa
package handler
type userFetcher interface {
    FetchUser(ctx context.Context, id int64) (*User, error)
}
```

## Error Handling

- **Sempre checar `err`.** `_ = err` só com comentário justificando.
- **Wrapping com `%w`.** `fmt.Errorf("context: %w", err)`.
- **`errors.Is` / `errors.As`** para comparação/extração.
- **Errors são lowercase sem ponto final.** `"not found"`, não `"Not found."`.
- **Panic só em `main`/`init` irrecuperável.** Nunca em lib.

## Imports

Ordem canônica (goimports automatiza):
```go
import (
    // stdlib
    "context"
    "fmt"

    // third-party
    "github.com/go-chi/chi/v5"
    "github.com/jackc/pgx/v5/pgxpool"

    // internal
    "example.com/app/internal/user"
)
```

## Formatting

- **`gofmt` sem exceção.** Não discutir.
- Tabs para indent (gofmt default).
- Line length — sem limite rígido; legibilidade manda.

## Zero Value

> "Make the zero value useful." (Go Proverb)

```go
// sync.Mutex, bytes.Buffer funcionam em zero value:
var mu sync.Mutex       // OK
var buf bytes.Buffer    // OK — já é gravável

// Struct deve seguir mesmo princípio quando possível.
```

## Composition > Inheritance

Go não tem classes. Composição via embedding:

```go
type Logger struct { /* ... */ }
func (l *Logger) Log(msg string) { /* ... */ }

type Server struct {
    *Logger  // embedded — métodos do Logger ficam disponíveis no Server
    port int
}

srv := &Server{Logger: &Logger{}, port: 8080}
srv.Log("started") // chama Logger.Log
```

## Concurrency

- **Channels orchestrate; mutexes serialize.** Ambos têm lugar.
- **Goroutine sempre tem estratégia de término.** Context, WaitGroup, channel close.
- **`context.Context` é 1º param.** Não armazenar em struct.
- **Canal de sinal: `chan struct{}`** — zero bytes vs `chan bool`.

## Documentação (godoc)

```go
// Package user provides domain types and repository interfaces for users.
package user

// User represents an authenticated application user.
type User struct { /* ... */ }

// FetchByID returns the user matching id, or ErrNotFound.
func (r *Repo) FetchByID(ctx context.Context, id int64) (*User, error) { /* ... */ }
```

- Comentário começa c/ nome do símbolo.
- Frases completas, ponto final.
- Package doc no arquivo `doc.go` ou no topo do arquivo principal.

## Anti-patterns (código não-idiomático)

1. `panic` em lib (use `error`)
2. `init()` mágico (side effects invisíveis)
3. Global mutável sem justificativa
4. `interface{}` quando `any` já existe (1.18+)
5. Interface "God" — 15 métodos, 1 implementação
6. Struct tags sem linter
7. `context.Value` p/ DI
8. Sobrescrever `http.DefaultClient` sem timeout
9. Concat string em SQL
10. `fmt.Errorf` sem `%w`
11. Receiver inconsistente (`func (s *Server)` + `func (this *Server)`)
12. `errors.New` embedado em loop (re-aloca)
13. Ignorar `rows.Err()` após `for rows.Next()`
14. `defer` em loop sem extrair função
15. Benchmark sem `b.ResetTimer()` quando setup é caro

## Quick Reference

| Dilema | Escolha | Razão |
|---|---|---|
| `interface{}` vs `any` | `any` (1.18+) | Alias oficial, linter prefer |
| `fmt.Errorf` com `%v` vs `%w` | `%w` | Preserva chain p/ errors.Is/As |
| `context.Background()` em handler | `r.Context()` | Propaga cancel do request |
| `math/rand` em token | `crypto/rand` | Segurança |
| Mutex vs Channel | Channel se fluxo natural, Mutex p/ state composto | Proverb |
| `new(T)` vs `&T{}` | `&T{}` | Mais comum, permite init fields |
| `make([]int, 0)` vs `[]int{}` | ambos OK | Consistência no projeto |
| Named returns | apenas funções curtas | Legibilidade |
| Interface no producer | ❌ | Define no consumer |

## Fontes

- https://go.dev/doc/effective_go
- https://google.github.io/styleguide/go/decisions
- https://google.github.io/styleguide/go/best-practices
- https://go.dev/wiki/CodeReviewComments
- https://go-proverbs.github.io/
