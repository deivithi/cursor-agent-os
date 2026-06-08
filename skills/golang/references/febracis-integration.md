# 🤝 Integração Febracis — Go + Supabase + n8n + Vercel

> Exemplo canônico: microserviço Go q expõe webhook p/ n8n, consulta Supabase Postgres via `pgx`, usa JWT Supabase p/ auth, e deploy no Vercel.

---

## Stack

| Camada | Tecnologia | Fonte |
|---|---|---|
| HTTP | `chi/v5` (stdlib-compatible) | https://go-chi.io/ |
| DB | `pgx/v5` + `pgxpool` (Supabase Postgres) | https://github.com/jackc/pgx |
| Auth | JWT Supabase (`github.com/golang-jwt/jwt/v5` + JWKS) | https://supabase.com/docs/guides/auth/jwts |
| Log | `log/slog` (stdlib) | https://pkg.go.dev/log/slog |
| Config | `viper` (env first) | https://github.com/spf13/viper |
| Deploy | Vercel `@vercel/go` | https://vercel.com/docs/functions/runtimes/go |

---

## Estrutura de projeto

```
myservice/
├── api/
│   └── webhook.go            # Vercel handler (serverless)
├── cmd/
│   └── server/
│       └── main.go           # Entrypoint standalone
├── internal/
│   ├── config/config.go
│   ├── auth/supabase_jwt.go
│   ├── repo/user_repo.go
│   ├── service/user_service.go
│   └── handler/
│       ├── user_handler.go
│       └── webhook_handler.go
├── migrations/               # SQL Supabase (gerenciado por supabase-factory)
├── go.mod
├── go.sum
├── Dockerfile
├── .golangci.yml
└── .github/workflows/ci.yml
```

---

## go.mod (core deps)

```go
module example.com/myservice

go 1.24

require (
    github.com/go-chi/chi/v5 v5.1.0
    github.com/jackc/pgx/v5 v5.7.1
    github.com/golang-jwt/jwt/v5 v5.2.1
    github.com/spf13/viper v1.19.0
    golang.org/x/sync v0.8.0
)
```

---

## 1. Config (env first)

```go
// internal/config/config.go
package config

import (
    "fmt"
    "github.com/spf13/viper"
)

type Config struct {
    Port         int    `mapstructure:"PORT"`
    DatabaseURL  string `mapstructure:"DATABASE_URL"`
    SupabaseURL  string `mapstructure:"SUPABASE_URL"`
    JWTSecret    string `mapstructure:"SUPABASE_JWT_SECRET"` // p/ HS256
    N8nWebhookSecret string `mapstructure:"N8N_WEBHOOK_SECRET"`
}

func Load() (*Config, error) {
    v := viper.New()
    v.AutomaticEnv()
    v.SetDefault("PORT", 8080)
    var c Config
    if err := v.Unmarshal(&c); err != nil {
        return nil, fmt.Errorf("config unmarshal: %w", err)
    }
    if c.DatabaseURL == "" {
        return nil, fmt.Errorf("DATABASE_URL required")
    }
    return &c, nil
}
```

---

## 2. Postgres Pool (Supabase)

```go
// internal/repo/pool.go
package repo

import (
    "context"
    "fmt"
    "github.com/jackc/pgx/v5/pgxpool"
)

func NewPool(ctx context.Context, dsn string) (*pgxpool.Pool, error) {
    cfg, err := pgxpool.ParseConfig(dsn)
    if err != nil {
        return nil, fmt.Errorf("parse DSN: %w", err)
    }
    cfg.MaxConns = 10
    cfg.MinConns = 2
    pool, err := pgxpool.NewWithConfig(ctx, cfg)
    if err != nil {
        return nil, fmt.Errorf("pgxpool: %w", err)
    }
    if err := pool.Ping(ctx); err != nil {
        pool.Close()
        return nil, fmt.Errorf("ping: %w", err)
    }
    return pool, nil
}
```

**Importante:** Supabase pooler port = `6543` (transaction mode) ou `5432` (session). Escolher por workload — `pgxpool` + transaction pooler é default.

---

## 3. Repo c/ context + placeholders

```go
// internal/repo/user_repo.go
package repo

import (
    "context"
    "errors"
    "fmt"

    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("user not found")

type UserRepo struct { pool *pgxpool.Pool }

func NewUserRepo(p *pgxpool.Pool) *UserRepo { return &UserRepo{pool: p} }

type User struct {
    ID    int64
    Email string
    Name  string
}

func (r *UserRepo) ByID(ctx context.Context, id int64) (*User, error) {
    var u User
    err := r.pool.QueryRow(ctx,
        `SELECT id, email, name FROM public.users WHERE id = $1`, id,
    ).Scan(&u.ID, &u.Email, &u.Name)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) { return nil, ErrNotFound }
        return nil, fmt.Errorf("query user %d: %w", id, err)
    }
    return &u, nil
}
```

**RLS:** Supabase força RLS — service role key bypassa; usar `anon` + JWT no client. Em Go server-side, usar `DATABASE_URL` c/ service role **apenas** em env vars server-side, nunca exposto.

---

## 4. JWT Supabase (middleware)

```go
// internal/auth/supabase_jwt.go
package auth

import (
    "context"
    "fmt"
    "net/http"
    "strings"

    "github.com/golang-jwt/jwt/v5"
)

type ctxKey string
const UserIDKey ctxKey = "user_id"

func Middleware(jwtSecret string) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            tok := strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ")
            if tok == "" {
                http.Error(w, "missing token", http.StatusUnauthorized)
                return
            }
            parsed, err := jwt.Parse(tok, func(t *jwt.Token) (any, error) {
                if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
                    return nil, fmt.Errorf("unexpected alg: %v", t.Header["alg"])
                }
                return []byte(jwtSecret), nil
            })
            if err != nil || !parsed.Valid {
                http.Error(w, "invalid token", http.StatusUnauthorized)
                return
            }
            claims := parsed.Claims.(jwt.MapClaims)
            sub, _ := claims["sub"].(string)
            ctx := context.WithValue(r.Context(), UserIDKey, sub)
            next.ServeHTTP(w, r.WithContext(ctx))
        })
    }
}
```

Supabase JWT secret: Dashboard → Project Settings → API → JWT Secret (HS256).
Para RS256 (JWKS), usar `https://<project>.supabase.co/auth/v1/keys` + lib JWKS.

---

## 5. Webhook n8n (HMAC verify)

```go
// internal/handler/webhook_handler.go
package handler

import (
    "crypto/hmac"
    "crypto/sha256"
    "encoding/hex"
    "encoding/json"
    "io"
    "log/slog"
    "net/http"
)

func N8nWebhook(secret string) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        sig := r.Header.Get("X-Signature")
        body, err := io.ReadAll(r.Body)
        if err != nil { http.Error(w, "read body", 400); return }
        defer r.Body.Close()

        mac := hmac.New(sha256.New, []byte(secret))
        mac.Write(body)
        expected := hex.EncodeToString(mac.Sum(nil))
        if !hmac.Equal([]byte(sig), []byte(expected)) {
            http.Error(w, "invalid signature", http.StatusUnauthorized)
            return
        }

        var payload map[string]any
        if err := json.Unmarshal(body, &payload); err != nil {
            http.Error(w, "bad json", 400); return
        }
        slog.Info("n8n webhook", "event", payload["event"])
        w.WriteHeader(http.StatusAccepted)
    }
}
```

---

## 6. Main c/ graceful shutdown

```go
// cmd/server/main.go
package main

import (
    "context"
    "errors"
    "log/slog"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/go-chi/chi/v5"
    "github.com/go-chi/chi/v5/middleware"
)

func main() {
    if err := run(); err != nil {
        slog.Error("fatal", "err", err)
        os.Exit(1)
    }
}

func run() error {
    slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, nil)))

    cfg, err := config.Load()
    if err != nil { return err }

    ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
    defer stop()

    pool, err := repo.NewPool(ctx, cfg.DatabaseURL)
    if err != nil { return err }
    defer pool.Close()

    r := chi.NewRouter()
    r.Use(middleware.RequestID, middleware.Recoverer, middleware.Timeout(30*time.Second))
    r.Post("/webhooks/n8n", handler.N8nWebhook(cfg.N8nWebhookSecret))
    r.Route("/api", func(r chi.Router) {
        r.Use(auth.Middleware(cfg.JWTSecret))
        r.Get("/me", /* ... */)
    })

    srv := &http.Server{
        Addr:              ":" + fmt.Sprint(cfg.Port),
        Handler:           r,
        ReadHeaderTimeout: 5 * time.Second,
    }

    go func() {
        if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
            slog.Error("listen", "err", err)
        }
    }()
    slog.Info("listening", "port", cfg.Port)

    <-ctx.Done()
    shCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()
    return srv.Shutdown(shCtx)
}
```

---

## 7. Vercel handler (`api/webhook.go`)

```go
package handler

import "net/http"

// Handler é o entrypoint Vercel — roteia em /api/webhook
func Handler(w http.ResponseWriter, r *http.Request) {
    // mesma lógica do handler.N8nWebhook, mas stateless
    w.WriteHeader(http.StatusOK)
    w.Write([]byte("ok"))
}
```

`vercel.json`:
```json
{
  "functions": {
    "api/webhook.go": { "runtime": "vercel-go@1.0.0" }
  }
}
```

Fonte: https://vercel.com/docs/functions/runtimes/go

---

## 8. Dockerfile multi-stage

Ver `templates/Dockerfile` desta skill.

---

## Integração c/ outras skills Febracis

- **`supabase-factory`** — consultar ANTES de criar schema novo. Decide schema em `febracis-dre` vs projeto novo.
- **`vibe-deploy-guard`** — 18 checks aplicados automaticamente (SQL injection, secrets, CORS, RLS).
- **`n8n`** — workflows consumindo estes webhooks (usar `n8n-workflow-patterns`).
- **`observability`** — integrar slog c/ Sentry / OpenTelemetry.

---

## Checklist pré-deploy Febracis

```
□ pgx connection string aponta p/ pooler port (6543) em produção
□ RLS ativa em tabelas sensíveis
□ JWT validation usa secret correto (dev vs prod)
□ Secrets em Vercel env (não em código)
□ HMAC verify em webhooks n8n
□ slog em JSON (prod) / text (dev)
□ Graceful shutdown c/ timeout
□ Rate limiting em endpoints públicos
□ CORS restrito a domínios conhecidos
□ Health check endpoint /healthz
□ Metrics /metrics (Prometheus) se aplicável
```

## Fontes

- https://supabase.com/docs/guides/auth/jwts
- https://supabase.com/docs/guides/database/connecting-to-postgres
- https://vercel.com/docs/functions/runtimes/go
- https://github.com/jackc/pgx
- https://go-chi.io/
