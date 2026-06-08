# File Prioritization Matrix — Criterios por Linguagem/Framework

> Scoring 1-5 por likelihood de conter vulnerabilidades.
> Hunt order: 5s primeiro → 4s → 3s se tempo permitir. Skip 1-2 exceto variant analysis.

## TypeScript / React / Next.js

| Score | Arquivos Tipicos | Justificativa |
|-------|-----------------|---------------|
| **5** | `middleware.ts`, `app/api/*/route.ts`, `auth.ts`, `verify.ts` | Auth decisions, API entry points |
| **5** | Upload handlers, webhook receivers, `[...slug].ts` | Untrusted input parsing |
| **5** | `supabase/functions/*/index.ts` (Edge Functions) | Server-side com acesso a secrets |
| **4** | Services que consomem output de auth (`user.service.ts`) | Dependem de auth correto |
| **4** | Query builders, ORM config, `prisma/schema.prisma` | SQL construction, schema |
| **4** | `_middleware.ts`, CORS config, rate limiting | Security policy enforcement |
| **3** | Server components com data fetching | Internal data flow |
| **3** | Config loaders (`next.config.js`, `.env` parsing) | Config injection surface |
| **3** | Logger com user data, error handlers | Info leak via logs |
| **2** | Client components sem input direto | UI rendering only |
| **2** | Utility functions (`format.ts`, `date.ts`) | Pure computation |
| **1** | `types.ts`, `constants.ts`, `enums.ts` | No logic, no I/O |
| **1** | Test fixtures, storybook stories | No production impact |

### Sinais de Priority 5 em Next.js/React
- `req.body`, `req.query`, `req.params` sem validacao Zod
- `dangerouslySetInnerHTML` com dados de usuario
- `NEXT_PUBLIC_` com chaves que deveriam ser privadas
- `supabase.from().select()` sem RLS
- Cookie manipulation sem `httpOnly`/`Secure`/`SameSite`

---

## Python / Django / FastAPI

| Score | Arquivos Tipicos | Justificativa |
|-------|-----------------|---------------|
| **5** | `views.py` com `@api_view`, `routes.py` | API entry points |
| **5** | Auth backends, `authentication.py`, JWT handlers | Auth decisions |
| **5** | File upload views, `serializers.py` sem validacao | Untrusted input |
| **5** | `manage.py` custom commands com input externo | CLI attack surface |
| **4** | `models.py` com custom managers, raw SQL | Query construction |
| **4** | `permissions.py`, middleware de auth | Policy enforcement |
| **4** | `tasks.py` (Celery) com input de fila | Async processing |
| **3** | `utils.py` com operacoes de filesystem | Path traversal risk |
| **3** | `settings.py`, config parsing | Misconfiguration surface |
| **2** | Template tags, template filters | Rendering only |
| **1** | `constants.py`, type hints, dataclasses puras | No logic |

### Sinais de Priority 5 em Python
- `pickle.loads()` com dados de usuario
- `subprocess.call(shell=True)` ou `os.system()`
- `eval()`, `exec()` com input externo
- `cursor.execute(f"SELECT ... {user_input}")` — SQL injection
- `yaml.load()` sem `Loader=SafeLoader`

---

## C / C++

| Score | Arquivos Tipicos | Justificativa |
|-------|-----------------|---------------|
| **5** | Parsers de protocolo (HTTP, DNS, TLS) | Network input parsing |
| **5** | Allocators, memory managers | Memory safety critical |
| **5** | Crypto implementations | Timing, correctness |
| **5** | Kernel modules, drivers | Privilege boundary |
| **4** | String handling (`sprintf`, `strcpy`, `strcat`) | Buffer overflow risk |
| **4** | File I/O com paths de usuario | Path traversal |
| **3** | Internal data structures | Logic correctness |
| **2** | Build scripts, Makefiles | No runtime impact |
| **1** | Header-only type definitions | No logic |

### Sinais de Priority 5 em C/C++
- `malloc(n * sizeof(T))` sem overflow check
- `strcmp` em dados nao null-terminated
- Cast de `size_t` para `int` (truncamento)
- `free()` em error path sem nullify pointer
- Signal handlers com funcoes nao async-safe

---

## Supabase (SQL / RLS / Edge Functions)

| Score | Arquivos Tipicos | Justificativa |
|-------|-----------------|---------------|
| **5** | Migrations com `CREATE POLICY` | RLS decisions |
| **5** | Edge Functions que acessam `service_role` key | Bypassa RLS |
| **5** | Functions/triggers com `SECURITY DEFINER` | Executa como owner |
| **4** | Views que expõem dados filtrados | Filtro correto? |
| **4** | Functions com input de usuario em SQL dinamico | Injection surface |
| **3** | Indexes, constraints | Schema integrity |
| **2** | Seed data, test migrations | No production logic |
| **1** | Type definitions, enums | No logic |

### Sinais de Priority 5 em Supabase
- `USING (true)` em policies de INSERT/UPDATE/DELETE
- `SECURITY DEFINER` sem `SET search_path`
- `EXECUTE format('SELECT ... %s', user_input)` sem `%L`
- Tabela sem RLS habilitado
- Edge Function sem `--no-verify-jwt` + sem auth check manual
