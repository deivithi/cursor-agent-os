# 🧪 Testing Playbook — Go

> Padrões idiomáticos: table-driven, subtests, t.Parallel, fuzzing, httptest, testify.

---

## 1. Table-driven + Subtests (padrão canônico)

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name    string
        a, b    int
        want    int
    }{
        {"positives", 2, 3, 5},
        {"zero",      0, 0, 0},
        {"negatives", -1, -1, -2},
    }
    for _, tt := range tests {
        tt := tt // pré-1.22 capture — remover em 1.22+
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()
            if got := Add(tt.a, tt.b); got != tt.want {
                t.Errorf("Add(%d,%d) = %d, want %d", tt.a, tt.b, got, tt.want)
            }
        })
    }
}
```

Fonte: https://go.dev/wiki/TableDrivenTests | https://go.dev/blog/subtests

---

## 2. Test Helpers

```go
func setupDB(t *testing.T) *sql.DB {
    t.Helper()  // error aponta p/ caller
    db, err := sql.Open("postgres", testDSN)
    if err != nil { t.Fatalf("open db: %v", err) }
    t.Cleanup(func() { db.Close() })  // roda no fim do teste
    return db
}
```

- `t.Helper()` — stack trace aponta p/ caller
- `t.Cleanup(fn)` — substituto moderno de `defer` em helpers

Fonte: https://pkg.go.dev/testing#T.Helper | https://pkg.go.dev/testing#T.Cleanup

---

## 3. httptest (HTTP server/client)

### Testando handler
```go
func TestUserHandler(t *testing.T) {
    req := httptest.NewRequest(http.MethodGet, "/users/42", nil)
    w := httptest.NewRecorder()

    handler.GetUser(w, req)

    if w.Code != http.StatusOK {
        t.Errorf("status = %d, want 200", w.Code)
    }
    var got User
    if err := json.NewDecoder(w.Body).Decode(&got); err != nil {
        t.Fatal(err)
    }
    if got.ID != 42 { t.Errorf("id = %d", got.ID) }
}
```

### Server de teste
```go
srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, `{"ok":true}`)
}))
defer srv.Close()

resp, err := http.Get(srv.URL + "/api")
// ...
```

Fonte: https://pkg.go.dev/net/http/httptest

---

## 4. testify (comunidade padrão)

```go
import (
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestUser(t *testing.T) {
    u, err := FetchUser(ctx, 42)
    require.NoError(t, err)         // require.* para assertions "fatais"
    require.NotNil(t, u)
    assert.Equal(t, "alice", u.Name) // assert.* continua se falhar
    assert.Contains(t, u.Email, "@")
}
```

- `require` para precondições (aborta se falha)
- `assert` para verificações (continua)

Mock: `testify/mock`. Suite: `testify/suite`.
Fonte: https://github.com/stretchr/testify

---

## 5. Fuzzing (Go 1.18+)

```go
func FuzzParseInt(f *testing.F) {
    f.Add("42")
    f.Add("-1")
    f.Add("")
    f.Fuzz(func(t *testing.T, s string) {
        _, err := ParseInt(s)
        if err != nil && !errors.Is(err, ErrInvalid) {
            t.Errorf("unexpected error: %v", err)
        }
    })
}
```

```bash
go test -fuzz=FuzzParseInt -fuzztime=30s ./parser
```

Corpus salvo em `testdata/fuzz/FuzzParseInt/`. Falhas viram unit tests automaticamente.

Fonte: https://go.dev/doc/fuzz/

---

## 6. Benchmarks

```go
func BenchmarkParseInt(b *testing.B) {
    input := "123456789"
    b.ReportAllocs()
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        _, _ = ParseInt(input)
    }
}
```

```bash
go test -bench=. -benchmem -count=5 -benchtime=3s ./...
```

Fonte: https://pkg.go.dev/testing#hdr-Benchmarks

---

## 7. Integration Tests (DB real)

Prefer real DB em container sobre mocks.

```go
func TestUserRepo_Integration(t *testing.T) {
    if testing.Short() { t.Skip("skip integration") }

    pool, err := repo.NewPool(ctx, testDSN)
    require.NoError(t, err)
    t.Cleanup(func() { pool.Close() })

    r := repo.NewUserRepo(pool)
    u, err := r.ByID(ctx, 1)
    // assertions...
}
```

```bash
go test -short ./...           # pula integration
go test ./...                  # todos
```

Tool: https://github.com/testcontainers/testcontainers-go

---

## 8. Mock com interface (stdlib)

```go
type userFetcher interface {
    FetchUser(ctx context.Context, id int64) (*User, error)
}

type fakeFetcher struct {
    user *User
    err  error
}
func (f *fakeFetcher) FetchUser(context.Context, int64) (*User, error) {
    return f.user, f.err
}

func TestService(t *testing.T) {
    svc := NewService(&fakeFetcher{user: &User{ID: 1}})
    // ...
}
```

Regra: interface definida **no consumer**, não no producer.

---

## 9. t.Parallel + Safety

- Cada subtest c/ `t.Parallel()` precisa de estado local
- `t.Setenv()` é auto-revertido e compatível c/ parallel
- **Não** compartilhar maps/slices mutáveis entre subtests paralelos

```go
for _, tt := range tests {
    tt := tt
    t.Run(tt.name, func(t *testing.T) {
        t.Parallel()
        // state LOCAL
        svc := NewService(newFakeDeps())
        // ...
    })
}
```

Fonte: https://pkg.go.dev/testing#T.Parallel

---

## 10. Coverage

```bash
go test -cover ./...
go test -coverprofile=c.out ./...
go tool cover -html=c.out
go tool cover -func=c.out | tail -1    # total
```

Target: 70-80% linhas para código de domínio. 100% não é objetivo — qualidade > coverage.

---

## 11. Race Detector (SEMPRE)

```bash
go test -race -count=1 ./...
```

Obriga em CI. Fonte: https://go.dev/doc/articles/race_detector

---

## Checklist Tests

```
□ Table-driven para múltiplos casos
□ t.Parallel() onde possível
□ t.Helper() em funções auxiliares
□ t.Cleanup() em setups
□ -race sempre passa
□ -count=1 em CI (sem cache)
□ Integration tests marcadas c/ testing.Short()
□ Coverage track (sem obsessão)
□ Fuzzing em parsers/decoders
□ Sem state global compartilhado entre testes
□ Mocks via interface no consumer
```

## Fontes

- https://pkg.go.dev/testing
- https://go.dev/wiki/TableDrivenTests
- https://go.dev/blog/subtests
- https://go.dev/doc/fuzz/
- https://go.dev/doc/articles/race_detector
- https://pkg.go.dev/net/http/httptest
- https://github.com/stretchr/testify
